/**
 * FrameKeep（帧藏）- 子页面统一壳层
 * 提供深色顶栏、标题与返回按钮，供 router 跳转的子页复用。
 */
import { router } from '@kit.ArkUI';
import { AppColors, AppFontSize, AppSpacing, PAGE_HEADER_HEIGHT } from '../Styles';

@Component
export struct PageShell {
  /** 顶栏标题 */
  @Prop title: string = ''
  /** 是否显示返回按钮 */
  @Prop showBack: boolean = true
  @BuilderParam content: () => void = this.defaultContent

  @Builder
  defaultContent() {
  }

  build() {
    Column() {
      // 顶栏
      Row() {
        if (this.showBack) {
          Row() {
            SymbolGlyph($r('sys.symbol.chevron_left'))
              .fontSize(20)
              .fontColor([AppColors.TEXT_PRIMARY])
            Text($r('app.string.btn_back'))
              .fontSize(AppFontSize.BODY_SM)
              .fontColor(AppColors.TEXT_PRIMARY)
              .margin({ left: 4 })
          }
          .onClick(() => {
            router.back();
          })
        } else {
          Row().width(60)
        }

        Text(this.title)
          .fontSize(AppFontSize.SUBTITLE)
          .fontWeight(FontWeight.Medium)
          .fontColor(AppColors.TEXT_PRIMARY)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Row().width(60)
      }
      .width('100%')
      .height(PAGE_HEADER_HEIGHT)
      .padding({ left: AppSpacing.PAGE_HORIZONTAL, right: AppSpacing.PAGE_HORIZONTAL })
      .backgroundColor(AppColors.PAGE_BG)

      Divider().color(AppColors.DIVIDER).strokeWidth(0.5)

      // 页面主体
      Column() {
        this.content()
      }
      .layoutWeight(1)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppColors.PAGE_BG)
  }
}
