/**
 * FrameKeep（帧藏）- 标签管理页
 */
import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { PageShell } from '../../common/components/PageShell';
import { RouteParams } from '../../common/Constants';
import { FrameItem, MockDataStore } from '../../common/MockData';
import { AppColors, AppFontSize, AppSpacing } from '../../common/Styles';

@Entry
@Component
struct TagManage {
  @State tags: string[] = []
  @State newTag: string = ''
  private frameId: string = ''
  private frame: FrameItem | undefined = undefined

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, string>
    this.frameId = params[RouteParams.FRAME_ID] ?? ''
    this.frame = MockDataStore.getFrameById(this.frameId)
    this.tags = this.frame ? [...this.frame.tags] : []
  }

  private saveTags(): void {
    if (this.frame) {
      this.frame.tags = [...this.tags]
      MockDataStore.updateFrame(this.frame)
    }
  }

  build() {
    Column() {
      PageShell({ title: '标签管理', content: () => { this.pageBody() } })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  pageBody() {
    Column({ space: AppSpacing.LG }) {
      Row({ space: AppSpacing.SM }) {
        TextInput({ placeholder: '输入新标签', text: this.newTag })
          .layoutWeight(1)
          .backgroundColor(AppColors.SURFACE_BG)
          .fontColor(AppColors.TEXT_PRIMARY)
          .onChange((v: string) => { this.newTag = v })
        Button('添加')
          .backgroundColor(AppColors.ACCENT_PRIMARY)
          .fontColor(AppColors.PAGE_BG)
          .onClick(() => {
            if (this.newTag.trim().length > 0) {
              this.tags.push(this.newTag.trim())
              this.newTag = ''
              this.saveTags()
              promptAction.showToast({ message: '标签已添加' })
            }
          })
      }
      .width('100%')

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.tags, (tag: string, index: number) => {
          Text(`${tag} ×`)
            .fontSize(AppFontSize.BODY_SM)
            .fontColor(AppColors.TEXT_PRIMARY)
            .backgroundColor(AppColors.SURFACE_BG)
            .padding({ left: 12, right: 12, top: 8, bottom: 8 })
            .borderRadius(16)
            .margin({ right: 8, bottom: 8 })
            .onClick(() => {
              this.tags.splice(index, 1)
              this.tags = [...this.tags]
              this.saveTags()
            })
        }, (tag: string, index: number) => `${tag}_${index}`)
      }
    }
    .padding(AppSpacing.PAGE_HORIZONTAL)
  }
}
