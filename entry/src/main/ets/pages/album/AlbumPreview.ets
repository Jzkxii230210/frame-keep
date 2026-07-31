/**
 * FrameKeep（帧藏）- 合集预览与导出
 * 
 * 支持预览合集中的情绪帧，并导出到系统相册
 */
import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { FrameItem, MockDataStore } from '../../common/MockData';
import { PageShell } from '../../common/components/PageShell';
import { AppColors, AppFontSize, AppSpacing } from '../../common/Styles';
import { MediaExportUtil } from '../../common/utils/MediaExportUtil';

/** 导出格式选项 */
enum ExportFormat {
  IMAGE = 'image',
  VIDEO = 'video'
}

/** 导出格式选项项 */
interface ExportFormatOption {
  value: ExportFormat
  label: string
}

@Entry
@Component
struct AlbumPreview {
  @State frameList: FrameItem[] = []
  @State currentIndex: number = 0
  @State exportFormat: ExportFormat = ExportFormat.IMAGE
  @State isExporting: boolean = false
  @State exportProgress: number = 0
  @State exportMessage: string = ''

  /** 导出格式选项列表 */
  private exportOptions: ExportFormatOption[] = [
    { value: ExportFormat.IMAGE, label: '图片' },
    { value: ExportFormat.VIDEO, label: '视频' }
  ]

  aboutToAppear(): void {
    // 获取路由参数中的合集ID
    const params = router.getParams() as Record<string, Object>
    const albumId = params?.['albumId'] as string
    
    if (albumId && albumId.length > 0) {
      // 根据合集ID获取合集中的帧
      this.frameList = MockDataStore.getFramesByAlbumId(albumId)
    } else {
      // 如果没有传入合集ID，获取所有帧的前3个（兼容旧逻辑）
      this.frameList = MockDataStore.getAllFrames().slice(0, 3)
    }
  }

  /** 渲染图片（支持 rawfile 和普通路径） */
  @Builder
  renderImage(uri: string, width: Length, height: Length, radius: number = 8) {
    if (uri && uri.length > 0) {
      // rawfile 路径需要用 $rawfile() 包装
      if (!uri.startsWith('file://') && !uri.startsWith('datashare://') && !uri.startsWith('mock://')) {
        Image($rawfile(uri))
          .width(width)
          .height(height)
          .objectFit(ImageFit.Cover)
          .borderRadius(radius)
      } else {
        Image(uri)
          .width(width)
          .height(height)
          .objectFit(ImageFit.Cover)
          .borderRadius(radius)
      }
    }
  }

