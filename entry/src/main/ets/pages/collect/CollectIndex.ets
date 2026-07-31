/**
 * FrameKeep（帧藏）- 收藏 Tab 首页
 * 情绪帧列表、来源/情绪筛选、搜索，跳转导入与详情。
 * 支持多选模式，批量打标签、删除、加入合集。
 * 支持视图切换（列表、网格）。
 */
import { router } from '@kit.ArkUI';
import {
  EmotionTag, RouteParams, RoutePath, SOURCE_TYPE_LABEL, EMOTION_TAG_LABEL, SourceType
} from '../../common/Constants';
import { FrameItem, MockDataStore } from '../../common/MockData';
import { AppColors, AppFontSize, AppSpacing } from '../../common/Styles';
import { BatchActionBar } from '../../common/components/BatchActionBar';

/** 视图模式 */
enum ViewMode {
  LIST = 'list',      // 列表视图
  GRID = 'grid'       // 网格视图
}

@Component
export struct CollectIndex {
  @State frameList: FrameItem[] = []
  @State searchText: string = ''
  @State selectedSource: SourceType | undefined = undefined
  @State selectedEmotion: EmotionTag | undefined = undefined
  
  /** 视图状态 */
  @State viewMode: ViewMode = ViewMode.LIST
  
  /** 多选模式状态 */
  @State isSelectMode: boolean = false
  @State selectedIds: Set<string> = new Set<string>()
  @State isAllSelectedFlag: boolean = false  // 缓存全选状态，避免渲染时计算
  @State selectedMap: Record<string, boolean> = {}  // 缓存每个项的选中状态
  @State selectedCount: number = 0  // 缓存选中数量，避免渲染时访问 Set.size
  
  /** 来源筛选 Chip 列表 */
  private sourceFilters: SourceType[] = [
    SourceType.FILM, SourceType.ANIME, SourceType.LIFE, SourceType.OTHER
  ]

  /** 情绪筛选 Chip 列表 */
  private emotionFilters: EmotionTag[] = [
    EmotionTag.HEAL, EmotionTag.BURN, EmotionTag.SAD, EmotionTag.FUNNY
  ]

  aboutToAppear(): void {
    // 确保数据已初始化后再刷新列表
    this.ensureDataReady()
  }

  /** 页面每次显示时刷新数据（包括从其他页面返回） */
  onPageShow(): void {
    this.refreshList()
  }

  /** 确保数据已初始化 */
  private async ensureDataReady(): Promise<void> {
    await MockDataStore.init()
    this.refreshList()
  }

  private refreshList(): void {
    let list = MockDataStore.filterFrames(this.selectedSource, this.selectedEmotion)
    if (this.searchText.trim().length > 0) {
      list = MockDataStore.searchFrames(this.searchText).filter((item: FrameItem) => {
        const matchSource = this.selectedSource === undefined || item.sourceType === this.selectedSource
        const matchEmotion = this.selectedEmotion === undefined || item.emotion === this.selectedEmotion
        return matchSource && matchEmotion
      })
    }
    this.frameList = list
    // 如果在多选模式下，更新全选标志和选中Map
    if (this.isSelectMode) {
      this.updateAllSelectedFlag()
      this.updateSelectedMap()
    }
  }

  /** 进入多选模式 */
  private enterSelectMode(initialItemId?: string): void {
    this.isSelectMode = true
    // 创建新的 Set 对象以触发 UI 更新
    if (initialItemId !== undefined) {
      const newSet = new Set<string>()
      newSet.add(initialItemId)
      this.selectedIds = newSet
    } else {
      this.selectedIds = new Set<string>()
    }
    // 更新全选标志和选中Map
    this.updateAllSelectedFlag()
    this.updateSelectedMap()
  }

  /** 退出多选模式 */
  private exitSelectMode(): void {
    this.isSelectMode = false
    this.selectedIds = new Set<string>()
    this.isAllSelectedFlag = false
    this.selectedMap = {}
    this.selectedCount = 0
  }

  /** 更新全选标志 */
  private updateAllSelectedFlag(): void {
    this.isAllSelectedFlag = this.frameList.length > 0 && this.selectedIds.size === this.frameList.length
    this.selectedCount = this.selectedIds.size
  }

