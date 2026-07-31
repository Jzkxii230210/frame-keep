/**
 * FrameKeep（帧藏）- 素材详情页（卡片创作枢纽）
 * 展示截图、标签管理、模板预览与一键创作。
 */
import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { PageShell } from '../../common/components/PageShell';
import {
  EMOTION_TAG_LABEL, RouteParams, RoutePath, SOURCE_TYPE_LABEL
} from '../../common/Constants';
import { FrameItem, MockDataStore } from '../../common/MockData';
import { AppColors, AppFontSize, AppSpacing } from '../../common/Styles';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileUtil } from '../../common/utils/FileUtil';

/** 快捷模板定义 */
interface QuickTemplate {
  id: string
  name: string
  bgColor: string
  textColor: string
  category: string
}

@Entry
@Component
struct MaterialDetail {
  @State frame: FrameItem | undefined = undefined
  private frameId: string = ''

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, string>
    this.frameId = params[RouteParams.FRAME_ID] ?? ''
    this.loadFrame()
  }

  private loadFrame(): void {
    this.frame = MockDataStore.getFrameById(this.frameId)
  }

  /** 获取快捷模板列表 */
  private getQuickTemplates(): QuickTemplate[] {
    return [
      { id: 'movie', name: '电影感', bgColor: '#1A1A1A', textColor: '#FFFFFF', category: '简约' },
      { id: 'simple', name: '简约', bgColor: '#F5F5F5', textColor: '#333333', category: '简约' },
      { id: 'ins', name: 'ins风', bgColor: '#FFE4E1', textColor: '#8B4513', category: '治愈' },
      { id: 'danmu', name: '弹幕风', bgColor: '#2F4F4F', textColor: '#00FF00', category: '燃向' }
    ]
  }

  /** 判断是否为 rawfile 路径（相对路径，非相册 URI） */
  private isRawFilePath(uri: string): boolean {
    return uri.length > 0 && !uri.startsWith('file://') && !uri.startsWith('datashare://')
  }

  /** 渲染图片（自动判断 rawfile 或相册 URI） */
  @Builder
  renderImage(uri: string, width: Length, height: Length) {
    if (this.isRawFilePath(uri)) {
      // rawfile 路径
      Image($rawfile(uri))
        .width(width)
        .height(height)
        .borderRadius(8)
        .objectFit(ImageFit.Cover)
    } else {
      // 相册 URI
      Image(uri)
        .width(width)
        .height(height)
        .borderRadius(8)
        .objectFit(ImageFit.Cover)
    }
  }

  /** 分享原图 */
  private async shareImage(): Promise<void> {
    try {
      if (!this.frame || this.frame!.screenshotUri.length === 0) {
        promptAction.showToast({ message: '暂无截图可分享' })
        return
      }
      
      // TODO: 调用系统分享能力
      promptAction.showToast({ message: '分享功能开发中...' })
    } catch (err) {
      const error = err as BusinessError
      console.error(`[MaterialDetail] 分享失败: ${error.code}, ${error.message}`)
      promptAction.showToast({ message: '分享失败' })
    }
  }

  build() {
    Column() {
      PageShell({
        title: '情绪帧详情',
        content: () => { this.pageBody() }
      })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  pageBody() {
    if (this.frame === undefined) {
      Column() {
        Text('未找到该条目')
          .fontColor(AppColors.TEXT_SECONDARY)
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    } else {
      Scroll() {
        Column({ space: AppSpacing.LG }) {
          // 来源与情绪
          Row({ space: AppSpacing.SM }) {
            Text(SOURCE_TYPE_LABEL[this.frame!.sourceType])
              .fontSize(AppFontSize.CAPTION)
              .fontColor(AppColors.ACCENT_PRIMARY)
            Text(EMOTION_TAG_LABEL[this.frame!.emotion])
              .fontSize(AppFontSize.CAPTION)
              .fontColor(AppColors.TEXT_TERTIARY)
          }

          Text(this.frame!.sourceTitle)
            .fontSize(AppFontSize.TITLE)
            .fontColor(AppColors.TEXT_PRIMARY)

          if (this.frame!.momentText.length > 0) {
            Text(this.frame!.momentText)
              .fontSize(AppFontSize.BODY)
              .fontColor(AppColors.TEXT_SECONDARY)
              .lineHeight(24)
          }

          // 截图展示
          if (this.frame!.screenshotUri.length > 0) {
            this.renderImage(this.frame!.screenshotUri, '100%', 200)
          } else {
            Column() {
              Text('📷')
                .fontSize(48)
              Text('暂无截图')
                .fontSize(AppFontSize.CAPTION)
                .fontColor(AppColors.TEXT_TERTIARY)
              Button('补导入截图')
                .fontSize(AppFontSize.CAPTION)
                .height(28)
                .backgroundColor(AppColors.SURFACE_BG)
                .fontColor(AppColors.ACCENT_PRIMARY)
                .margin({ top: AppSpacing.SM })
                .onClick(() => {
                  this.frame!.screenshotUri = `mock://screenshot/${this.frame!.id}`
                  MockDataStore.updateFrame(this.frame!)
                  promptAction.showToast({ message: '已绑定截图' })
                  this.loadFrame()
                })
            }
            .width('100%')
            .height(200)
            .backgroundColor(AppColors.SURFACE_BG)
            .borderRadius(8)
            .justifyContent(FlexAlign.Center)
          }

          // 卡片效果预览区 - 一键套用模板
          Text('一键套用模板')
            .fontSize(AppFontSize.SUBTITLE)
            .fontColor(AppColors.TEXT_PRIMARY)

          Scroll() {
            Row({ space: AppSpacing.MD }) {
              ForEach(this.getQuickTemplates(), (template: QuickTemplate) => {
                Column({ space: 4 }) {
                  // 模板预览缩略图
                  Stack() {
                    // 背景色
                    Column()
                      .width(80)
                      .height(100)
                      .backgroundColor(template.bgColor)
                      .borderRadius(8)

                    // 模拟文字效果
                    Text('台词预览')
                      .fontSize(10)
                      .fontColor(template.textColor)
                      .maxLines(2)
                  }
                  .width(80)
                  .height(100)

                  Text(template.name)
                    .fontSize(10)
                    .fontColor(AppColors.TEXT_SECONDARY)
                }
                .onClick(() => {
                  router.pushUrl({
                    url: RoutePath.CARD_EDIT,
                    params: {
                      frameId: this.frameId,
                      templateId: template.id
                    }
                  })
                })
              }, (template: QuickTemplate) => template.id)
            }
            .padding({ right: AppSpacing.PAGE_HORIZONTAL })
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width('100%')

          // 标签管理
          Row() {
            Text(`标签：${this.frame!.tags.length > 0 ? this.frame!.tags.join(' · ') : '未设置'}`)
              .fontSize(AppFontSize.BODY_SM)
              .fontColor(AppColors.TEXT_SECONDARY)
              .layoutWeight(1)
            Text('管理')
              .fontSize(AppFontSize.BODY_SM)
              .fontColor(AppColors.ACCENT_PRIMARY)
              .onClick(() => {
                router.pushUrl({
                  url: RoutePath.TAG_MANAGE,
                  params: { frameId: this.frameId }
                })
              })
          }
          .width('100%')

          // 加入合集快捷入口
          Row({ space: AppSpacing.SM }) {
            Text('📁')
              .fontSize(16)
            Text('加入合集')
              .fontSize(AppFontSize.BODY)
              .fontColor(AppColors.ACCENT_PRIMARY)
            Blank()
            Text('→')
              .fontSize(16)
              .fontColor(AppColors.TEXT_TERTIARY)
          }
          .width('100%')
          .padding(AppSpacing.MD)
          .backgroundColor(AppColors.SURFACE_BG)
          .borderRadius(12)
          .onClick(() => {
            // TODO: 跳转到合集选择页面
            promptAction.showToast({ message: '合集功能开发中...' })
          })

          // 创作入口 - 强化主按钮
          Button('生成卡片')
            .width('100%')
            .height(50)
            .fontSize(AppFontSize.BODY)
            .backgroundColor(AppColors.ACCENT_PRIMARY)
            .fontColor(AppColors.PAGE_BG)
            .borderRadius(25)
            .onClick(() => {
              router.pushUrl({
                url: RoutePath.TEMPLATE_SELECT,
                params: { frameId: this.frameId }
              })
            })

          Text('支持自定义文字、滤镜、背景')
            .fontSize(AppFontSize.CAPTION)
            .fontColor(AppColors.TEXT_TERTIARY)
            .width('100%')
            .textAlign(TextAlign.Center)

          // 底部操作区
          Row({ space: AppSpacing.MD }) {
            Button('移入回收站')
              .layoutWeight(1)
              .backgroundColor(AppColors.SURFACE_BG)
              .fontColor(AppColors.DANGER)
              .onClick(() => {
                MockDataStore.moveToRecycleBin(this.frameId)
                promptAction.showToast({ message: '已移入回收站' })
                router.back()
              })

            Button('分享原图')
              .layoutWeight(1)
              .backgroundColor(AppColors.SURFACE_BG)
              .fontColor(AppColors.ACCENT_PRIMARY)
              .onClick(() => {
                this.shareImage()
              })
          }
          .width('100%')
        }
        .padding(AppSpacing.PAGE_HORIZONTAL)
      }
      .layoutWeight(1)
    }
  }
}
