/**
 * FrameKeep（帧藏）- 我的模板
 */
import { router } from '@kit.ArkUI';
import { RoutePath, RouteParams } from '../../common/Constants';
import { PageShell } from '../../common/components/PageShell';
import { AppColors, AppFontSize, AppSpacing } from '../../common/Styles';
import { FrameItem, MockDataStore } from '../../common/MockData';

@Entry
@Component
struct MyTemplate {
  @State frameList: FrameItem[] = []
  private templates: string[] = ['治愈留白', '电影字幕', '心情日记']

  aboutToAppear(): void {
    this.frameList = MockDataStore.getAllFrames(true)
  }

  build() {
    Column() {
      PageShell({ title: '我的模板', content: () => { this.body() } })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  body() {
    if (this.frameList.length === 0) {
      Column() {
        Text('暂无收藏的情绪帧')
          .fontColor(AppColors.TEXT_SECONDARY)
          .fontSize(AppFontSize.BODY)
        Text('请先在收藏页添加情绪帧')
          .fontColor(AppColors.TEXT_TERTIARY)
          .fontSize(AppFontSize.CAPTION)
          .margin({ top: AppSpacing.SM })
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else {
      Column({ space: AppSpacing.LG }) {
        // 提示文字
        Text('选择情绪帧应用模板')
          .fontColor(AppColors.TEXT_SECONDARY)
          .fontSize(AppFontSize.BODY_SM)
          .width('100%')

        // 情绪帧列表
        List({ space: AppSpacing.LIST_ITEM_GAP }) {
          ForEach(this.frameList, (frame: FrameItem) => {
            ListItem() {
              this.frameItem(frame)
            }
          }, (frame: FrameItem) => frame.id)
        }
        .layoutWeight(1)
      }
      .padding(AppSpacing.PAGE_HORIZONTAL)
    }
  }

  @Builder
  frameItem(frame: FrameItem) {
    Column({ space: AppSpacing.SM }) {
      Row({ space: AppSpacing.MD }) {
        // 缩略图
        if (frame.screenshotUri.length > 0) {
          if (this.isRawFilePath(frame.screenshotUri)) {
            Image($rawfile(frame.screenshotUri))
              .width(60)
              .height(60)
              .borderRadius(8)
              .objectFit(ImageFit.Cover)
          } else {
            Image(frame.screenshotUri)
              .width(60)
              .height(60)
              .borderRadius(8)
              .objectFit(ImageFit.Cover)
          }
        } else {
          Column()
            .width(60)
            .height(60)
            .borderRadius(8)
            .backgroundColor(AppColors.BADGE_BG)
        }

        Column({ space: 4 }) {
          Text(frame.sourceTitle)
            .fontColor(AppColors.TEXT_PRIMARY)
            .fontSize(AppFontSize.BODY)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          if (frame.momentText.length > 0) {
            Text(frame.momentText)
              .fontColor(AppColors.TEXT_SECONDARY)
              .fontSize(AppFontSize.CAPTION)
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')

      // 模板快捷按钮
      Row({ space: AppSpacing.SM }) {
        ForEach(this.templates, (name: string) => {
          Button(name)
            .fontSize(AppFontSize.CAPTION)
            .height(28)
            .layoutWeight(1)
            .backgroundColor(AppColors.SURFACE_BG)
            .fontColor(AppColors.ACCENT_PRIMARY)
            .onClick(() => {
              router.pushUrl({
                url: RoutePath.TEMPLATE_SELECT,
                params: { frameId: frame.id }
              })
            })
        }, (name: string) => name)
      }
      .width('100%')
    }
    .width('100%')
    .padding(AppSpacing.MD)
    .backgroundColor(AppColors.SURFACE_BG)
    .borderRadius(12)
  }

  /** 判断是否为 rawfile 路径 */
  private isRawFilePath(uri: string): boolean {
    return uri.length > 0 && !uri.startsWith('file://') && !uri.startsWith('datashare://')
  }
}
