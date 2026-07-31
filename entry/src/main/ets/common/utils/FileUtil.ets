/**
 * FrameKeep（帧藏）- 文件工具类
 * 用于处理文件复制，将相册图片复制到应用私有目录
 */
import { fileIo as fs } from '@kit.CoreFileKit'
import { common } from '@kit.AbilityKit'
import { image } from '@kit.ImageKit'
import { BusinessError } from '@kit.BasicServicesKit'

/**
 * 文件工具类
 */
export class FileUtil {
  private static instance: FileUtil
  private context: common.UIAbilityContext | null = null

  // 应用私有目录中的媒体文件夹
  private readonly MEDIA_DIR = 'media'

  private constructor() {}

  /**
   * 获取单例实例
   */
  static getInstance(): FileUtil {
    if (!FileUtil.instance) {
      FileUtil.instance = new FileUtil()
    }
    return FileUtil.instance
  }

  /**
   * 初始化（在 EntryAbility.onCreate 中调用）
   */
  init(context: common.UIAbilityContext): void {
    this.context = context
    // 创建媒体目录
    this.ensureMediaDir()
    console.info('[FileUtil] 初始化成功')
  }

  /**
   * 确保媒体目录存在
   */
  private ensureMediaDir(): void {
    if (!this.context) {
      console.error('[FileUtil] 未初始化')
      return
    }
    const mediaDir = `${this.context.filesDir}/${this.MEDIA_DIR}`
    try {
      if (!fs.accessSync(mediaDir)) {
        fs.mkdirSync(mediaDir)
        console.info(`[FileUtil] 创建媒体目录: ${mediaDir}`)
      }
    } catch (err) {
      try {
        fs.mkdirSync(mediaDir, true)
        console.info(`[FileUtil] 创建媒体目录: ${mediaDir}`)
      } catch (e) {
        console.error(`[FileUtil] 创建媒体目录失败: ${e}`)
      }
    }
  }

  /**
   * 将相册图片复制到应用私有目录
   * @param sourceUri 相册 URI（如 file:// 或 datashare://）
   * @returns 复制后的文件路径（相对于 filesDir），失败返回空字符串
   */
  async copyImageToPrivate(sourceUri: string): Promise<string> {
    if (!this.context) {
      console.error('[FileUtil] 未初始化')
      return ''
    }

    try {
      // 生成唯一文件名
      const timestamp = Date.now()
      const random = Math.floor(Math.random() * 10000)
      const fileName = `img_${timestamp}_${random}.jpg`
      const destPath = `${this.context.filesDir}/${this.MEDIA_DIR}/${fileName}`

      // 使用 ImagePacker 将图片解码后重新编码保存
      // 这样可以处理各种 URI 格式（file://, datashare://）
      const imageSource = image.createImageSource(sourceUri)
      const bitmap = await imageSource.createPixelMap()
      
      // 创建 ImagePacker
      const imagePackerApi = image.createImagePacker()
      const packOpts: image.PackingOption = {
        format: 'image/jpeg',
        quality: 90
      }
      
      // 打包图片为 ArrayBuffer
      const arrayBuffer = await imagePackerApi.packing(bitmap, packOpts)
      
      // 写入文件
      const destFile = fs.openSync(destPath, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY)
      fs.writeSync(destFile.fd, arrayBuffer)
      fs.closeSync(destFile)
      
      // 释放资源
      imagePackerApi.release()
      bitmap.release()
      imageSource.release()

      // 返回相对路径（用于存储和加载）
      const relativePath = `${this.MEDIA_DIR}/${fileName}`
      console.info(`[FileUtil] 图片复制成功: ${relativePath}`)
      return relativePath
    } catch (err) {
      const error = err as BusinessError
      console.error(`[FileUtil] 图片复制失败: ${error.code}, ${error.message}`)
      return ''
    }
  }

