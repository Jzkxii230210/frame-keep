/**
 * FrameKeep（帧藏）- 场景素材库详情页
 * 展示特定使用场景下的素材列表
 */
import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { RouteParams, EMOTION_TAG_LABEL, SOURCE_TYPE_LABEL } from '../../common/Constants';
import { FrameItem, MockDataStore } from '../../common/MockData';
import { PageShell } from '../../common/components/PageShell';
import { AppColors, AppFontSize, AppSpacing } from '../../common/Styles';
import { MediaAssets } from '../../common/utils/MediaAssetsManager';

/** 场景素材库数据 */
interface SceneLibraryData {
  id: string
  title: string
  description: string
  usageScenario: string
}

/** 场景素材库配置 */
const SCENE_LIBRARY_CONFIG: Record<string, SceneLibraryData> = {
  'sl1': {
    id: 'sl1',
    title: '朋友圈文案向',
    description: '适合发圈的氛围感台词',
    usageScenario: '朋友圈'
  },
  'sl2': {
    id: 'sl2',
    title: '备考励志向',
    description: '考研/学习打气金句',
    usageScenario: '备考'
  },
  'sl3': {
    id: 'sl3',
    title: '低谷治愈向',
    description: 'emo时必看的治愈片段',
    usageScenario: '治愈'
  },
  'sl4': {
    id: 'sl4',
    title: '剪辑备用向',
    description: '高燃转场名场面素材',
    usageScenario: '剪辑'
  }
}

@Entry
@Component
struct SceneLibraryDetail {
  @State libraryData: SceneLibraryData | undefined = undefined
  @State frames: FrameItem[] = []
  @State isMultiSelectMode: boolean = false
  @State selectedFrameIds: Set<string> = new Set<string>()
  @State showMoveDialog: boolean = false
  @State targetLibraryId: string = ''
  private libraryId: string = ''

  async aboutToAppear(): Promise<void> {
    await MockDataStore.init()
    const params = router.getParams() as Record<string, string>
    this.libraryId = params['libraryId'] ?? ''
    this.libraryData = SCENE_LIBRARY_CONFIG[this.libraryId]
    await this.loadFrames()
  }

  /** 加载素材数据 */
  private async loadFrames(): Promise<void> {
    // 先检查是否有自定义的场景素材库数据
    const customFrameIds = MockDataStore.getSceneLibraryFrameIds(this.libraryId)
    
    if (customFrameIds !== undefined && customFrameIds.length > 0) {
      // 使用自定义数据
      const allFrames = MockDataStore.getAllFrames()
      this.frames = customFrameIds
        .map(id => allFrames.find(f => f.id === id))
        .filter(f => f !== undefined) as FrameItem[]
    } else {
      // 使用默认数据（基于情绪筛选）
      const allFrames = MockDataStore.getAllFrames()
      
      if (this.libraryId === 'sl1') {
        // 朋友圈文案向 - 治愈或伤感情绪，适合发圈
        this.frames = allFrames.filter(f => f.emotion === 'heal' || f.emotion === 'sad')
      } else if (this.libraryId === 'sl2') {
        // 备考励志向 - 燃向情绪，学习打气
        this.frames = allFrames.filter(f => f.emotion === 'burn')
      } else if (this.libraryId === 'sl3') {
        // 低谷治愈向 - 治愈情绪，emo时必看
        this.frames = allFrames.filter(f => f.emotion === 'heal')
      } else if (this.libraryId === 'sl4') {
        // 剪辑备用向 - 燃向或搞笑，高燃转场名场面素材
        this.frames = allFrames.filter(f => f.emotion === 'burn' || f.emotion === 'funny')
      } else {
        this.frames = []
      }
      
      // 初始化自定义数据（保存默认数据）
      await MockDataStore.initSceneLibraryData(this.libraryId, this.frames.map(f => f.id))
    }
  }

