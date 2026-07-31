/**
 * FrameKeep（帧藏）- 卡片模板选择页
 * 功能：按分类浏览8种真实版式的卡片模板，支持选中态反馈，跳转至编辑页
 * 分类：电影质感 / 生活记录 / 潮流设计 / 极简高级
 */
import { router } from '@kit.ArkUI';
import { RouteParams, RoutePath } from '../../common/Constants';
import { FrameItem, MockDataStore } from '../../common/MockData';
import { AppColors, AppFontSize, AppSpacing } from '../../common/Styles';
import {
  TemplateCategory,
  LayoutType,
  TemplateStyle,
  CATEGORY_LABELS,
  TEMPLATES,
  getTemplatesByCategory
} from '../../common/TemplateTypes';

@Entry
@Component
struct TemplateSelect {
  private frameId: string = ''
  @State frame: FrameItem | undefined = undefined

  /** 当前选中的分类索引（0=全部） */
  @State currentTabIndex: number = 0
  /** 当前选中的模板索引 */
  @State selectedTemplateIndex: number = -1

  /** 分类列表（与Tab一一对应，第0项为全部） */
  private tabCategories: (TemplateCategory | 'all')[] = [
    'all',
    TemplateCategory.FILM,
    TemplateCategory.LIFE,
    TemplateCategory.TREND,
    TemplateCategory.MINIMAL
  ]

