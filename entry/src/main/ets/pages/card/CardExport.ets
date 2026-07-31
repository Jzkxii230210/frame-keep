/**
 * FrameKeep（帧藏）- 卡片导出分享
 */
import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { pasteboard } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { RouteParams, RoutePath } from '../../common/Constants';
import { FrameItem, MockDataStore } from '../../common/MockData';
import { PageShell } from '../../common/components/PageShell';
import { AppColors, AppFontSize, AppSpacing } from '../../common/Styles';
import { MediaExportUtil } from '../../common/utils/MediaExportUtil';

/** 模板样式定义 */
interface TemplateStyle {
  name: string
  bgColor: string
  textColor: string
  fontSize: number
  fontWeight: FontWeight
  italic: boolean
  shadow: boolean
  layout: 'center' | 'bottom' | 'top' | 'split'
}

@Entry
@Component
struct CardExport {
  private frameId: string = ''
  private templateName: string = ''
  @State frame: FrameItem | undefined = undefined
  
  /** 6种模板样式 */
  private templateStyles: TemplateStyle[] = [
    {
      name: '治愈留白',
      bgColor: '#E8F4F8',
      textColor: '#2C5F7C',
      fontSize: 16,
      fontWeight: FontWeight.Normal,
      italic: false,
      shadow: false,
      layout: 'center'
    },
    {
      name: '燃向冲击',
      bgColor: '#1A1A2E',
      textColor: '#FF4757',
      fontSize: 20,
      fontWeight: FontWeight.Bold,
      italic: false,
      shadow: true,
      layout: 'bottom'
    },
    {
      name: '电影字幕',
      bgColor: '#000000',
      textColor: '#FFD700',
      fontSize: 14,
      fontWeight: FontWeight.Normal,
      italic: false,
      shadow: false,
      layout: 'bottom'
    },
    {
      name: '简约纯图',
      bgColor: '#FFFFFF',
      textColor: '#333333',
      fontSize: 12,
      fontWeight: FontWeight.Lighter,
      italic: false,
      shadow: false,
      layout: 'top'
    },
    {
      name: '弹幕风格',
      bgColor: '#2D3436',
      textColor: '#00FF88',
      fontSize: 18,
      fontWeight: FontWeight.Bold,
      italic: false,
      shadow: true,
      layout: 'center'
    },
    {
      name: '心情日记',
      bgColor: '#FFF5E6',
      textColor: '#8B4513',
      fontSize: 15,
      fontWeight: FontWeight.Normal,
      italic: true,
      shadow: false,
      layout: 'split'
    }
  ]

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, string>
    this.frameId = params[RouteParams.FRAME_ID] ?? ''
    this.templateName = params['templateName'] ?? '治愈留白'
    this.frame = MockDataStore.getFrameById(this.frameId)
  }

  /** 获取当前模板样式 */
  private getTemplateStyle(): TemplateStyle {
    return this.templateStyles.find(t => t.name === this.templateName) ?? this.templateStyles[0]
  }

  build() {
    Column() {
      PageShell({ title: '保存与分享', content: () => { this.body() } })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  body() {
    Column({ space: AppSpacing.LG }) {
      // 卡片预览
      this.cardPreview()
      
      Text(`${this.templateName} 模板`)
        .fontColor(AppColors.TEXT_TERTIARY)
        .fontSize(AppFontSize.CAPTION)

      Toggle({ type: ToggleType.Switch, isOn: true })
        .selectedColor(AppColors.ACCENT_PRIMARY)
      Text('保存为我的模板')
        .fontColor(AppColors.TEXT_SECONDARY)
        .fontSize(AppFontSize.BODY_SM)

      // 使用 SaveButton 安全控件保存到相册
      SaveButton()
        .width('100%')
        .onClick(async (event: ClickEvent, result: SaveButtonOnClickResult) => {
          if (result === SaveButtonOnClickResult.SUCCESS) {
            await this.saveCardToGallery()
          } else {
            promptAction.showToast({ message: '授权失败，无法保存到相册' })
          }
        })

      Button('复制分享文案')
        .width('100%')
        .backgroundColor(AppColors.SURFACE_BG)
        .fontColor(AppColors.TEXT_PRIMARY)
        .onClick(() => {
          const frame = MockDataStore.getFrameById(this.frameId)
          const text = frame?.momentText ?? '帧藏 · 收藏触动你的每一帧'
          const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text)
          pasteboard.getSystemPasteboard().setData(data)
          promptAction.showToast({ message: '文案已复制' })
        })

      Button('完成')
        .width('100%')
        .backgroundColor(AppColors.SURFACE_BG)
        .fontColor(AppColors.ACCENT_PRIMARY)
        .onClick(() => {
          // 完成后返回到主页面（Index），自动显示收藏 Tab
          // 获取导航栈长度，计算需要返回的次数
          const stackLength = parseInt(router.getLength())
          // 需要返回 stackLength - 1 次才能回到 Index 页面
          for (let i = 0; i < stackLength - 1; i++) {
            router.back()
          }
        })
    }
    .padding(AppSpacing.PAGE_HORIZONTAL)
  }

  /** 卡片预览（根据模板样式渲染） */
  @Builder
  cardPreview() {
    Stack() {
      // 背景层
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(this.getTemplateStyle().bgColor)
      
      // 截图层
      if (this.frame && this.frame.screenshotUri.length > 0) {
        if (this.isRawFilePath(this.frame.screenshotUri)) {
          Image($rawfile(this.frame.screenshotUri))
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Cover)
        } else {
          Image(this.frame.screenshotUri)
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Cover)
        }
      }
      
      // 文字层
      this.textLayer()
    }
    .width('100%')
    .height(240)
    .borderRadius(12)
    .clip(true)
    .id('cardPreview') // 添加组件 ID 用于截图
  }

  /** 保存卡片到相册 */
  private async saveCardToGallery(): Promise<void> {
    try {
      // 获取组件截图
      const pixelMap = await this.getUIContext().getComponentSnapshot().get('cardPreview', {
        scale: 1.0,
        waitUntilRenderFinished: true
      })
      
      // 获取上下文
      const context = getContext(this) as common.UIAbilityContext
      
      // 保存到相册
      const result = await MediaExportUtil.savePixelMapToGallery(context, pixelMap, 'jpeg', 95)
      
      if (result.success) {
        promptAction.showToast({ message: '卡片已保存到相册' })
      } else {
        promptAction.showToast({ message: result.error || '保存失败' })
      }
    } catch (error) {
      console.error('保存卡片失败:', error)
      promptAction.showToast({ message: '保存失败，请重试' })
    }
  }

  /** 文字层（根据模板布局） */
  @Builder
  textLayer() {
    // 居中布局
    if (this.getTemplateStyle().layout === 'center') {
      Column() {
        Text(this.frame?.momentText ?? '帧藏 · 收藏触动你的每一帧')
          .fontSize(this.getTemplateStyle().fontSize)
          .fontWeight(this.getTemplateStyle().fontWeight)
          .fontColor(this.getTemplateStyle().textColor)
          .fontStyle(this.getTemplateStyle().italic ? FontStyle.Italic : FontStyle.Normal)
          .textShadow(this.getTemplateStyle().shadow ? { radius: 4, color: '#80000000', offsetX: 2, offsetY: 2 } : undefined)
          .maxLines(3)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .padding(16)
    } else if (this.getTemplateStyle().layout === 'bottom') {
      // 底部布局
      Column() {
        Blank()
        Column() {
          Text(this.frame?.momentText ?? '帧藏 · 收藏触动你的每一帧')
            .fontSize(this.getTemplateStyle().fontSize)
            .fontWeight(this.getTemplateStyle().fontWeight)
            .fontColor(this.getTemplateStyle().textColor)
            .fontStyle(this.getTemplateStyle().italic ? FontStyle.Italic : FontStyle.Normal)
            .textShadow(this.getTemplateStyle().shadow ? { radius: 4, color: '#80000000', offsetX: 2, offsetY: 2 } : undefined)
            .maxLines(3)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 16 })
        .backgroundColor('linear-gradient(180deg, transparent, #60000000)')
      }
      .width('100%')
      .height('100%')
    } else if (this.getTemplateStyle().layout === 'top') {
      // 顶部布局
      Column() {
        Column() {
          Text(this.frame?.momentText ?? '帧藏 · 收藏触动你的每一帧')
            .fontSize(this.getTemplateStyle().fontSize)
            .fontWeight(this.getTemplateStyle().fontWeight)
            .fontColor(this.getTemplateStyle().textColor)
            .fontStyle(this.getTemplateStyle().italic ? FontStyle.Italic : FontStyle.Normal)
            .maxLines(3)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#40FFFFFF')
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
              .fontSize(24)
            Text(this.frame?.momentText ?? '帧藏 · 收藏触动你的每一帧')
              .fontSize(this.getTemplateStyle().fontSize)
              .fontWeight(this.getTemplateStyle().fontWeight)
              .fontColor(this.getTemplateStyle().textColor)
              .fontStyle(this.getTemplateStyle().italic ? FontStyle.Italic : FontStyle.Normal)
              .maxLines(3)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .margin({ top: 8 })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#60FFFFFF')
      }
      .width('100%')
      .height('100%')
    }
  }

  /** 判断是否为 rawfile 路径 */
  private isRawFilePath(uri: string): boolean {
    return uri.length > 0 && !uri.startsWith('file://') && !uri.startsWith('datashare://')
  }
}
