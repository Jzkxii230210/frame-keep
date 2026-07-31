/**
 * FrameKeep（帧藏）- 卡片模板选择
 * 支持模板分类筛选、选中态反馈、我的模板入口
 */
import { router } from '@kit.ArkUI';
import { EMOTION_TAG_LABEL, RouteParams, RoutePath } from '../../common/Constants';
import { FrameItem, MockDataStore } from '../../common/MockData';
import { AppColors, AppFontSize, AppSpacing } from '../../common/Styles';

/** 模板分类 */
enum TemplateCategory {
  HEAL = 'heal',      // 治愈
  BURN = 'burn',      // 燃向
  SIMPLE = 'simple',  // 简约
  DANMU = 'danmu',    // 弹幕
  RETRO = 'retro'     // 复古
}

/** 模板类型定义 */
interface TemplateStyle {
  id: string
  name: string
  category: TemplateCategory
}

@Entry
@Component
struct TemplateSelect {
  private frameId: string = ''
  @State frame: FrameItem | undefined = undefined
  
  /** 当前选中的分类 */
  @State selectedCategory: TemplateCategory | undefined = undefined
  /** 当前选中的模板索引 */
  @State selectedTemplateIndex: number = -1
  
  /** 分类标签映射 */
  private categoryLabels: Record<string, string> = {
    [TemplateCategory.FILM]: '电影质感',
    [TemplateCategory.LIFE]: '生活记录',
    [TemplateCategory.TREND]: '潮流设计',
    [TemplateCategory.MINIMAL]: '极简高级'
  }
  
  /** 所有分类 */
  private categories: TemplateCategory[] = [
    TemplateCategory.FILM,
    TemplateCategory.LIFE,
    TemplateCategory.TREND,
    TemplateCategory.MINIMAL
  ]
  
  /** 8种模板样式定义 */
  private templates: TemplateStyle[] = [
    // 电影质感类
    { id: 'widescreen_film', name: '宽屏电影帧', category: TemplateCategory.FILM },
    { id: 'left_line_poster', name: '左竖线海报', category: TemplateCategory.FILM },
    // 燃向
    {
      name: '燃向冲击',
      bgColor: '#1A1A2E',
      textColor: '#FF4757',
      textStyle: { fontSize: 18, fontWeight: FontWeight.Bold, italic: false, shadow: true },
      layout: 'bottom',
      category: TemplateCategory.BURN
    },
    {
      name: '热血标语',
      bgColor: '#0D0D0D',
      textColor: '#FFD700',
      textStyle: { fontSize: 20, fontWeight: FontWeight.Bold, italic: false, shadow: true },
      layout: 'center',
      category: TemplateCategory.BURN
    },
    // 简约
    {
      name: '简约纯图',
      bgColor: '#FFFFFF',
      textColor: '#333333',
      textStyle: { fontSize: 10, fontWeight: FontWeight.Lighter, italic: false, shadow: false },
      layout: 'top',
      category: TemplateCategory.SIMPLE
    },
    {
      name: 'ins拼贴风',
      bgColor: '#F5F5DC',
      textColor: '#4A4A4A',
      textStyle: { fontSize: 11, fontWeight: FontWeight.Normal, italic: false, shadow: false },
      layout: 'split',
      category: TemplateCategory.SIMPLE
    },
    // 弹幕
    {
      name: '弹幕风格',
      bgColor: '#2D3436',
      textColor: '#00FF88',
      textStyle: { fontSize: 16, fontWeight: FontWeight.Bold, italic: false, shadow: true },
      layout: 'center',
      category: TemplateCategory.DANMU
    },
    // 复古
    {
      name: '电影字幕',
      bgColor: '#000000',
      textColor: '#FFD700',
      textStyle: { fontSize: 12, fontWeight: FontWeight.Normal, italic: false, shadow: false },
      layout: 'bottom',
      category: TemplateCategory.RETRO
    },
    {
      name: '黑白电影风',
      bgColor: '#1C1C1C',
      textColor: '#E0E0E0',
      textStyle: { fontSize: 14, fontWeight: FontWeight.Normal, italic: false, shadow: false },
      layout: 'center',
      category: TemplateCategory.RETRO
    },
    {
      name: '复古海报风',
      bgColor: '#D4A574',
      textColor: '#5D4037',
      textStyle: { fontSize: 16, fontWeight: FontWeight.Bold, italic: true, shadow: true },
      layout: 'bottom',
      category: TemplateCategory.RETRO
    }
  ]
  