  /** 根据当前Tab筛选模板 */
  private getFilteredTemplates(): TemplateStyle[] {
    const category = this.tabCategories[this.currentTabIndex]
    return getTemplatesByCategory(category)
  }

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, string>
    this.frameId = params[RouteParams.FRAME_ID] ?? ''
    this.frame = MockDataStore.getFrameById(this.frameId)
  }

  build() {
    Column() {
      // ========== 顶部导航栏 ==========
      Row() {
        // 返回按钮
        Button({ type: ButtonType.Circle }) {
          Text('←')
            .fontSize(20)
            .fontColor(AppColors.TEXT_PRIMARY)
        }
        .width(36)
        .height(36)
        .backgroundColor(AppColors.SURFACE_BG)
        .onClick(() => router.back())

        Text('选择模板')
          .fontSize(AppFontSize.HEADLINE)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.TEXT_PRIMARY)
          .layoutWeight(1)
          .margin({ left: AppSpacing.SM })

        Button('我的模板')
          .fontSize(AppFontSize.BODY_SM)
          .fontColor(AppColors.TEXT_SECONDARY)
          .backgroundColor(AppColors.SURFACE_BG)
          .borderRadius(20)
          .height(36)
          .onClick(() => router.pushUrl({ url: RoutePath.MY_TEMPLATE }))
      }
      .width('100%')
      .padding({
        left: AppSpacing.PAGE_HORIZONTAL,
        right: AppSpacing.PAGE_HORIZONTAL,
        top: AppSpacing.LG,
        bottom: AppSpacing.SM
      })

      // ========== 分类Tabs ==========
      Tabs({ index: this.currentTabIndex, barPosition: BarPosition.Start }) {
        ForEach(this.tabCategories, (category: TemplateCategory | 'all', index: number) => {
          TabContent() {
            this.templateGrid()
          }
          .tabBar(category === 'all' ? '全部' : CATEGORY_LABELS[category])
        }, (category: TemplateCategory | 'all') => category)
      }
      .barMode(BarMode.Scrollable)
      .barBackgroundColor(AppColors.PAGE_BG)
      .layoutWeight(1)
      .onChange((index: number) => {
        this.currentTabIndex = index
        this.selectedTemplateIndex = -1 // 切换分类重置选中
      })

      // ========== 底部操作栏（选中模板后显示） ==========
      if (this.selectedTemplateIndex >= 0) {
        Row() {
          Text(`已选择：${this.getFilteredTemplates()[this.selectedTemplateIndex]?.name ?? ''}`)
            .fontSize(AppFontSize.BODY_SM)
            .fontColor(AppColors.TEXT_SECONDARY)
            .layoutWeight(1)

          Button('下一步')
            .fontSize(AppFontSize.BODY)
            .fontColor(AppColors.PAGE_BG)
            .backgroundColor(AppColors.ACCENT_PRIMARY)
            .borderRadius(24)
            .height(44)
            .padding({ left: 32, right: 32 })
            .onClick(() => {
              const template = this.getFilteredTemplates()[this.selectedTemplateIndex]
              if (template) {
                router.pushUrl({
                  url: RoutePath.CARD_EDIT,
                  params: {
                    frameId: this.frameId,
                    templateId: template.id,
                    templateName: template.name
                  }
                })
              }
            })
        }
        .width('100%')
        .padding({
          left: AppSpacing.PAGE_HORIZONTAL,
          right: AppSpacing.PAGE_HORIZONTAL,
          top: AppSpacing.SM,
          bottom: AppSpacing.LG
        })
        .backgroundColor(AppColors.SURFACE_BG)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppColors.PAGE_BG)
  }

  // ========== 模板网格列表 ==========
  @Builder
  templateGrid() {
    if (this.getFilteredTemplates().length === 0) {
      Column() {
        Text('暂无该分类模板')
          .fontSize(AppFontSize.BODY)
          .fontColor(AppColors.TEXT_TERTIARY)
      }
      .width('100%')
      .height(200)
      .justifyContent(FlexAlign.Center)
    } else {
      Grid() {
        ForEach(this.getFilteredTemplates(), (template: TemplateStyle, index: number) => {
          GridItem() {
            Column({ space: AppSpacing.SM }) {
              // 模板预览图（真实版式渲染）
              this.templatePreview(template)
              // 模板名称
              Text(template.name)
                .fontSize(AppFontSize.BODY_SM)
                .fontColor(AppColors.TEXT_PRIMARY)
            }
            .width('100%')
            .padding(AppSpacing.SM)
            .backgroundColor(AppColors.SURFACE_BG)
            .borderRadius(12)
            .border({
              width: this.selectedTemplateIndex === index ? 3 : 0,
              color: AppColors.ACCENT_PRIMARY
            })
            .shadow(this.selectedTemplateIndex === index ? {
              radius: 12,
              color: AppColors.ACCENT_PRIMARY + '40',
              offsetX: 0,
              offsetY: 4
            } : undefined)
            .onClick(() => {
              this.selectedTemplateIndex = this.selectedTemplateIndex === index ? -1 : index
            })
          }
        }, (template: TemplateStyle) => template.id)
      }
      .columnsTemplate('1fr 1fr')
      .rowsGap(AppSpacing.MD)
      .columnsGap(AppSpacing.MD)
      .padding(AppSpacing.PAGE_HORIZONTAL)
    }
  }

  // ========== 核心：8种真实版式预览渲染 ==========
  @Builder
  templatePreview(template: TemplateStyle) {
    Stack({ alignContent: Alignment.Center }) {
      if (template.layoutType === LayoutType.WIDESCREEN) {
        this.renderWidescreen(template)
      } else if (template.layoutType === LayoutType.LEFT_LINE) {
        this.renderLeftLine(template)
      } else if (template.layoutType === LayoutType.POLAROID) {
        this.renderPolaroid(template)
      } else if (template.layoutType === LayoutType.DIARY) {
        this.renderDiary(template)
      } else if (template.layoutType === LayoutType.DANMAKU) {
        this.renderDanmaku(template)
      } else if (template.layoutType === LayoutType.COLLAGE) {
        this.renderCollage(template)
      } else if (template.layoutType === LayoutType.BORDER) {
        this.renderBorder(template)
      } else if (template.layoutType === LayoutType.SPLIT) {
        this.renderSplit(template)
      }
    }
    .width('100%')
    .height(120)
    .borderRadius(8)
    .clip(true)
    .backgroundColor(template.bgColor)
  }

  // ---------- 各版式具体实现 ----------

  /** 宽屏电影帧 */
  @Builder
  renderWidescreen(template: TemplateStyle) {
    Column() {
      // 上黑边
      Rect().width('100%').height('15%').fill('#000000')
      // 画面区域
      Stack({ alignContent: Alignment.Center }) {
        this.renderPreviewImage()
      }
      .layoutWeight(1)
      // 下黑边 + 字幕
      Stack({ alignContent: Alignment.Center }) {
        Rect().width('100%').height('100%').fill('#000000')
        Text(this.getPreviewText())
          .fontSize(template.fontSize)
          .fontColor(template.textColor)
          .fontWeight(template.fontWeight)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .height('15%')
    }
    .width('100%')
    .height('100%')
  }

  /** 左竖线海报 */
  @Builder
  renderLeftLine(template: TemplateStyle) {
    Row() {
      // 左侧装饰竖线
      Rect().width(3).height('60%').fill(AppColors.ACCENT_PRIMARY)
      // 文字区域
      Column({ space: 4 }) {
        Text(this.getPreviewText())
          .fontSize(template.fontSize)
          .fontColor(template.textColor)
          .fontWeight(template.fontWeight)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text('—— 出处')
          .fontSize(template.fontSize - 2)
          .fontColor(template.textColor)
          .opacity(0.6)
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 10 })
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .padding(12)
    .backgroundImage(this.getPreviewImageUri(), ImageRepeat.NoRepeat)
    .backgroundImageSize(ImageSize.Cover)
  }

  /** 拍立得相框 */
  @Builder
  renderPolaroid(template: TemplateStyle) {
    Column() {
      // 图片区域
      Stack({ alignContent: Alignment.Center }) {
        this.renderPreviewImage()
      }
      .layoutWeight(4)
      .width('90%')
      .margin({ top: 8 })
      .clip(true)
      // 底部留白 + 文字
      Column() {
        Text(this.getPreviewText())
          .fontSize(template.fontSize)
          .fontColor(template.textColor)
          .fontWeight(template.fontWeight)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    }
    .width('85%')
    .height('92%')
    .backgroundColor('#FFFFFF')
    .shadow({ radius: 4, color: '#00000033', offsetX: 0, offsetY: 2 })
  }

  /** 手账日记 */
  @Builder
  renderDiary(template: TemplateStyle) {
    Stack({ alignContent: Alignment.TopStart }) {
      // 背景图
      this.renderPreviewImage()
      // 右上角日期标签
      Text('07/02')
        .fontSize(9)
        .fontColor('#5D4037')
        .backgroundColor('#FFFFFFCC')
        .padding({ left: 6, right: 6, top: 2, bottom: 2 })
        .borderRadius(4)
        .position({ x: '70%', y: 8 })
      // 底部文字
      Column() {
        Blank()
        Text(this.getPreviewText())
          .fontSize(template.fontSize)
          .fontColor(template.textColor)
          .fontWeight(template.fontWeight)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .backgroundColor('#FFFFFFCC')
          .padding(6)
          .borderRadius(6)
          .margin({ bottom: 8, left: 8, right: 8 })
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }

  /** 弹幕冲击 */
  @Builder
  renderDanmaku(template: TemplateStyle) {
    Stack({ alignContent: Alignment.Center }) {
      this.renderPreviewImage()
      // 深色蒙版
      Rect().width('100%').height('100%').fill('#000000').opacity(0.4)
      // 错位重影文字
      Text(this.getPreviewText())
        .fontSize(template.fontSize + 2)
        .fontColor('#FFFFFF')
        .fontWeight(template.fontWeight)
        .opacity(0.3)
        .position({ x: '52%', y: '52%' })
        .transform({ translate: { x: -50, y: -50 } })
      Text('>> ' + this.getPreviewText())
        .fontSize(template.fontSize)
        .fontColor(template.textColor)
        .fontWeight(template.fontWeight)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .height('100%')
  }

  /** 杂志拼贴 */
  @Builder
  renderCollage(template: TemplateStyle) {
    Stack({ alignContent: Alignment.TopStart }) {
      // 背景
      Rect().width('100%').height('100%').fill(template.bgColor)
      // 错位图片
      if (this.frame?.screenshotUri) {
        Image(this.getPreviewImageUri())
          .width('60%')
          .height('70%')
          .objectFit(ImageFit.Cover)
          .position({ x: '10%', y: '15%' })
          .borderRadius(6)
      }
      // 黄色装饰块
      Rect().width(20).height(60).fill(AppColors.ACCENT_PRIMARY)
        .position({ x: '75%', y: '20%' })
      // 文字
      Text(this.getPreviewText())
        .fontSize(template.fontSize)
        .fontColor(template.textColor)
        .fontWeight(template.fontWeight)
        .maxLines(2)
        .width('70%')
        .position({ x: '15%', y: '65%' })
    }
    .width('100%')
    .height('100%')
  }

  /** 留白边框 */
  @Builder
  renderBorder(template: TemplateStyle) {
    Column({ space: 8 }) {
      // 居中缩小的图片
      Stack({ alignContent: Alignment.Center }) {
        this.renderPreviewImage()
      }
      .width('70%')
      .aspectRatio(1)
      .borderRadius(6)
      .clip(true)
      // 底部文字
      Text(this.getPreviewText())
        .fontSize(template.fontSize)
        .fontColor(template.textColor)
        .fontWeight(template.fontWeight)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .letterSpacing(2)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  /** 左右分栏 */
  @Builder
  renderSplit(template: TemplateStyle) {
    Row() {
      // 左侧图片
      Stack({ alignContent: Alignment.Center }) {
        this.renderPreviewImage()
      }
      .width('45%')
      .height('100%')
      .clip(true)
      // 分割线
      Divider().vertical(true).color('#333333').margin({ left: 8, right: 8 })
      // 右侧文字
      Column({ space: 4 }) {
        Text('标题')
          .fontSize(template.fontSize + 1)
          .fontColor(template.textColor)
          .fontWeight(FontWeight.Bold)
        Text(this.getPreviewText())
          .fontSize(template.fontSize - 1)
          .fontColor(template.textColor)
          .opacity(0.7)
          .maxLines(3)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .padding(8)
  }

  // ---------- 公共辅助方法 ----------

  /** 渲染预览底图 */
  @Builder
  renderPreviewImage() {
    if (this.frame && this.frame.screenshotUri.length > 0) {
      Image(this.getPreviewImageUri())
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
    } else {
      Rect().width('100%').height('100%').fill('#333333')
    }
  }

  /** 获取预览图URI */
  private getPreviewImageUri(): string {
    return this.frame?.screenshotUri ?? ''
  }

  /** 获取预览文字 */
  private getPreviewText(): string {
    const text = this.frame?.momentText ?? '示例台词文字'
    return text.length > 12 ? text.substring(0, 12) + '...' : text
  }
}