  build() {
    Column() {
      PageShell({ title: '合集预览', content: () => { this.body() } })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  body() {
    Column({ space: AppSpacing.LG }) {
      // 预览区域
      this.previewSection()

      // 导出选项
      this.exportOptionsSection()

      // 导出按钮
      this.exportButtonSection()

      // 导出进度
      if (this.isExporting) {
        this.progressSection()
      }

      // 提示信息
      Text('导出后可在系统相册中查看')
        .fontSize(AppFontSize.CAPTION)
        .fontColor(AppColors.TEXT_TERTIARY)
    }
    .padding(AppSpacing.PAGE_HORIZONTAL)
  }

  /** 预览区域 */
  @Builder
  previewSection() {
    Column({ space: AppSpacing.SM }) {
      Swiper() {
        ForEach(this.frameList, (item: FrameItem, index: number) => {
          Column({ space: AppSpacing.SM }) {
            // 图片预览区域
            Column() {
              if (item.screenshotUri && item.screenshotUri.length > 0) {
                this.renderImage(item.screenshotUri, '100%', '100%', 12)
              } else {
                Column() {
                  Text('暂无图片')
                    .fontSize(AppFontSize.CAPTION)
                    .fontColor(AppColors.TEXT_TERTIARY)
                }
                .width('100%')
                .height('100%')
                .justifyContent(FlexAlign.Center)
              }
            }
            .width('100%')
            .height(200)
            .borderRadius(12)
            .backgroundColor(AppColors.SURFACE_BG)

            // 文字信息
            Column({ space: 4 }) {
              Text(item.sourceTitle)
                .fontColor(AppColors.TEXT_PRIMARY)
                .fontSize(AppFontSize.BODY_SM)
              Text(item.momentText.length > 0 ? item.momentText : '（纯画面）')
                .fontSize(AppFontSize.CAPTION)
                .fontColor(AppColors.TEXT_SECONDARY)
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
          }
          .padding(AppSpacing.MD)
        }, (item: FrameItem) => item.id)
      }
      .height(280)
      .indicator(true)
      .onChange((index: number) => {
        this.currentIndex = index
      })

      // 当前项提示
      Text(`第 ${this.currentIndex + 1} / ${this.frameList.length} 项`)
        .fontSize(AppFontSize.CAPTION)
        .fontColor(AppColors.TEXT_TERTIARY)
    }
  }

  /** 导出选项 */
  @Builder
  exportOptionsSection() {
    Column({ space: AppSpacing.SM }) {
      Text('导出格式')
        .fontSize(AppFontSize.BODY_SM)
        .fontColor(AppColors.TEXT_SECONDARY)
        .width('100%')

      Row({ space: AppSpacing.MD }) {
        ForEach(this.exportOptions, (item: ExportFormatOption) => {
          Text(item.label)
            .fontSize(AppFontSize.BODY_SM)
            .fontColor(this.exportFormat === item.value ? AppColors.PAGE_BG : AppColors.TEXT_SECONDARY)
            .backgroundColor(this.exportFormat === item.value ? AppColors.ACCENT_PRIMARY : AppColors.SURFACE_BG)
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .borderRadius(16)
            .onClick(() => {
              this.exportFormat = item.value
            })
        }, (item: ExportFormatOption) => item.value)
      }
      .width('100%')
    }
    .width('100%')
    .padding(AppSpacing.MD)
    .backgroundColor(AppColors.SURFACE_BG)
    .borderRadius(12)
  }

  /** 导出按钮区域 */
  @Builder
  exportButtonSection() {
    Column({ space: AppSpacing.SM }) {
      // 使用 SaveButton 安全控件导出当前项
      SaveButton()
        .width('100%')
        .onClick(async (event: ClickEvent, result: SaveButtonOnClickResult) => {
          if (result === SaveButtonOnClickResult.SUCCESS) {
            await this.exportCurrentItem()
          } else {
            promptAction.showToast({ message: '授权失败，无法保存到相册' })
          }
        })

      // 批量导出按钮
      Button('导出全部（需授权）')
        .width('100%')
        .backgroundColor(AppColors.SURFACE_BG)
        .fontColor(AppColors.TEXT_PRIMARY)
        .onClick(async () => {
          await this.exportAllItems()
        })
    }
  }

  /** 导出进度 */
  @Builder
  progressSection() {
    Column({ space: AppSpacing.SM }) {
      Progress({ value: this.exportProgress, total: 100, type: ProgressType.Linear })
        .width('100%')
        .color(AppColors.ACCENT_PRIMARY)
      Text(this.exportMessage)
        .fontSize(AppFontSize.CAPTION)
        .fontColor(AppColors.TEXT_SECONDARY)
    }
    .width('100%')
    .padding(AppSpacing.MD)
    .backgroundColor(AppColors.SURFACE_BG)
    .borderRadius(12)
  }

  /** 导出当前项 */
  private async exportCurrentItem(): Promise<void> {
    if (this.frameList.length === 0) {
      promptAction.showToast({ message: '没有可导出的内容' })
      return
    }

    const currentItem = this.frameList[this.currentIndex]
    this.isExporting = true
    this.exportProgress = 0
    this.exportMessage = '正在导出...'

    try {
      const context = getContext(this) as common.UIAbilityContext

      if (this.exportFormat === ExportFormat.IMAGE) {
        // 导出图片
        if (currentItem.screenshotUri && !currentItem.screenshotUri.startsWith('mock://')) {
          // 真实图片路径
          const pixelMap = await MediaExportUtil.createPixelMapFromFile(currentItem.screenshotUri)
          if (pixelMap) {
            const result = await MediaExportUtil.savePixelMapToGallery(context, pixelMap)
            if (result.success) {
              promptAction.showToast({ message: '图片已保存到相册' })
            } else {
              promptAction.showToast({ message: result.error || '保存失败' })
            }
          }
        } else {
          // Mock 数据，生成示例图片
          promptAction.showToast({ message: '示例数据，请先导入真实图片' })
        }
      } else {
        // 导出视频
        if (currentItem.videoUri && !currentItem.videoUri.startsWith('mock://')) {
          const result = await MediaExportUtil.saveVideoToGallery(context, currentItem.videoUri)
          if (result.success) {
            promptAction.showToast({ message: '视频已保存到相册' })
          } else {
            promptAction.showToast({ message: result.error || '保存失败' })
          }
        } else {
          promptAction.showToast({ message: '示例数据，请先导入真实视频' })
        }
      }

      this.exportProgress = 100
      this.exportMessage = '导出完成'
    } catch (error) {
      promptAction.showToast({ message: '导出失败，请重试' })
    } finally {
      setTimeout(() => {
        this.isExporting = false
      }, 1000)
    }
  }

  /** 导出全部项 */
  private async exportAllItems(): Promise<void> {
    if (this.frameList.length === 0) {
      promptAction.showToast({ message: '没有可导出的内容' })
      return
    }

    this.isExporting = true
    this.exportProgress = 0
    this.exportMessage = '准备导出...'

    try {
      const context = getContext(this) as common.UIAbilityContext
      let successCount = 0
      let failCount = 0

      for (let i = 0; i < this.frameList.length; i++) {
        const item = this.frameList[i]
        this.exportProgress = Math.floor((i / this.frameList.length) * 100)
        this.exportMessage = `正在导出第 ${i + 1} 项...`

        // 模拟导出过程
        await new Promise<void>(resolve => setTimeout(resolve, 500))

        // 实际项目中这里应该调用真实的导出逻辑
        if (item.screenshotUri && !item.screenshotUri.startsWith('mock://')) {
          successCount++
        } else {
          failCount++
        }
      }

      this.exportProgress = 100
      this.exportMessage = `导出完成：成功 ${successCount} 项，失败 ${failCount} 项`

      if (failCount === 0) {
        promptAction.showToast({ message: `已导出 ${successCount} 项到相册` })
      } else {
        promptAction.showToast({ message: `部分导出失败，请检查数据` })
      }
    } catch (error) {
      promptAction.showToast({ message: '导出失败，请重试' })
    } finally {
      setTimeout(() => {
        this.isExporting = false
      }, 2000)
    }
  }
}
