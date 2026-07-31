/**
 * FrameKeep（帧藏）- 视频片段截取
 */
import { router } from '@kit.ArkUI';
import { ClipDuration, RouteParams, RoutePath } from '../../common/Constants';
import { FrameItem, MockDataStore } from '../../common/MockData';
import { PageShell } from '../../common/components/PageShell';
import { AppColors, AppFontSize, AppSpacing } from '../../common/Styles';

@Entry
@Component
struct VideoClip {
  @State frame: FrameItem | undefined = undefined
  @State clipStart: number = 0
  @State clipEnd: number = 30
  private frameId: string = ''

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, string>
    this.frameId = params[RouteParams.FRAME_ID] ?? ''
    this.frame = MockDataStore.getFrameById(this.frameId)
    if (this.frame) {
      this.clipStart = Math.floor(this.frame.clipStartMs / 1000)
      this.clipEnd = Math.floor(this.frame.clipEndMs / 1000) || 30
    }
  }

  build() {
    Column() {
      PageShell({ title: '片段截取', content: () => { this.body() } })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  body() {
    Column({ space: AppSpacing.LG }) {
      // 视频预览区域
      Column() {
        if (this.frame && this.frame.videoUri.length > 0) {
          Video({
            src: this.frame.videoUri
          })
            .width('100%')
            .height('100%')
            .autoPlay(false)
            .controls(true)
            .objectFit(ImageFit.Cover)
        } else {
          Column({ space: AppSpacing.SM }) {
            Text('▶')
              .fontSize(48)
              .fontColor(AppColors.TEXT_TERTIARY)
            Text('暂无视频')
              .fontSize(AppFontSize.CAPTION)
              .fontColor(AppColors.TEXT_TERTIARY)
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
        }
      }
      .width('100%')
      .height(180)
      .borderRadius(12)
      .backgroundColor(AppColors.BADGE_BG)
      .clip(true)
      
      Text('时间轴预览 · 支持 15–60 秒')
        .fontSize(AppFontSize.CAPTION)
        .fontColor(AppColors.TEXT_TERTIARY)

      Text(`起始：${this.clipStart}s`)
        .fontColor(AppColors.TEXT_SECONDARY)
      Slider({
        value: this.clipStart,
        min: 0,
        max: 120,
        step: 1
      })
        .blockColor(AppColors.ACCENT_PRIMARY)
        .onChange((v: number) => { this.clipStart = v })

      Text(`结束：${this.clipEnd}s（片段 ${this.clipEnd - this.clipStart}s）`)
        .fontColor(AppColors.TEXT_SECONDARY)
      Slider({
        value: this.clipEnd,
        min: 15,
        max: 60,
        step: 1
      })
        .blockColor(AppColors.ACCENT_PRIMARY)
        .onChange((v: number) => { this.clipEnd = v })

      Button('提取当前帧为截图')
        .width('100%')
        .backgroundColor(AppColors.SURFACE_BG)
        .fontColor(AppColors.ACCENT_PRIMARY)
        .onClick(() => {
          if (this.frame) {
            this.frame.screenshotUri = `mock://frame/${this.frame.id}.jpg`
            MockDataStore.updateFrame(this.frame)
          }
        })

      Button('下一步：字幕编辑')
        .width('100%')
        .backgroundColor(AppColors.ACCENT_PRIMARY)
        .fontColor(AppColors.PAGE_BG)
        .onClick(() => {
          if (this.frame) {
            this.frame.clipStartMs = this.clipStart * 1000
            this.frame.clipEndMs = this.clipEnd * 1000
            MockDataStore.updateFrame(this.frame)
          }
          router.pushUrl({ url: RoutePath.SUBTITLE_EDIT, params: { frameId: this.frameId } })
        })
    }
    .padding(AppSpacing.PAGE_HORIZONTAL)
  }
}
