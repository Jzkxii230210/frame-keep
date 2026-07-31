/**
 * FrameKeep（帧藏）- 素材导入页
 * 三步流：选择来源类型 → 从相册选择媒体 → 填写元信息
 */
import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { PageShell } from '../../common/components/PageShell';
import { RoutePath, SOURCE_TYPE_LABEL, SourceType } from '../../common/Constants';
import { MockDataStore } from '../../common/MockData';
import { AppColors, AppFontSize, AppSpacing } from '../../common/Styles';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileUtil } from '../../common/utils/FileUtil';

@Entry
@Component
struct ImportPage {
  @State step: number = 1
  @State selectedSource: SourceType = SourceType.LIFE
  @State sourceTitle: string = ''
  @State momentText: string = ''
  @State selectedUri: string = '' // 选择的媒体文件URI
  @State isVideo: boolean = false // 是否为视频

  private sourceOptions: SourceType[] = [
    SourceType.FILM, SourceType.ANIME, SourceType.LIFE, SourceType.OTHER
  ]

  build() {
    Column() {
      PageShell({ title: '导入情绪帧', content: () => { this.pageBody() } })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  pageBody() {
    Column({ space: AppSpacing.LG }) {
      // 步骤指示
      Row({ space: AppSpacing.SM }) {
        ForEach([1, 2, 3], (s: number) => {
          Text(`步骤${s}`)
            .fontSize(AppFontSize.CAPTION)
            .fontColor(this.step >= s ? AppColors.ACCENT_PRIMARY : AppColors.TEXT_TERTIARY)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
        }, (s: number) => s.toString())
      }
      .width('100%')
      .padding({ top: AppSpacing.LG })

      if (this.step === 1) {
        this.stepSource()
      } else if (this.step === 2) {
        this.stepPickMedia()
      } else {
        this.stepMeta()
      }
    }
    .width('100%')
    .padding({ left: AppSpacing.PAGE_HORIZONTAL, right: AppSpacing.PAGE_HORIZONTAL })
  }

  @Builder
  stepSource() {
    Column({ space: AppSpacing.MD }) {
      Text('情绪从哪来？')
        .fontSize(AppFontSize.TITLE)
        .fontColor(AppColors.TEXT_PRIMARY)
      ForEach(this.sourceOptions, (src: SourceType) => {
        Row() {
          Text(SOURCE_TYPE_LABEL[src])
            .fontSize(AppFontSize.BODY)
            .fontColor(this.selectedSource === src ? AppColors.ACCENT_PRIMARY : AppColors.TEXT_PRIMARY)
          Blank()
          if (this.selectedSource === src) {
            SymbolGlyph($r('sys.symbol.checkmark'))
              .fontSize(18)
              .fontColor([AppColors.ACCENT_PRIMARY])
          }
        }
        .width('100%')
        .padding(AppSpacing.MD)
        .backgroundColor(AppColors.SURFACE_BG)
        .borderRadius(12)
        .onClick(() => { this.selectedSource = src })
      }, (src: SourceType) => src)

      Button('下一步')
        .width('100%')
        .backgroundColor(AppColors.ACCENT_PRIMARY)
        .fontColor(AppColors.PAGE_BG)
        .onClick(() => { 
          this.step = 2
          this.pickMedia()
        })
    }
  }

  @Builder
  stepPickMedia() {
    Column({ space: AppSpacing.MD }) {
      Text('选择媒体文件')
        .fontSize(AppFontSize.TITLE)
        .fontColor(AppColors.TEXT_PRIMARY)
      
      // 显示已选择的媒体
      if (this.selectedUri.length > 0) {
        Column({ space: AppSpacing.SM }) {
          if (this.isVideo) {
            Row({ space: AppSpacing.SM }) {
              SymbolGlyph($r('sys.symbol.video'))
                .fontSize(32)
                .fontColor([AppColors.ACCENT_PRIMARY])
              Text('已选择视频')
                .fontSize(AppFontSize.BODY)
                .fontColor(AppColors.TEXT_PRIMARY)
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
          } else {
            Image(this.selectedUri)
              .width('100%')
              .height(200)
              .objectFit(ImageFit.Cover)
              .borderRadius(8)
          }
        }
        .width('100%')
        
        Row({ space: AppSpacing.MD }) {
          Button('重新选择')
            .layoutWeight(1)
            .backgroundColor(AppColors.SURFACE_BG)
            .fontColor(AppColors.TEXT_PRIMARY)
            .onClick(() => { this.pickMedia() })
          
          Button('下一步')
            .layoutWeight(1)
            .backgroundColor(AppColors.ACCENT_PRIMARY)
            .fontColor(AppColors.PAGE_BG)
            .onClick(() => { this.step = 3 })
        }
        .width('100%')
      } else {
        // 未选择时显示提示
        Column({ space: AppSpacing.MD }) {
          Text('请从相册选择图片或视频')
            .fontSize(AppFontSize.BODY)
            .fontColor(AppColors.TEXT_SECONDARY)
          
          Button('打开相册')
            .width('100%')
            .backgroundColor(AppColors.ACCENT_PRIMARY)
            .fontColor(AppColors.PAGE_BG)
            .onClick(() => { this.pickMedia() })
        }
        .width('100%')
        .padding(AppSpacing.XL)
      }
    }
  }

  // 从相册选择媒体文件（图片或视频）
  private async pickMedia(): Promise<void> {
    try {
      const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions()
      // 同时支持图片和视频
      photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_VIDEO_TYPE
      photoSelectOptions.maxSelectNumber = 1
      
      const photoPicker = new photoAccessHelper.PhotoViewPicker()
      const photoSelectResult = await photoPicker.select(photoSelectOptions)
      
      if (photoSelectResult.photoUris && photoSelectResult.photoUris.length > 0) {
        this.selectedUri = photoSelectResult.photoUris[0]
        
        // 更可靠的视频判断：检查 URI 或使用 PhotoSelectResult 的类型信息
        // HarmonyOS 相册返回的 URI 可能不包含扩展名，需要检查其他信息
        const uriLower = this.selectedUri.toLowerCase()
        this.isVideo = uriLower.includes('.mp4') || 
                       uriLower.includes('.mov') ||
                       uriLower.includes('.3gp') ||
                       uriLower.includes('.mkv') ||
                       uriLower.includes('.avi') ||
                       // 如果 URI 中没有扩展名，检查是否包含 video 关键字
                       uriLower.includes('video')
        
        console.info(`[ImportPage] 选择文件: ${this.selectedUri}, 是否视频: ${this.isVideo}`)
        promptAction.showToast({ message: this.isVideo ? '已选择视频' : '已选择图片' })
      }
    } catch (err) {
      const error = err as BusinessError
      console.error(`PhotoViewPicker select failed, code: ${error.code}, message: ${error.message}`)
      promptAction.showToast({ message: '选择取消或失败' })
    }
  }

  @Builder
  stepMeta() {
    Column({ space: AppSpacing.MD }) {
      Text('补充信息')
        .fontSize(AppFontSize.TITLE)
        .fontColor(AppColors.TEXT_PRIMARY)
      TextInput({ placeholder: '来源名称（剧名/直播间/地点）', text: this.sourceTitle })
        .onChange((v: string) => { this.sourceTitle = v })
        .backgroundColor(AppColors.SURFACE_BG)
        .fontColor(AppColors.TEXT_PRIMARY)
      TextInput({ placeholder: '情绪文字（台词/弹幕/心情，可留空）', text: this.momentText })
        .onChange((v: string) => { this.momentText = v })
        .backgroundColor(AppColors.SURFACE_BG)
        .fontColor(AppColors.TEXT_PRIMARY)
      Button('完成导入')
        .width('100%')
        .backgroundColor(AppColors.ACCENT_PRIMARY)
        .fontColor(AppColors.PAGE_BG)
        .onClick(async () => {
          const title = this.sourceTitle.trim().length > 0 ? this.sourceTitle : SOURCE_TYPE_LABEL[this.selectedSource]
          const frame = MockDataStore.createEmptyFrame(this.selectedSource, title, this.momentText)
          
          // 处理选择的媒体文件
          if (this.selectedUri.length > 0) {
            let copiedPath = ''
            
            // 根据文件类型调用不同的复制方法
            if (this.isVideo) {
              copiedPath = await fileUtil.copyVideoToPrivate(this.selectedUri)
            } else {
              copiedPath = await fileUtil.copyImageToPrivate(this.selectedUri)
            }
            
            if (copiedPath.length > 0) {
              // 使用复制后的路径（file:// URI）
              const fileUri = fileUtil.getFileUri(copiedPath)
              if (this.isVideo) {
                frame.videoUri = fileUri
                frame.clipEndMs = 30000
              } else {
                frame.screenshotUri = fileUri
              }
              MockDataStore.updateFrame(frame)
              promptAction.showToast({ message: '已收藏到情绪帧' })
              router.back()
            } else {
              // 复制失败，仍使用原 URI（可能重启后无法访问）
              if (this.isVideo) {
                frame.videoUri = this.selectedUri
                frame.clipEndMs = 30000
              } else {
                frame.screenshotUri = this.selectedUri
              }
              MockDataStore.updateFrame(frame)
              promptAction.showToast({ message: '已收藏（文件可能无法持久保存）' })
              router.back()
            }
          } else {
            promptAction.showToast({ message: '已收藏到情绪帧' })
            router.back()
          }
        })
    }
  }
}
