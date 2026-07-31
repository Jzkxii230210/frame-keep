/**
 * FrameKeep（帧藏）- 创作工作台
 * 三段式布局：顶部引导栏 → 最近作品横滑区 → 素材创作区
 * 支持来源/情绪筛选，紧凑列表式设计。
 */
import { router } from '@kit.ArkUI';
import {
  RouteParams, RoutePath, SOURCE_TYPE_LABEL, EMOTION_TAG_LABEL,
  SourceType, EmotionTag
} from '../../common/Constants';
import { MockDataStore, FrameItem } from '../../common/MockData';
import { AppColors, AppFontSize, AppSpacing } from '../../common/Styles';

/** 生成的卡片作品（模拟数据） */
interface GeneratedCard {
  id: string
  frameId: string
  thumbnailUri: string
  title: string
  createdAt: number
}

@Component
export struct CreateHub {
  @State frameList: FrameItem[] = []
  @State selectedSource: SourceType | undefined = undefined
  @State selectedEmotion: EmotionTag | undefined = undefined
  @State recentCards: GeneratedCard[] = []

  /** 来源筛选 Chip 列表 */
  private sourceFilters: SourceType[] = [
    SourceType.FILM, SourceType.ANIME, SourceType.LIFE, SourceType.OTHER
  ]

  /** 情绪筛选 Chip 列表 */
  private emotionFilters: EmotionTag[] = [
    EmotionTag.HEAL, EmotionTag.BURN, EmotionTag.SAD, EmotionTag.FUNNY
  ]

  aboutToAppear(): void {
    this.loadData()
    this.loadRecentCards()
  }

  private loadData(): void {
    let frames = MockDataStore.getAllFrames()
    
    // 按来源筛选
    if (this.selectedSource !== undefined) {
      frames = frames.filter((item: FrameItem) => item.sourceType === this.selectedSource)
    }
    
    // 按情绪筛选
    if (this.selectedEmotion !== undefined) {
      frames = frames.filter((item: FrameItem) => item.emotion === this.selectedEmotion)
    }
    
    this.frameList = frames
  }

  /** 加载最近生成的卡片（模拟数据） */
  private loadRecentCards(): void {
    // 从收藏的素材中取前 3 个作为"最近生成的卡片"
    const frames = MockDataStore.getAllFrames()
    const cards: GeneratedCard[] = []
    
    for (let i = 0; i < Math.min(3, frames.length); i++) {
      const frame = frames[i]
      const card: GeneratedCard = {
        id: `card_${frame.id}`,
        frameId: frame.id,
        thumbnailUri: frame.screenshotUri,
        title: frame.sourceTitle,
        createdAt: Date.now() - i * 86400000
      }
      cards.push(card)
    }
    
    this.recentCards = cards
  }

  /** 判断是否为 rawfile 路径 */
  private isRawFilePath(uri: string): boolean {
    return uri.length > 0 && !uri.startsWith('file://') && !uri.startsWith('datashare://')
  }

  /** 渲染图片 */
  @Builder
  renderImage(uri: string, width: Length, height: Length) {
    if (this.isRawFilePath(uri)) {
      Image($rawfile(uri))
        .width(width)
        .height(height)
        .borderRadius(8)
        .objectFit(ImageFit.Cover)
    } else {
      Image(uri)
        .width(width)
        .height(height)
        .borderRadius(8)
        .objectFit(ImageFit.Cover)
    }
  }

