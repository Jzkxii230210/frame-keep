/**
 * FrameKeep（帧藏）- 媒体导出工具类
 * 
 * 提供将图片/视频保存到系统相册的能力
 * 使用 SaveButton 安全控件，无需申请受限权限
 */
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { image } from '@kit.ImageKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

/** 导出结果 */
export interface ExportResult {
  success: boolean
  uri?: string
  error?: string
}

/** 导出进度回调 */
export type ExportProgressCallback = (progress: number, message: string) => void

/**
 * 媒体导出工具类
 */
export class MediaExportUtil {
  /**
   * 将 PixelMap 保存到相册
   * 需要在 SaveButton 的 onClick 回调中调用
   * 
   * @param context UI上下文
   * @param pixelMap 图片像素数据
   * @param format 图片格式，默认 jpeg
   * @param quality 图片质量，0-100
   * @returns 导出结果
   */
  static async savePixelMapToGallery(
    context: common.UIAbilityContext,
    pixelMap: image.PixelMap,
    format: string = 'jpeg',
    quality: number = 95
  ): Promise<ExportResult> {
    try {
      const helper = photoAccessHelper.getPhotoAccessHelper(context)
      
      // 创建图片资源
      const uri = await helper.createAsset(photoAccessHelper.PhotoType.IMAGE, format)
      
      // 打开文件
      const file = await fs.open(uri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
      
      // 创建图片打包器
      const imagePacker = image.createImagePacker()
      const packOpts: image.PackingOption = {
        format: `image/${format}`,
        quality: quality
      }
      
      // 打包并写入文件
      await imagePacker.packToFile(pixelMap, file.fd, packOpts)
      
      // 释放资源
      imagePacker.release()
      fs.close(file.fd)
      
      return { success: true, uri }
    } catch (error) {
      const err = error as BusinessError
      return { success: false, error: `保存失败: ${err.message}` }
    }
  }

  /**
   * 将 ArrayBuffer 保存为图片到相册
   * 
   * @param context UI上下文
   * @param buffer 图片数据
   * @param format 图片格式
   * @returns 导出结果
   */
  static async saveBufferToGallery(
    context: common.UIAbilityContext,
    buffer: ArrayBuffer,
    format: string = 'jpeg'
  ): Promise<ExportResult> {
    try {
      const helper = photoAccessHelper.getPhotoAccessHelper(context)
      
      // 创建图片资源
      const uri = await helper.createAsset(photoAccessHelper.PhotoType.IMAGE, format)
      
      // 打开文件
      const file = await fs.open(uri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
      
      // 写入数据
      await fs.write(file.fd, buffer)
      fs.close(file.fd)
      
      return { success: true, uri }
    } catch (error) {
      const err = error as BusinessError
      return { success: false, error: `保存失败: ${err.message}` }
    }
  }

  /**
   * 将视频文件保存到相册
   * 
   * @param context UI上下文
   * @param videoPath 视频文件路径（沙箱路径）
   * @param format 视频格式，默认 mp4
   * @returns 导出结果
   */
  static async saveVideoToGallery(
    context: common.UIAbilityContext,
    videoPath: string,
    format: string = 'mp4'
  ): Promise<ExportResult> {
    try {
      const helper = photoAccessHelper.getPhotoAccessHelper(context)
      
      // 创建视频资源
      const uri = await helper.createAsset(photoAccessHelper.PhotoType.VIDEO, format)
      
      // 读取源视频文件
      const sourceFile = fs.openSync(videoPath, fs.OpenMode.READ_ONLY)
      const stat = fs.statSync(videoPath)
      const buffer = new ArrayBuffer(stat.size)
      fs.readSync(sourceFile.fd, buffer)
      fs.closeSync(sourceFile)
      
      // 写入目标文件
      const targetFile = await fs.open(uri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
      await fs.write(targetFile.fd, buffer)
      fs.close(targetFile.fd)
      
      return { success: true, uri }
    } catch (error) {
      const err = error as BusinessError
      return { success: false, error: `保存失败: ${err.message}` }
    }
  }

  /**
   * 从文件路径创建 PixelMap
   * 
   * @param filePath 图片文件路径
   * @returns PixelMap
   */
  static async createPixelMapFromFile(filePath: string): Promise<image.PixelMap | null> {
    try {
      const imageSource = image.createImageSource(filePath)
      const pixelMap = await imageSource.createPixelMap()
      return pixelMap
    } catch (error) {
      return null
    }
  }

  /**
   * 从 ArrayBuffer 创建 PixelMap
   * 
   * @param buffer 图片数据
   * @returns PixelMap
   */
  static async createPixelMapFromBuffer(buffer: ArrayBuffer): Promise<image.PixelMap | null> {
    try {
      const imageSource = image.createImageSource(buffer)
      const pixelMap = await imageSource.createPixelMap()
      return pixelMap
    } catch (error) {
      return null
    }
  }
}
