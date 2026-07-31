/**
 * FrameKeep（帧藏）- 帮助与反馈
 */
import { promptAction } from '@kit.ArkUI';
import { AppConst } from '../../common/Constants';
import { PageShell } from '../../common/components/PageShell';
import { AppColors, AppFontSize, AppSpacing } from '../../common/Styles';

@Entry
@Component
struct HelpFeedback {
  @State feedback: string = ''

  build() {
    Column() {
      PageShell({ title: '帮助与反馈', content: () => { this.body() } })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  body() {
    Column({ space: AppSpacing.LG }) {
      Text(`关于 ${AppConst.APP_NAME}`)
        .fontSize(AppFontSize.SUBTITLE)
        .fontColor(AppColors.TEXT_PRIMARY)
      Text(AppConst.SLOGAN)
        .fontColor(AppColors.TEXT_SECONDARY)
        .fontSize(AppFontSize.BODY_SM)
      Text('收藏影视、直播、生活等一切情绪来源，30 秒轻创作可分享片段。')
        .fontColor(AppColors.TEXT_TERTIARY)
        .fontSize(AppFontSize.BODY_SM)
        .lineHeight(22)

      Divider().color(AppColors.DIVIDER)

      TextArea({ placeholder: '写下你的建议或问题…', text: this.feedback })
        .height(120)
        .backgroundColor(AppColors.SURFACE_BG)
        .fontColor(AppColors.TEXT_PRIMARY)
        .onChange((v: string) => { this.feedback = v })

      Button('提交反馈（Mock）')
        .width('100%')
        .backgroundColor(AppColors.ACCENT_PRIMARY)
        .fontColor(AppColors.PAGE_BG)
        .onClick(() => {
          promptAction.showToast({ message: '感谢反馈！' })
          this.feedback = ''
        })
    }
    .padding(AppSpacing.PAGE_HORIZONTAL)
  }
}