  /** 获取当前筛选后的模板列表 */
  private getFilteredTemplates(): TemplateStyle[] {
    if (this.selectedCategory === undefined) {
      return this.templates
    }
    return this.templates.filter((t: TemplateStyle) => t.category === this.selectedCategory)
  }

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, string>
    this.frameId = params[RouteParams.FRAME_ID] ?? ''
    this.frame = MockDataStore.getFrameById(this.frameId)
  }

  build() {
    Column() {
      // 顶栏：返回 + 标题 + 我的模板入口
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
        .onClick(() => {
          router.back()
        })
        
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
          .onClick(() => {
            router.pushUrl({ url: RoutePath.MY_TEMPLATE })
          })
      }
      .width('100%')
      .padding({
        left: AppSpacing.PAGE_HORIZONTAL,
        right: AppSpacing.PAGE_HORIZONTAL,
        top: AppSpacing.LG,
        bottom: AppSpacing.SM
      })
      
      // 分类 Tabs
      Tabs({ barPosition: BarPosition.Start }) {
        TabContent() {
          this.templateGrid()
        }
        .tabBar('全部')
        
        ForEach(this.categories, (category: TemplateCategory) => {
          TabContent() {
            this.templateGrid()
          }
          .tabBar(this.categoryLabels[category])
        }, (category: TemplateCategory) => category)
      }
      .barMode(BarMode.Scrollable)
      .barBackgroundColor(AppColors.PAGE_BG)
      .layoutWeight(1)
      .onChange((index: number) => {
        // index 0 是全部，之后是各分类
        if (index === 0) {
          this.selectedCategory = undefined
        } else {
          this.selectedCategory = this.categories[index - 1]
        }
        // 切换分类时重置选中
        this.selectedTemplateIndex = -1
      })
      
      // 底部操作栏
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
                  params: { frameId: this.frameId, templateName: template.name }
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

  /** 模板网格 */
  @Builder
  templateGrid() {
    Grid() {
      ForEach(this.getFilteredTemplates(), (template: TemplateStyle, index: number) => {
        GridItem() {
          Column({ space: AppSpacing.SM }) {
            // 模板预览
            this.templatePreview(template)
            
            Text(template.name)
              .fontSize(AppFontSize.BODY_SM)
              .fontColor(AppColors.TEXT_PRIMARY)
          }
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
            // 点击选中/取消选中
            if (this.selectedTemplateIndex === index) {
              this.selectedTemplateIndex = -1
            } else {
              this.selectedTemplateIndex = index
            }
          })
        }
      }, (template: TemplateStyle) => template.name)
    }
    .columnsTemplate('1fr 1fr')
    .rowsGap(AppSpacing.MD)
    .columnsGap(AppSpacing.MD)
    .padding(AppSpacing.PAGE_HORIZONTAL)
  }

  /** 模板预览组件 */
  @Builder
  templatePreview(template: TemplateStyle) {
    Stack() {
      // 背景层
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(template.bgColor)
      
      // 截图层（如果有）
      if (this.frame && this.frame.screenshotUri.length > 0) {
        if (this.isRawFilePath(this.frame.screenshotUri)) {
          Image($rawfile(this.frame.screenshotUri))
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Cover)
            .opacity(0.3)
        } else {
          Image(this.frame.screenshotUri)
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Cover)
            .opacity(0.3)
        }
      }
      
      // 文字层（根据布局样式）
      if (template.layout === 'center') {
        Column() {
          Text(this.getPreviewText(template))
            .fontSize(template.textStyle.fontSize)
            .fontWeight(template.textStyle.fontWeight)
            .fontColor(template.textColor)
            .fontStyle(template.textStyle.italic ? FontStyle.Italic : FontStyle.Normal)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .padding(8)
      } else if (template.layout === 'bottom') {
        Column() {
          Blank()
          Text(this.getPreviewText(template))
            .fontSize(template.textStyle.fontSize)
            .fontWeight(template.textStyle.fontWeight)
            .fontColor(template.textColor)
            .fontStyle(template.textStyle.italic ? FontStyle.Italic : FontStyle.Normal)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .padding(8)
        }
        .width('100%')
        .height('100%')
      } else if (template.layout === 'top') {
        Column() {
          Text(this.getPreviewText(template))
            .fontSize(template.textStyle.fontSize)
            .fontWeight(template.textStyle.fontWeight)
            .fontColor(template.textColor)
            .fontStyle(template.textStyle.italic ? FontStyle.Italic : FontStyle.Normal)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .padding(8)
          Blank()
        }
        .width('100%')
        .height('100%')
      } else {
        // split 布局
        Column() {
          Blank()
          Row() {
            Column() {
              Text('📅')
                .fontSize(20)
              Text(this.getPreviewText(template))
                .fontSize(template.textStyle.fontSize)
                .fontWeight(template.textStyle.fontWeight)
                .fontColor(template.textColor)
                .fontStyle(template.textStyle.italic ? FontStyle.Italic : FontStyle.Normal)
                .maxLines(2)
                .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .padding(8)
          .backgroundColor('#40FFFFFF')
        }
        .width('100%')
        .height('100%')
      }
    }
    .width('100%')
    .height(100)
    .borderRadius(8)
    .clip(true)
  }

  /** 获取预览文字 */
  private getPreviewText(template: TemplateStyle): string {
    const text = this.frame?.momentText ?? '情绪文字'
    // 根据模板截取不同长度
    if (template.name === '治愈留白') {
      return text.length > 8 ? text.substring(0, 8) + '...' : text
    } else if (template.name === '燃向冲击' || template.name === '热血标语') {
      return text.length > 6 ? text.substring(0, 6) + '!' : text
    } else if (template.name === '弹幕风格') {
      return '>> ' + text.substring(0, 10)
    } else if (template.name === '黑白电影风') {
      return '「' + (text.length > 10 ? text.substring(0, 10) : text) + '」'
    } else if (template.name === '复古海报风') {
      return '★ ' + (text.length > 8 ? text.substring(0, 8) : text)
    }
    return text.length > 15 ? text.substring(0, 15) + '...' : text
  }

  /** 判断是否为 rawfile 路径 */
  private isRawFilePath(uri: string): boolean {
    return uri.length > 0 && !uri.startsWith('file://') && !uri.startsWith('datashare://')
  }
}