  /** 切换多选模式 */
  private toggleMultiSelectMode(): void {
    this.isMultiSelectMode = !this.isMultiSelectMode
    if (!this.isMultiSelectMode) {
      this.selectedFrameIds.clear()
    }
  }

  /** 切换单个素材选中状态 */
  private toggleFrameSelection(frameId: string): void {
    if (this.selectedFrameIds.has(frameId)) {
      this.selectedFrameIds.delete(frameId)
    } else {
      this.selectedFrameIds.add(frameId)
    }
  }

  /** 全选/取消全选 */
  private toggleSelectAll(): void {
    if (this.selectedFrameIds.size === this.frames.length) {
      this.selectedFrameIds.clear()
    } else {
      this.frames.forEach(f => this.selectedFrameIds.add(f.id))
    }
  }

  /** 批量收藏 */
  private batchCollect(): void {
    let addedCount = 0
    this.frames.forEach(f => {
      if (this.selectedFrameIds.has(f.id)) {
        if (!MockDataStore.getFrameById(f.id)) {
          MockDataStore.addFrame(f)
          addedCount++
        }
      }
    })
    promptAction.showToast({ message: `已添加 ${addedCount} 条素材到收藏` })
    this.toggleMultiSelectMode()
  }

  build() {
    Column() {
      PageShell({
        title: this.libraryData?.title ?? '场景素材库',
        content: () => { this.body() }
      })
    }
    .width('100%')
    .height('100%')
    .bindSheet($$this.showMoveDialog, this.moveDialog(), { height: 300, dragBar: false })
  }

  @Builder
  body() {
    Column({ space: AppSpacing.LG }) {
      // 场景说明
      if (this.libraryData) {
        Row({ space: 8 }) {
          Text(this.libraryData.usageScenario)
            .fontSize(12)
            .fontColor(AppColors.ACCENT_PRIMARY)
            .backgroundColor('#1A4A90E2')
            .borderRadius(8)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          Text(this.libraryData.description)
            .fontColor(AppColors.TEXT_SECONDARY)
            .fontSize(AppFontSize.BODY_SM)
        }
        .width('100%')
      }

      // 操作栏
      Row({ space: AppSpacing.MD }) {
        if (this.isMultiSelectMode) {
          // 多选模式
          Text('取消')
            .fontSize(AppFontSize.BODY)
            .fontColor(AppColors.TEXT_SECONDARY)
            .onClick(() => this.toggleMultiSelectMode())

          Blank()

          Text(`已选 ${this.selectedFrameIds.size} 项`)
            .fontSize(AppFontSize.BODY_SM)
            .fontColor(AppColors.TEXT_SECONDARY)

          Text(this.selectedFrameIds.size === this.frames.length ? '取消全选' : '全选')
            .fontSize(AppFontSize.BODY)
            .fontColor(AppColors.ACCENT_PRIMARY)
            .onClick(() => this.toggleSelectAll())
        } else {
          // 正常模式
          Text(`${this.frames.length} 条素材`)
            .fontSize(AppFontSize.BODY_SM)
            .fontColor(AppColors.TEXT_SECONDARY)

          Blank()

          if (this.frames.length > 0) {
            Text('选择')
              .fontSize(AppFontSize.BODY)
              .fontColor(AppColors.ACCENT_PRIMARY)
              .onClick(() => this.toggleMultiSelectMode())
          }
        }
      }
      .width('100%')

      // 素材列表
      if (this.frames.length > 0) {
        List({ space: AppSpacing.LIST_ITEM_GAP }) {
          ForEach(this.frames, (item: FrameItem) => {
            ListItem() {
              this.frameCard(item)
            }
          }, (item: FrameItem) => item.id)
        }
        .layoutWeight(1)
      } else {
        // 空状态
        this.emptyState()
      }

      // 多选模式底部操作栏
      if (this.isMultiSelectMode && this.selectedFrameIds.size > 0) {
        this.batchActionBar()
      }
    }
    .padding(AppSpacing.PAGE_HORIZONTAL)
    .height('100%')
  }