  /** 更新选中状态 Map */
  private updateSelectedMap(): void {
    const newMap: Record<string, boolean> = {}
    this.frameList.forEach((item: FrameItem) => {
      newMap[item.id] = this.selectedIds.has(item.id)
    })
    this.selectedMap = newMap
  }

  /** 全选当前列表 */
  private selectAll(): void {
    // 如果列表为空，不执行全选
    if (this.frameList.length === 0) {
      return
    }
    
    const newSet = new Set<string>()
    this.frameList.forEach((item: FrameItem) => {
      newSet.add(item.id)
    })
    this.selectedIds = newSet
    // 更新全选标志和选中Map
    this.updateAllSelectedFlag()
    this.updateSelectedMap()
  }

  /** 取消全选（清空选中项，但不退出多选模式） */
  private deselectAll(): void {
    this.selectedIds = new Set<string>()
    // 更新全选标志和选中Map
    this.updateAllSelectedFlag()
    this.updateSelectedMap()
  }

  /** 切换选中状态 */
  private toggleSelection(itemId: string): void {
    const newSet = new Set<string>(this.selectedIds)
    if (newSet.has(itemId)) {
      newSet.delete(itemId)
    } else {
      newSet.add(itemId)
    }
    this.selectedIds = newSet
    // 更新全选标志和选中Map
    this.updateAllSelectedFlag()
    this.updateSelectedMap()
  }

  /** 批量删除 */
  private handleBatchDelete(): void {
    AlertDialog.show({
      title: '批量删除',
      message: `确定要删除选中的 ${this.selectedCount} 项吗？删除后可在回收站恢复。`,
      primaryButton: {
        value: '取消',
        action: () => {}
      },
      secondaryButton: {
        value: '删除',
        fontColor: AppColors.DANGER,
        action: () => {
          const ids = Array.from(this.selectedIds)
          const count = MockDataStore.batchDelete(ids)
          console.info(`[CollectIndex] 批量删除成功，删除 ${count} 条`)
          this.refreshList()
          this.exitSelectMode()
        }
      }
    })
  }

