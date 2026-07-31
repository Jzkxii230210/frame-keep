/**
 * FrameKeep（帧藏）- 作品管理页面
 * 展示所有生成的卡片作品
 */
import { router } from '@kit.ArkUI';
import { RouteParams, RoutePath } from '../../common/Constants';
import { MockDataStore, FrameItem } from '../../common/MockData';
import { AppColors, AppFontSize, AppSpacing } from '../../common/Styles';

/** 生成的卡片作品 */
interface GeneratedCard {
  id: string
  frameId: string
  thumbnailUri: string
  title: string
  createdAt: number
}

@Entry
@Component
struct CardManage {
  @State cardList: GeneratedCard[] = []
  @State isLoading: boolean = true

  aboutToAppear(): void {
    this.loadCards()
  }

  /** 加载所有卡片作品 */
  private loadCards(): void {
    const frames = MockDataStore.getAllFrames()
    const cards: GeneratedCard[] = []
    
    for (let i = 0; i < frames.length; i++) {
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
    
    this.cardList = cards
    this.isLoading = false
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
        .objectFit(ImageFit.Cover)
    } else {
      Image(uri)
        .width(width)
        .height(height)
        .objectFit(ImageFit.Cover)
    }
  }

  build() {
    Column() {
      // 顶栏
      Row() {
        Text('<')
          .fontSize(20)
          .fontColor(AppColors.TEXT_PRIMARY)
          .onClick(() => {
            router.back()
          })
        
        Text('我的作品')
          .fontSize(AppFontSize.HEADLINE)
          .fontWeight(FontWeight.Medium)
          .fontColor(AppColors.TEXT_PRIMARY)
          .margin({ left: AppSpacing.MD })
        
        Blank()
      }
      .width('100%')
      .height(56)
      .padding({ left: AppSpacing.PAGE_HORIZONTAL, right: AppSpacing.PAGE_HORIZONTAL })
      
      // 内容区
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color(AppColors.ACCENT_PRIMARY)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else if (this.cardList.length === 0) {
        Column() {
          Text('暂无作品')
            .fontSize(AppFontSize.BODY)
            .fontColor(AppColors.TEXT_SECONDARY)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        // 网格布局
        Grid() {
          ForEach(this.cardList, (card: GeneratedCard) => {
            GridItem() {
              Column() {
                // 卡片封面
                this.renderImage(card.thumbnailUri, '100%', 120)
                
                // 标题
                Text(card.title)
                  .fontSize(AppFontSize.CAPTION)
                  .fontColor(AppColors.TEXT_PRIMARY)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .margin({ top: AppSpacing.SM })
              }
              .width('100%')
              .onClick(() => {
                // 跳转到卡片编辑页面
                router.pushUrl({ url: RoutePath.CARD_EDIT, params: { frameId: card.frameId } })
              })
            }
          }, (card: GeneratedCard) => card.id)
        }
        .columnsTemplate('1fr 1fr 1fr')
        .rowsGap(AppSpacing.MD)
        .columnsGap(AppSpacing.MD)
        .width('100%')
        .layoutWeight(1)
        .padding({ left: AppSpacing.PAGE_HORIZONTAL, right: AppSpacing.PAGE_HORIZONTAL, top: AppSpacing.MD })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppColors.PAGE_BG)
  }
}