  /** 素材卡片 */
  @Builder
  frameCard(item: FrameItem) {
    Row({ space: AppSpacing.MD }) {
      // 多选模式下显示 Checkbox
      if (this.isMultiSelectMode) {
        Checkbox()
          .select(this.selectedFrameIds.has(item.id))
          .shape(CheckBoxShape.CIRCLE)
          .onChange((isChecked: boolean) => {
            this.toggleFrameSelection(item.id)
          })
      }

      // 封面图
      Image($rawfile(item.screenshotUri || MediaAssets.HEAL_IMAGES.IMG_001))
        .width(80)
        .height(80)
        .borderRadius(8)
        .objectFit(ImageFit.Cover)

      Column({ space: 6 }) {
        // 标签行
        Row({ space: 6 }) {
          Text(SOURCE_TYPE_LABEL[item.sourceType])
            .fontSize(10)
            .fontColor(AppColors.ACCENT_PRIMARY)
            .backgroundColor('#1A4A90E2')
            .borderRadius(4)
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          Text(EMOTION_TAG_LABEL[item.emotion])
            .fontSize(10)
            .fontColor(AppColors.TEXT_TERTIARY)
        }

        // 来源标题
        Text(item.sourceTitle)
          .fontSize(AppFontSize.BODY)
          .fontColor(AppColors.TEXT_PRIMARY)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        // 台词/描述
        if (item.momentText.length > 0) {
          Text(item.momentText)
            .fontSize(AppFontSize.CAPTION)
            .fontColor(AppColors.TEXT_SECONDARY)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 收藏按钮（非多选模式）
      if (!this.isMultiSelectMode) {
        Button('收藏')
          .height(32)
          .fontSize(AppFontSize.CAPTION)
          .backgroundColor(AppColors.ACCENT_PRIMARY)
          .fontColor(AppColors.PAGE_BG)
          .onClick(() => {
            if (MockDataStore.getFrameById(item.id)) {
              promptAction.showToast({ message: '已在你的收藏中' })
            } else {
              MockDataStore.addFrame(item)
              promptAction.showToast({ message: '已添加到收藏' })
            }
          })
      }
    }
    .width('100%')
    .padding(AppSpacing.MD)
    .backgroundColor(AppColors.SURFACE_BG)
    .borderRadius(12)
    .onClick(() => {
      if (this.isMultiSelectMode) {
        this.toggleFrameSelection(item.id)
      }
    })
  }
  
  /** 移动弹窗 */
  @Builder
  moveDialog() {
    Column({ space: AppSpacing.MD }) {
      Text(`移动 ${this.selectedFrameIds.size} 条素材到其他场景`)
        .fontSize(AppFontSize.TITLE)
        .fontColor(AppColors.TEXT_PRIMARY)
      
      Column({ space: AppSpacing.SM }) {
        ForEach(Object.entries(SCENE_LIBRARY_CONFIG), (entry: [string, SceneLibraryData]) => {
          if (entry[0] !== this.libraryId) {
            Row() {
              Text(entry[1].title)
                .fontSize(AppFontSize.BODY)
                .fontColor(AppColors.TEXT_PRIMARY)
            }
            .width('100%')
            .height(48)
            .padding({ left: AppSpacing.MD, right: AppSpacing.MD })
            .backgroundColor(this.targetLibraryId === entry[0] ? '#1AE8B923' : AppColors.SURFACE_BG)
            .borderRadius(8)
            .onClick(() => {
              this.targetLibraryId = entry[0]
            })
          }
        }, (entry: [string, SceneLibraryData]) => entry[0])
      }
      .width('100%')
      .layoutWeight(1)
      
      Row({ space: AppSpacing.MD }) {
        Button('取消')
          .layoutWeight(1)
          .height(44)
          .backgroundColor('#E8E8E8')
          .fontColor(AppColors.TEXT_PRIMARY)
          .onClick(() => {
            this.showMoveDialog = false
            this.targetLibraryId = ''
          })
        
        Button('确认移动')
          .layoutWeight(1)
          .height(44)
          .backgroundColor(AppColors.ACCENT_PRIMARY)
          .fontColor(AppColors.PAGE_BG)
          .enabled(this.targetLibraryId.length > 0)
          .onClick(async () => {
            await this.batchMove()
          })
      }
    }
    .width('100%')
    .padding(AppSpacing.MD)
  }
  
  /** 删除帧 */
  private async batchDelete(): Promise<void> {
    const frameIds = Array.from(this.selectedFrameIds)
    let successCount = 0
    
    for (const frameId of frameIds) {
      const success = await MockDataStore.deleteFrameFromSceneLibrary(this.libraryId, frameId)
      if (success) {
        successCount++
      }
    }
    
    if (successCount > 0) {
      promptAction.showToast({ message: `已删除 ${successCount} 条素材` })
      this.toggleMultiSelectMode()
      await this.loadFrames()
    } else {
      promptAction.showToast({ message: '删除失败' })
    }
  }
  
  /** 批量移动帧 */
  private async batchMove(): Promise<void> {
    if (this.targetLibraryId.length === 0) {
      return
    }
    
    const frameIds = Array.from(this.selectedFrameIds)
    let successCount = 0
    
    for (const frameId of frameIds) {
      const success = await MockDataStore.moveFrameToSceneLibrary(this.libraryId, this.targetLibraryId, frameId)
      if (success) {
        successCount++
      }
    }
    
    if (successCount > 0) {
      promptAction.showToast({ message: `已移动 ${successCount} 条素材` })
      this.showMoveDialog = false
      this.targetLibraryId = ''
      this.toggleMultiSelectMode()
      await this.loadFrames()
    } else {
      promptAction.showToast({ message: '移动失败' })
    }
  }

  /** 空状态 */
  @Builder
  emptyState() {
    Column({ space: AppSpacing.MD }) {
      Text('📦')
        .fontSize(48)
      Text('暂无素材')
        .fontSize(AppFontSize.BODY)
        .fontColor(AppColors.TEXT_SECONDARY)
      Text('该场景的素材正在整理中，敬请期待')
        .fontSize(AppFontSize.CAPTION)
        .fontColor(AppColors.TEXT_TERTIARY)
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  /** 批量操作栏 */
  @Builder
  batchActionBar() {
    Row({ space: AppSpacing.SM }) {
      Button('移动')
        .layoutWeight(1)
        .height(44)
        .fontSize(AppFontSize.BODY)
        .backgroundColor('#E8E8E8')
        .fontColor('#333333')
        .borderRadius(22)
        .onClick(() => {
          this.showMoveDialog = true
        })
      
      Button('删除')
        .layoutWeight(1)
        .height(44)
        .fontSize(AppFontSize.BODY)
        .backgroundColor('#FFE8E8')
        .fontColor('#D32F2F')
        .borderRadius(22)
        .onClick(async () => {
          await this.batchDelete()
        })
      
      Button('收藏')
        .layoutWeight(1)
        .height(44)
        .fontSize(AppFontSize.BODY)
        .backgroundColor(AppColors.ACCENT_PRIMARY)
        .fontColor(AppColors.PAGE_BG)
        .borderRadius(22)
        .onClick(() => this.batchCollect())
    }
    .width('100%')
    .padding({ top: AppSpacing.MD, bottom: AppSpacing.MD, left: AppSpacing.MD, right: AppSpacing.MD })
    .backgroundColor(AppColors.PAGE_BG)
    .borderRadius({ topLeft: 16, topRight: 16 })
    .shadow({
      radius: 8,
      color: '#1A000000',
      offsetY: -2
    })
  }
}
