/**
 * FrameKeep（帧藏）- BGM 与混音配置
 */
import { router } from '@kit.ArkUI';
import { EMOTION_TAG_LABEL, RouteParams, RoutePath } from '../../common/Constants';
import { BgmItem, FrameItem, MockDataStore } from '../../common/MockData';
import { PageShell } from '../../common/components/PageShell';
import { AppColors, AppFontSize, AppSpacing } from '../../common/Styles';

@Entry
@Component
struct AudioConfig {
  @State frame: FrameItem | undefined = undefined
  @State bgmList: BgmItem[] = []
  @State selectedBgmId: string = ''
  @State mixRatio: number = 50
  private frameId: string = ''

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, string>
    this.frameId = params[RouteParams.FRAME_ID] ?? ''
    this.frame = MockDataStore.getFrameById(this.frameId)
    if (this.frame) {
      this.bgmList = MockDataStore.getBgmByEmotion(this.frame.emotion)
      this.selectedBgmId = this.frame.bgmId
    }
  }

  build() {
    Column() {
      PageShell({ title: 'BGM 搭配', content: () => { this.body() } })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  body() {
    Column({ space: AppSpacing.LG }) {
      if (this.frame) {
        Text(`按情绪「${EMOTION_TAG_LABEL[this.frame.emotion]}」推荐`)
          .fontColor(AppColors.TEXT_SECONDARY)
          .fontSize(AppFontSize.BODY_SM)
      }

      List({ space: AppSpacing.SM }) {
        ForEach(this.bgmList, (bgm: BgmItem) => {
          ListItem() {
            Row() {
              Text(bgm.name)
                .fontColor(this.selectedBgmId === bgm.id ? AppColors.ACCENT_PRIMARY : AppColors.TEXT_PRIMARY)
                .layoutWeight(1)
              if (this.selectedBgmId === bgm.id) {
                SymbolGlyph($r('sys.symbol.checkmark'))
                  .fontColor([AppColors.ACCENT_PRIMARY])
              }
            }
            .width('100%')
            .padding(AppSpacing.MD)
            .backgroundColor(AppColors.SURFACE_BG)
            .borderRadius(8)
            .onClick(() => { this.selectedBgmId = bgm.id })
          }
        }, (bgm: BgmItem) => bgm.id)
      }
      .height(200)

      Text(`原声 / BGM 比例：${this.mixRatio}% BGM`)
        .fontColor(AppColors.TEXT_SECONDARY)
      Slider({ value: this.mixRatio, min: 0, max: 100 })
        .blockColor(AppColors.ACCENT_PRIMARY)
        .onChange((v: number) => { this.mixRatio = v })

      Checkbox({ name: 'keepOriginal', group: 'audio' })
        .select(true)
        .selectedColor(AppColors.ACCENT_PRIMARY)
      Text('保留视频原声')
        .fontColor(AppColors.TEXT_SECONDARY)
        .fontSize(AppFontSize.BODY_SM)

      Button('导入本地音频（Mock）')
        .width('100%')
        .backgroundColor(AppColors.SURFACE_BG)
        .fontColor(AppColors.TEXT_PRIMARY)

      Button('下一步：导出')
        .width('100%')
        .backgroundColor(AppColors.ACCENT_PRIMARY)
        .fontColor(AppColors.PAGE_BG)
        .onClick(() => {
          if (this.frame) {
            this.frame.bgmId = this.selectedBgmId
            MockDataStore.updateFrame(this.frame)
          }
          router.pushUrl({ url: RoutePath.VIDEO_EXPORT, params: { frameId: this.frameId } })
        })
    }
    .padding(AppSpacing.PAGE_HORIZONTAL)
  }
}
