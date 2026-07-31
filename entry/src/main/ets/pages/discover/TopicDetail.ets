/**
 * FrameKeep（帧藏）- 情绪专题详情
 */
import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { EMOTION_TAG_LABEL, RouteParams, SOURCE_TYPE_LABEL } from '../../common/Constants';
import { EmotionTopic, FrameItem, MockDataStore } from '../../common/MockData';
import { PageShell } from '../../common/components/PageShell';
import { AppColors, AppFontSize, AppSpacing } from '../../common/Styles';

@Entry
@Component
struct TopicDetail {
  @State topic: EmotionTopic | undefined = undefined
  @State frames: FrameItem[] = []
  private topicId: string = ''

  async aboutToAppear(): Promise<void> {
    await MockDataStore.init()
    const params = router.getParams() as Record<string, string>
    this.topicId = params[RouteParams.TOPIC_ID] ?? ''
    this.topic = MockDataStore.getTopicById(this.topicId)
    this.frames = MockDataStore.getFramesByTopicId(this.topicId)
  }

  build() {
    Column() {
      PageShell({ title: this.topic?.title ?? '专题', content: () => { this.body() } })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  body() {
    Column({ space: AppSpacing.LG }) {
      if (this.topic) {
        Text(this.topic.description)
          .fontColor(AppColors.TEXT_SECONDARY)
          .fontSize(AppFontSize.BODY_SM)
      }
      List({ space: AppSpacing.LIST_ITEM_GAP }) {
        ForEach(this.frames, (item: FrameItem) => {
          ListItem() {
            Column({ space: AppSpacing.SM }) {
              // 图片显示
              if (item.screenshotUri && item.screenshotUri.length > 0) {
                Image($rawfile(item.screenshotUri))
                  .width('100%')
                  .height(180)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(8)
              }
              Row({ space: AppSpacing.SM }) {
                Text(SOURCE_TYPE_LABEL[item.sourceType])
                  .fontSize(AppFontSize.CAPTION)
                  .fontColor(AppColors.ACCENT_PRIMARY)
                Text(EMOTION_TAG_LABEL[item.emotion])
                  .fontSize(AppFontSize.CAPTION)
                  .fontColor(AppColors.TEXT_TERTIARY)
              }
              Text(item.sourceTitle).fontColor(AppColors.TEXT_PRIMARY)
              Text(item.momentText.length > 0 ? item.momentText : '（纯画面）')
                .fontSize(AppFontSize.BODY_SM)
                .fontColor(AppColors.TEXT_SECONDARY)
                .maxLines(2)
              Button('收藏到我的')
                .height(32)
                .fontSize(AppFontSize.CAPTION)
                .backgroundColor(AppColors.ACCENT_PRIMARY)
                .fontColor(AppColors.PAGE_BG)
                .onClick(() => {
                  // 检查是否已收藏
                  if (MockDataStore.getFrameById(item.id)) {
                    promptAction.showToast({ message: '已在你的收藏中' })
                  } else {
                    // 添加到收藏
                    MockDataStore.addFrame(item)
                    promptAction.showToast({ message: '已添加到收藏' })
                  }
                })
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
            .padding(AppSpacing.MD)
            .backgroundColor(AppColors.SURFACE_BG)
            .borderRadius(12)
          }
        }, (item: FrameItem) => item.id)
      }
    }
    .padding(AppSpacing.PAGE_HORIZONTAL)
  }
}
