/**
 * FrameKeep（帧藏）- 回收站
 */
import { promptAction } from '@kit.ArkUI';
import { PageShell } from '../../common/components/PageShell';
import { SOURCE_TYPE_LABEL } from '../../common/Constants';
import { MockDataStore, FrameItem } from '../../common/MockData';
import { AppColors, AppFontSize, AppSpacing } from '../../common/Styles';

@Entry
@Component
struct RecycleBin {
  @State list: FrameItem[] = []

  aboutToAppear(): void {
    this.refresh()
  }

  private refresh(): void {
    this.list = MockDataStore.getRecycleBinFrames()
  }

  build() {
    Column() {
      PageShell({ title: '回收站', content: () => { this.pageBody() } })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  pageBody() {
    if (this.list.length === 0) {
      Column() {
        Text('回收站为空')
          .fontColor(AppColors.TEXT_SECONDARY)
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else {
      List({ space: AppSpacing.LIST_ITEM_GAP }) {
        ForEach(this.list, (item: FrameItem) => {
          ListItem() {
            Row() {
              Column({ space: 4 }) {
                Text(item.sourceTitle)
                  .fontColor(AppColors.TEXT_PRIMARY)
                Text(SOURCE_TYPE_LABEL[item.sourceType])
                  .fontSize(AppFontSize.CAPTION)
                  .fontColor(AppColors.TEXT_TERTIARY)
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              Button('恢复')
                .fontSize(AppFontSize.CAPTION)
                .height(32)
                .backgroundColor(AppColors.ACCENT_PRIMARY)
                .fontColor(AppColors.PAGE_BG)
                .onClick(() => {
                  MockDataStore.restoreFromRecycleBin(item.id)
                  promptAction.showToast({ message: '已恢复' })
                  this.refresh()
                })
              Button('删除')
                .fontSize(AppFontSize.CAPTION)
                .height(32)
                .backgroundColor(AppColors.SURFACE_BG)
                .fontColor(AppColors.DANGER)
                .margin({ left: 8 })
                .onClick(() => {
                  MockDataStore.deletePermanently(item.id)
                  promptAction.showToast({ message: '已永久删除' })
                  this.refresh()
                })
            }
            .width('100%')
            .padding(AppSpacing.MD)
            .backgroundColor(AppColors.SURFACE_BG)
            .borderRadius(12)
          }
        }, (item: FrameItem) => item.id)
      }
      .padding(AppSpacing.PAGE_HORIZONTAL)
    }
  }
}