  /**
   * 将相册视频复制到应用私有目录
   * @param sourceUri 相册 URI（如 file:// 或 datashare://）
   * @returns 复制后的文件路径（相对于 filesDir），失败返回空字符串
   */
  async copyVideoToPrivate(sourceUri: string): Promise<string> {
    if (!this.context) {
      console.error('[FileUtil] 未初始化')
      return ''
    }

    try {
      // 生成唯一文件名
      const timestamp = Date.now()
      const random = Math.floor(Math.random() * 10000)
      const fileName = `video_${timestamp}_${random}.mp4`
      const destPath = `${this.context.filesDir}/${this.MEDIA_DIR}/${fileName}`

      console.info(`[FileUtil] 开始复制视频: ${sourceUri}`)

      // 处理不同URI格式
      if (sourceUri.startsWith('datashare://') || sourceUri.startsWith('content://')) {
        // 相册返回的 datashare 或 content URI，需要通过文件描述符读取
        const sourceFile = fs.openSync(sourceUri, fs.OpenMode.READ_ONLY)
        const destFile = fs.openSync(destPath, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY)
        
        // 分块读取和写入（处理大文件）
        const bufferSize = 1024 * 1024 // 1MB 缓冲区
        let buffer = new ArrayBuffer(bufferSize)
        let readSize = 0
        let totalSize = 0
        
        while (true) {
          readSize = fs.readSync(sourceFile.fd, buffer)
          if (readSize === 0) {
            break
          }
          totalSize += readSize
          
          // 如果读取的数据小于缓冲区大小，只写入实际读取的数据
          if (readSize < bufferSize) {
            const actualData = buffer.slice(0, readSize)
            fs.writeSync(destFile.fd, actualData)
          } else {
            fs.writeSync(destFile.fd, buffer)
          }
        }
        
        fs.closeSync(sourceFile)
        fs.closeSync(destFile)
        
        console.info(`[FileUtil] 视频复制成功，大小: ${(totalSize / 1024 / 1024).toFixed(2)} MB`)
      } else if (sourceUri.startsWith('file://')) {
        // file:// URI，直接复制
        const sourcePath = sourceUri.substring(7)
        fs.copyFile(sourcePath, destPath)
        console.info(`[FileUtil] 视频复制成功 (file://)`)
      } else {
        // 其他格式，尝试直接作为路径处理
        fs.copyFile(sourceUri, destPath)
        console.info(`[FileUtil] 视频复制成功 (直接路径)`)
      }
      
      // 返回相对路径（用于存储和加载）
      const relativePath = `${this.MEDIA_DIR}/${fileName}`
      return relativePath
    } catch (err) {
      const error = err as BusinessError
      console.error(`[FileUtil] 视频复制失败: ${error.code}, ${error.message}`)
      return ''
    }
  }

  /**
   * 获取私有文件的完整路径
   * @param relativePath 相对路径（如 media/img_xxx.jpg）
   * @returns 完整文件路径
   */
  getFullPath(relativePath: string): string {
    if (!this.context) {
      console.error('[FileUtil] 未初始化')
      return ''
    }
    return `${this.context.filesDir}/${relativePath}`
  }

  /**
   * 获取私有文件的 URI（用于 Image 组件）
   * @param relativePath 相对路径（如 media/img_xxx.jpg）
   * @returns file:// URI
   */
  getFileUri(relativePath: string): string {
    if (!this.context) {
      console.error('[FileUtil] 未初始化')
      return ''
    }
    return `file://${this.context.filesDir}/${relativePath}`
  }

  /**
   * 删除私有文件
   * @param relativePath 相对路径
   */
  deleteFile(relativePath: string): boolean {
    if (!this.context) {
      console.error('[FileUtil] 未初始化')
      return false
    }
    try {
      const fullPath = `${this.context.filesDir}/${relativePath}`
      if (fs.accessSync(fullPath)) {
        fs.unlinkSync(fullPath)
        console.info(`[FileUtil] 文件删除成功: ${relativePath}`)
        return true
      }
      return false
    } catch (err) {
      console.error(`[FileUtil] 文件删除失败: ${err}`)
      return false
    }
  }

  /**
   * 检查文件是否存在
   */
  fileExists(relativePath: string): boolean {
    if (!this.context) {
      return false
    }
    try {
      const fullPath = `${this.context.filesDir}/${relativePath}`
      return fs.accessSync(fullPath)
    } catch (err) {
      return false
    }
  }
}

// 导出单例
export const fileUtil = FileUtil.getInstance()