  build() {
    Column() {
      // ===== 第一区块：顶部引导栏 =====
      Row() {
        Column({ space: 4 }) {
          Text('创作')
            .fontSize(24)
            .fontWeight(FontWeight.Bolder)
            .fontColor(AppColors.TEXT_PRIMARY)
          Text('先去「收藏」导入触动你的截图或录屏吧')
            .fontSize(AppFontSize.CAPTION)
            .fontColor(AppColors.TEXT_TERTIARY)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        // 精致的导入按钮
        Button({ type: ButtonType.Normal }) {
          Row({ space: 4 }) {
            Text('+')
              .fontSize(14)
              .fontColor(AppColors.PAGE_BG)
            Text('导入素材')
              .fontSize(AppFontSize.CAPTION)
              .fontColor(AppColors.PAGE_BG)
          }
        }
        .height(32)
        .backgroundColor(AppColors.ACCENT_PRIMARY)
        .borderRadius(16)
        .padding({ left: 12, right: 12 })
        .onClick(() => {
          router.pushUrl({ url: RoutePath.IMPORT_PAGE })
        })
      }
      .width('100%')
      .padding({
        left: AppSpacing.PAGE_HORIZONTAL,
        right: AppSpacing.PAGE_HORIZONTAL,
        top: AppSpacing.LG,
        bottom: AppSpacing.LG
      })

      // ===== 第二区块：最近作品横滑区 =====
      Column() {
        Row() {
          Text('最近生成')
            .fontSize(AppFontSize.BODY)
            .fontWeight(FontWeight.Medium)
            .fontColor(AppColors.TEXT_PRIMARY)
          Blank()
          Text('查看全部')
            .fontSize(AppFontSize.CAPTION)
            .fontColor(AppColors.ACCENT_PRIMARY)
            .onClick(() => {
              router.pushUrl({ url: RoutePath.CARD_MANAGE })
            })
        }
        .width('100%')
        .margin({ bottom: AppSpacing.SM })

        if (this.recentCards.length > 0) {
          Scroll() {
            Row({ space: AppSpacing.MD }) {
              ForEach(this.recentCards, (card: GeneratedCard) => {
                Column({ space: 4 }) {
                  // 卡片缩略图
                  if (card.thumbnailUri && card.thumbnailUri.length > 0) {
                    this.renderImage(card.thumbnailUri, 100, 130)
                  } else {
                    Column()
                      .width(100)
                      .height(130)
                      .backgroundColor(AppColors.SURFACE_BG)
                      .borderRadius(8)
                  }
                  Text(card.title)
                    .fontSize(10)
                    .fontColor(AppColors.TEXT_SECONDARY)
                    .maxLines(1)
                    .width(100)
                }
                .onClick(() => {
                  router.pushUrl({
                    url: RoutePath.CARD_EDIT,
                    params: { frameId: card.frameId }
                  })
                })
              }, (card: GeneratedCard) => card.id)
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width('100%')
        } else {
          // 空状态
          Row() {
            Column() {
              Text('🖼️')
                .fontSize(32)
              Text('暂无作品，去制作第一张吧')
                .fontSize(AppFontSize.CAPTION)
                .fontColor(AppColors.TEXT_TERTIARY)
                .margin({ top: 8 })
            }
            .width('100%')
            .height(130)
            .justifyContent(FlexAlign.Center)
          }
          .width('100%')
          .backgroundColor(AppColors.SURFACE_BG)
          .borderRadius(8)
        }
      }
      .width('100%')
      .padding({
        left: AppSpacing.PAGE_HORIZONTAL,
        right: AppSpacing.PAGE_HORIZONTAL,
        bottom: AppSpacing.LG
      })

      // ===== 第三区块：素材创作区 =====
      Column() {
        // 筛选标签
        Row({ space: AppSpacing.SM }) {
          Text('来源：')
            .fontSize(AppFontSize.BODY_SM)
            .fontColor(AppColors.TEXT_SECONDARY)
          ForEach(this.sourceFilters, (type: SourceType) => {
            Text(SOURCE_TYPE_LABEL[type])
              .fontSize(AppFontSize.CAPTION)
              .fontColor(this.selectedSource === type ? AppColors.ACCENT_PRIMARY : AppColors.TEXT_SECONDARY)
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .backgroundColor(this.selectedSource === type ? AppColors.SURFACE_BG : AppColors.PAGE_BG)
              .borderRadius(12)
              .onClick(() => {
                this.selectedSource = this.selectedSource === type ? undefined : type
                this.loadData()
              })
          }, (type: SourceType) => type)
        }
        .width('100%')

        Row({ space: AppSpacing.SM }) {
          Text('情绪：')
            .fontSize(AppFontSize.BODY_SM)
            .fontColor(AppColors.TEXT_SECONDARY)
          ForEach(this.emotionFilters, (tag: EmotionTag) => {
            Text(EMOTION_TAG_LABEL[tag])
              .fontSize(AppFontSize.CAPTION)
              .fontColor(this.selectedEmotion === tag ? AppColors.ACCENT_PRIMARY : AppColors.TEXT_SECONDARY)
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .backgroundColor(this.selectedEmotion === tag ? AppColors.SURFACE_BG : AppColors.PAGE_BG)
              .borderRadius(12)
              .onClick(() => {
                this.selectedEmotion = this.selectedEmotion === tag ? undefined : tag
                this.loadData()
              })
          }, (tag: EmotionTag) => tag)
        }
        .width('100%')
        .margin({ top: AppSpacing.SM })

        // 素材列表
        if (this.frameList.length === 0) {
          Column() {
            Text('📦')
              .fontSize(48)
            Text('暂无素材')
              .fontSize(AppFontSize.BODY)
              .fontColor(AppColors.TEXT_SECONDARY)
              .margin({ top: AppSpacing.SM })
            Text('先去「收藏」导入一些截图吧')
              .fontSize(AppFontSize.CAPTION)
              .fontColor(AppColors.TEXT_TERTIARY)
              .margin({ top: 4 })
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          List({ space: AppSpacing.MD }) {
            ForEach(this.frameList, (item: FrameItem) => {
              ListItem() {
                this.compactFrameCard(item)
              }
            }, (item: FrameItem) => item.id)
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
      }
      .width('100%')
      .layoutWeight(1)
      .padding({
        left: AppSpacing.PAGE_HORIZONTAL,
        right: AppSpacing.PAGE_HORIZONTAL,
        top: AppSpacing.SM
      })
      .backgroundColor(AppColors.SURFACE_BG)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppColors.PAGE_BG)
  }

  /** 紧凑列表式卡片 */
  @Builder
  compactFrameCard(item: FrameItem) {
    Row({ space: AppSpacing.MD }) {
      // 左侧：缩略图
      if (item.screenshotUri && item.screenshotUri.length > 0) {
        this.renderImage(item.screenshotUri, 60, 60)
      } else {
        Column()
          .width(60)
          .height(60)
          .backgroundColor(AppColors.BADGE_BG)
          .borderRadius(8)
      }

      // 中间：作品名称 + 分类标签
      Column({ space: 4 }) {
        Text(item.sourceTitle)
          .fontSize(AppFontSize.BODY)
          .fontColor(AppColors.TEXT_PRIMARY)
          .fontWeight(FontWeight.Medium)
          .maxLines(1)

        Row({ space: 4 }) {
          Text(SOURCE_TYPE_LABEL[item.sourceType])
            .fontSize(10)
            .fontColor(AppColors.TEXT_TERTIARY)
          Text('·')
            .fontSize(10)
            .fontColor(AppColors.TEXT_TERTIARY)
          Text(EMOTION_TAG_LABEL[item.emotion])
            .fontSize(10)
            .fontColor(AppColors.TEXT_TERTIARY)
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 右侧：迷你胶囊按钮
      Button('做卡片')
        .fontSize(AppFontSize.CAPTION)
        .height(28)
        .backgroundColor(AppColors.ACCENT_PRIMARY)
        .fontColor(AppColors.PAGE_BG)
        .borderRadius(14)
        .padding({ left: 12, right: 12 })
        .onClick(() => {
          router.pushUrl({ url: RoutePath.TEMPLATE_SELECT, params: { frameId: item.id } })
        })
    }
    .width('100%')
    .padding(AppSpacing.MD)
    .backgroundColor(AppColors.PAGE_BG)
    .borderRadius(12)
  }
}
