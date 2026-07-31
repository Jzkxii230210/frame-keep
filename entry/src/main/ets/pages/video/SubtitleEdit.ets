/**
 * FrameKeep（帧藏）- 字幕/心情字编辑
 */
import { router } from '@kit.ArkUI';
import { RouteParams, RoutePath } from '../../common/Constants';
import { FrameItem, MockDataStore } from '../../common/MockData';
import { PageShell } from '../../common/components/PageShell';
import { AppColors, AppFontSize, AppSpacing } from '../../common/Styles';

@Entry
@Component
struct SubtitleEdit {
  @State frame: FrameItem | undefined = undefined
  @State subtitle: string = ''
  private frameId: string = ''

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, string>
    this.frameId = params[RouteParams.FRAME_ID] ?? ''
    this.frame = MockDataStore.getFrameById(this.frameId)
    this.subtitle = this.frame?.subtitleText ?? this.frame?.momentText ?? ''
  }

  build() {
    Column() {
      PageShell({ title: '字幕编辑', content: () => { this.body() } })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  body() {
    Column({ space: AppSpacing.LG }) {
      Badge({ count: 0, position: BadgePosition.RightTop, style: { badgeSize: 14, badgeColor: AppColors.ACCENT_PRIMARY } }) {
        Text('自动识别字幕')
          .fontColor(AppColors.TEXT_TERTIARY)
      }
      Text($r('app.string.coming_soon'))
        .fontSize(AppFontSize.CAPTION)
        .fontColor(AppColors.TEXT_TERTIARY)

      TextArea({ text: this.subtitle, placeholder: '编辑字幕或心情字' })
        .height(120)
        .backgroundColor(AppColors.SURFACE_BG)
        .fontColor(AppColors.TEXT_PRIMARY)
        .onChange((v: string) => { this.subtitle = v })

      Button('一键填入收藏台词')
        .width('100%')
        .backgroundColor(AppColors.SURFACE_BG)
        .fontColor(AppColors.ACCENT_PRIMARY)
        .onClick(() => {
          this.subtitle = this.frame?.momentText ?? ''
        })

      Button('下一步：BGM 配置')
        .width('100%')
        .backgroundColor(AppColors.ACCENT_PRIMARY)
        .fontColor(AppColors.PAGE_BG)
        .onClick(() => {
          if (this.frame) {
            this.frame.subtitleText = this.subtitle
            MockDataStore.updateFrame(this.frame)
          }
          router.pushUrl({ url: RoutePath.AUDIO_CONFIG, params: { frameId: this.frameId } })
        })
    }
    .padding(AppSpacing.PAGE_HORIZONTAL)
  }
}