  build() {
    Column() {
      // 批量操作栏（多选模式时显示）
      if (this.isSelectMode) {
        BatchActionBar({
          selectedCount: this.selectedCount,
          onBatchDelete: () => { this.handleBatchDelete() },
          onCancel: () => { this.exitSelectMode() }
        })
      }

      // 顶栏
      Row() {
        Column({ space: 4 }) {
          Text('帧藏')
            .fontSize(AppFontSize.HEADLINE)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppColors.TEXT_PRIMARY)
          Text($r('app.string.app_slogan'))
            .fontSize(AppFontSize.BODY_SM)
            .fontColor(AppColors.TEXT_SECONDARY)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        Row({ space: AppSpacing.SM }) {
          // 多选按钮
          if (this.isSelectMode) {
            // 全选/取消全选按钮
            Button(this.isAllSelectedFlag ? '取消全选' : '全选')
              .fontSize(AppFontSize.BODY_SM)
              .fontColor(this.isAllSelectedFlag ? AppColors.ACCENT_PRIMARY : AppColors.TEXT_SECONDARY)
              .backgroundColor(this.isAllSelectedFlag ? AppColors.BADGE_BG : AppColors.SURFACE_BG)
              .borderRadius(20)
              .height(36)
              .onClick(() => {
                if (this.isAllSelectedFlag) {
                  this.deselectAll()
                } else {
                  this.selectAll()
                }
              })
            
            // 取消按钮
            Button('取消')
              .fontSize(AppFontSize.BODY_SM)
              .fontColor(AppColors.TEXT_SECONDARY)
              .backgroundColor(AppColors.SURFACE_BG)
              .borderRadius(20)
              .height(36)
              .onClick(() => {
                this.exitSelectMode()
              })
          } else {
            Button('选择')
              .fontSize(AppFontSize.BODY_SM)
              .fontColor(AppColors.TEXT_SECONDARY)
              .backgroundColor(AppColors.SURFACE_BG)
              .borderRadius(20)
              .height(36)
              .onClick(() => {
                this.enterSelectMode()
              })
            
            // 视图切换按钮
            Button(this.viewMode === ViewMode.LIST ? '☰' : '▦')
              .fontSize(AppFontSize.BODY_SM)
              .fontColor(AppColors.TEXT_SECONDARY)
              .backgroundColor(AppColors.SURFACE_BG)
              .borderRadius(20)
              .height(36)
              .width(36)
              .padding({ left: 0, right: 0 })
              .onClick(() => {
                // 切换视图模式
                this.viewMode = this.viewMode === ViewMode.LIST ? ViewMode.GRID : ViewMode.LIST
              })
          }

          Button($r('app.string.btn_import'))
            .fontSize(AppFontSize.BODY_SM)
            .fontColor(AppColors.PAGE_BG)
            .backgroundColor(AppColors.ACCENT_PRIMARY)
            .borderRadius(20)
            .height(36)
            .onClick(() => {
              router.pushUrl({ url: RoutePath.IMPORT_PAGE })
            })
        }
      }
      .width('100%')
      .padding({
        left: AppSpacing.PAGE_HORIZONTAL,
        right: AppSpacing.PAGE_HORIZONTAL,
        top: AppSpacing.XL,
        bottom: AppSpacing.SM
      })

      // 搜索框
      Search({ value: this.searchText, placeholder: '搜索来源、台词、标签…' })
        .width('100%')
        .height(32)
        .backgroundColor(AppColors.SURFACE_BG)
        .placeholderColor(AppColors.TEXT_TERTIARY)
        .textFont({ size: AppFontSize.BODY })
        .margin({ left: AppSpacing.PAGE_HORIZONTAL, right: AppSpacing.PAGE_HORIZONTAL, bottom: AppSpacing.SM })
        .onChange((val: string) => {
          this.searchText = val
          this.refreshList()
        })

      // 来源筛选
      Scroll() {
        Row({ space: AppSpacing.SM }) {
          Text('全部来源')
            .fontSize(AppFontSize.CAPTION)
            .fontColor(this.selectedSource === undefined ? AppColors.PAGE_BG : AppColors.TEXT_SECONDARY)
            .backgroundColor(this.selectedSource === undefined ? AppColors.ACCENT_PRIMARY : AppColors.SURFACE_BG)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .borderRadius(16)
            .onClick(() => {
              this.selectedSource = undefined
              this.refreshList()
            })
          ForEach(this.sourceFilters, (src: SourceType) => {
            Text(SOURCE_TYPE_LABEL[src])
              .fontSize(AppFontSize.CAPTION)
              .fontColor(this.selectedSource === src ? AppColors.PAGE_BG : AppColors.TEXT_SECONDARY)
              .backgroundColor(this.selectedSource === src ? AppColors.ACCENT_PRIMARY : AppColors.SURFACE_BG)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .borderRadius(16)
              .onClick(() => {
                this.selectedSource = this.selectedSource === src ? undefined : src
                this.refreshList()
              })
          }, (src: SourceType) => src)
        }
        .padding({ left: AppSpacing.PAGE_HORIZONTAL, right: AppSpacing.PAGE_HORIZONTAL })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .height(40)

      // 情绪筛选
      Scroll() {
        Row({ space: AppSpacing.SM }) {
          Text('全部情绪')
            .fontSize(AppFontSize.CAPTION)
            .fontColor(this.selectedEmotion === undefined ? AppColors.PAGE_BG : AppColors.TEXT_SECONDARY)
            .backgroundColor(this.selectedEmotion === undefined ? AppColors.ACCENT_PRIMARY : AppColors.SURFACE_BG)
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .borderRadius(16)
            .onClick(() => {
              this.selectedEmotion = undefined
              this.refreshList()
            })
          ForEach(this.emotionFilters, (emo: EmotionTag) => {
            Text(EMOTION_TAG_LABEL[emo])
              .fontSize(AppFontSize.CAPTION)
              .fontColor(this.selectedEmotion === emo ? AppColors.PAGE_BG : AppColors.TEXT_SECONDARY)
              .backgroundColor(this.selectedEmotion === emo ? AppColors.ACCENT_PRIMARY : AppColors.SURFACE_BG)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .borderRadius(16)
              .onClick(() => {
                this.selectedEmotion = this.selectedEmotion === emo ? undefined : emo
                this.refreshList()
              })
          }, (emo: EmotionTag) => emo)
        }
        .padding({ left: AppSpacing.PAGE_HORIZONTAL, right: AppSpacing.PAGE_HORIZONTAL })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .height(40)
      .margin({ bottom: AppSpacing.SM })

      if (this.frameList.length === 0) {
        // 空状态页面
        Column({ space: 24 }) {
          // 空状态插画
          Column() {
            // 使用系统符号字体作为插画
            Text('🎬')
              .fontSize(80)
              .opacity(0.6)
            
            // 装饰性背景圆
            Column()
              .width(160)
              .height(160)
              .borderRadius(80)
              .linearGradient({
                angle: 135,
                colors: [
                  [AppColors.ACCENT_PRIMARY + '15', 0.0],
                  [AppColors.ACCENT_PRIMARY + '08', 1.0]
                ]
              })
              .position({ x: '50%', y: '50%' })
              .translate({ x: '-50%', y: '-50%' })
              .zIndex(-1)
          }
          .width(160)
          .height(160)
          .margin({ bottom: 16 })

          // 主标题
          Text('还没有收藏素材')
            .fontSize(AppFontSize.HEADLINE)
            .fontColor(AppColors.TEXT_PRIMARY)
            .fontWeight(FontWeight.Medium)

          // 引导文案
          Column({ space: 8 }) {
            Text('记录那些触动心灵的瞬间')
              .fontSize(AppFontSize.BODY)
              .fontColor(AppColors.TEXT_SECONDARY)
            
            Text('截图、台词、情绪，一键收藏')
              .fontSize(AppFontSize.BODY_SM)
              .fontColor(AppColors.TEXT_TERTIARY)
          }

          // 立即导入按钮
          Button('立即导入')
            .fontSize(AppFontSize.BODY)
            .fontColor('#FFFFFF')
            .backgroundColor(AppColors.ACCENT_PRIMARY)
            .borderRadius(24)
            .height(48)
            .padding({ left: 32, right: 32 })
            .shadow({
              radius: 12,
              color: AppColors.ACCENT_PRIMARY + '40',
              offsetX: 0,
              offsetY: 4
            })
            .onClick(() => {
              router.pushUrl({ url: RoutePath.IMPORT_PAGE })
            })

          // 底部提示
          Row({ space: 4 }) {
            Text('💡')
              .fontSize(14)
            Text('支持从相册导入或截图粘贴')
              .fontSize(AppFontSize.CAPTION)
              .fontColor(AppColors.TEXT_TERTIARY)
          }
          .margin({ top: 8 })
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .padding({ left: 48, right: 48 })
      } else {
        // 根据视图模式显示不同的布局
        if (this.viewMode === ViewMode.LIST) {
          // 列表视图
          List({ space: AppSpacing.LIST_ITEM_GAP }) {
            ForEach(this.frameList, (item: FrameItem) => {
              ListItem() {
                this.frameCard(item)
              }
            }, (item: FrameItem) => item.id)
          }
          .layoutWeight(1)
          .padding({ left: AppSpacing.PAGE_HORIZONTAL, right: AppSpacing.PAGE_HORIZONTAL })
          .scrollBar(BarState.Off)
        } else {
          // 网格视图
          Grid() {
            ForEach(this.frameList, (item: FrameItem) => {
              GridItem() {
                this.frameCard(item)
              }
            }, (item: FrameItem) => item.id)
          }
          .columnsTemplate('1fr 1fr')  // 两列布局
          .rowsGap(AppSpacing.LIST_ITEM_GAP)
          .columnsGap(AppSpacing.SM)
          .layoutWeight(1)
          .padding({ left: AppSpacing.PAGE_HORIZONTAL, right: AppSpacing.PAGE_HORIZONTAL })
          .scrollBar(BarState.Off)
        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppColors.PAGE_BG)
    .onVisibleAreaChange([0.0, 1.0], (isVisible: boolean, currentRatio: number) => {
      if (isVisible && currentRatio >= 0.5) {
        this.refreshList()
      }
    })
  }

  /** 判断是否为 rawfile 路径（相对路径，非相册 URI） */
  private isRawFilePath(uri: string): boolean {
    return uri.length > 0 && !uri.startsWith('file://') && !uri.startsWith('datashare://')
  }

  /** 获取卡片高度（根据视图模式） */
  private getCardHeight(): number {
    return this.viewMode === ViewMode.LIST ? 220 : 180
  }

  @Builder
  frameCard(item: FrameItem) {
    Stack({ alignContent: Alignment.BottomStart }) {
      // 背景大图
      if (item.screenshotUri && item.screenshotUri.length > 0) {
        if (this.isRawFilePath(item.screenshotUri)) {
          Image($rawfile(item.screenshotUri))
            .width('100%')
            .height(this.getCardHeight())
            .objectFit(ImageFit.Cover)
            .borderRadius(12)
        } else {
          Image(item.screenshotUri)
            .width('100%')
            .height(this.getCardHeight())
            .objectFit(ImageFit.Cover)
            .borderRadius(12)
        }
      } else {
        // 无图片时的占位背景
        Column()
          .width('100%')
          .height(this.getCardHeight())
          .borderRadius(12)
          .linearGradient({
            angle: 135,
            colors: [[AppColors.BADGE_BG, 0.0], ['#2A2A2E', 1.0]]
          })
      }

      // 渐变遮罩层（增强文字可读性）
      Column()
        .width('100%')
        .height(100)
        .borderRadius({ bottomLeft: 12, bottomRight: 12 })
        .linearGradient({
          angle: 180,
          colors: [['#00000000', 0.0], ['#CC000000', 0.6], ['#E6000000', 1.0]]
        })

      // 左上角：来源/情绪标签
      Row({ space: AppSpacing.XS }) {
        Text(SOURCE_TYPE_LABEL[item.sourceType])
          .fontSize(AppFontSize.CAPTION)
          .fontColor('#FFFFFF')
          .backgroundColor(AppColors.ACCENT_PRIMARY)
          .padding({ left: 8, right: 8, top: 3, bottom: 3 })
          .borderRadius(4)
        Text(EMOTION_TAG_LABEL[item.emotion])
          .fontSize(AppFontSize.CAPTION)
          .fontColor('#FFFFFF')
          .backgroundColor('rgba(255, 255, 255, 0.25)')
          .padding({ left: 8, right: 8, top: 3, bottom: 3 })
          .borderRadius(4)
      }
      .position({ x: 12, y: 12 })

      // 右上角：多选模式下显示选中指示器
      if (this.isSelectMode) {
        Row() {
          if (this.selectedMap[item.id] ?? false) {
            Text('✓')
              .fontSize(16)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Bold)
          }
        }
        .width(24)
        .height(24)
        .borderRadius(12)
        .backgroundColor(this.selectedMap[item.id] ?? false ? AppColors.ACCENT_PRIMARY : 'rgba(255, 255, 255, 0.3)')
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .position({ x: '100%', y: 12 })
        .translate({ x: -36 })
        .onClick(() => {
          this.toggleSelection(item.id)
        })
      }

      // 底部：台词文字叠加
      Column({ space: 6 }) {
        Text(item.sourceTitle)
          .fontSize(AppFontSize.BODY)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .textShadow({ radius: 2, color: '#80000000', offsetX: 0, offsetY: 1 })

        if (item.momentText.length > 0) {
          Text(item.momentText)
            .fontSize(AppFontSize.BODY_SM)
            .fontColor('rgba(255, 255, 255, 0.85)')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .textShadow({ radius: 2, color: '#80000000', offsetX: 0, offsetY: 1 })
        } else {
          Text('（纯画面）')
            .fontSize(AppFontSize.BODY_SM)
            .fontColor('rgba(255, 255, 255, 0.6)')
            .fontStyle(FontStyle.Italic)
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 16 })
      .alignItems(HorizontalAlign.Start)


    }
    .width('100%')
    .height(this.getCardHeight())
    .borderRadius(12)
    .backgroundColor(this.selectedMap[item.id] ?? false ? '#1A1A1E' : AppColors.SURFACE_BG)
    .border({
      width: this.selectedMap[item.id] ?? false ? 3 : 0,
      color: AppColors.ACCENT_PRIMARY
    })
    .onClick(() => {
      if (this.isSelectMode) {
        // 多选模式下，点击切换选中状态
        this.toggleSelection(item.id)
      } else {
        // 正常模式下，跳转详情
        router.pushUrl({
          url: RoutePath.MATERIAL_DETAIL,
          params: { frameId: item.id }
        })
      }
    })
    .gesture(
      LongPressGesture({ repeat: false, duration: 500 })
        .onAction(() => {
          // 长按进入多选模式
          if (!this.isSelectMode) {
            this.enterSelectMode(item.id)
          }
        })
    )
  }
}
