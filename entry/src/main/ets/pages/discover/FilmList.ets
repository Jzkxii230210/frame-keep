/**
 * FrameKeep（帧藏）- 情绪专题列表（FilmList 文件名保留）
 */
import { router } from '@kit.ArkUI';
import { RouteParams, RoutePath } from '../../common/Constants';
import { EmotionTopic, MockDataStore } from '../../common/MockData';
import { PageShell } from '../../common/components/PageShell';
import { AppColors, AppFontSize, AppSpacing } from '../../common/Styles';

@Entry
@Component
struct FilmList {
  @State topics: EmotionTopic[] = []

  aboutToAppear(): void {
    this.topics = MockDataStore.getEmotionTopics()
  }

  build() {
    Column() {
      PageShell({ title: '情绪专题', content: () => { this.body() } })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  body() {
    List({ space: AppSpacing.LIST_ITEM_GAP }) {
      ForEach(this.topics, (topic: EmotionTopic) => {
        ListItem() {
          Row({ space: AppSpacing.MD }) {
            // 封面：优先显示专题第一帧图片，否则显示颜色块
            if (MockDataStore.getFramesByTopicId(topic.id)[0]?.screenshotUri) {
              Image($rawfile(MockDataStore.getFramesByTopicId(topic.id)[0].screenshotUri))
                .width(72)
                .height(72)
                .borderRadius(8)
                .objectFit(ImageFit.Cover)
            } else {
              Column()
                .width(72)
                .height(72)
                .borderRadius(8)
                .backgroundColor(topic.coverColor)
            }
            Column({ space: 4 }) {
              Text(topic.title).fontColor(AppColors.TEXT_PRIMARY)
              Text(topic.description)
                .fontSize(AppFontSize.CAPTION)
                .fontColor(AppColors.TEXT_TERTIARY)
                .maxLines(2)
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .width('100%')
          .padding(AppSpacing.MD)
          .backgroundColor(AppColors.SURFACE_BG)
          .borderRadius(12)
          .onClick(() => {
            router.pushUrl({
              url: RoutePath.TOPIC_DETAIL,
              params: { topicId: topic.id }
            })
          })
        }
      }, (topic: EmotionTopic) => topic.id)
    }
    .padding(AppSpacing.PAGE_HORIZONTAL)
  }
}
