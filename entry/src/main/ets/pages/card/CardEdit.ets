/**
 * FrameKeep（帧藏）- 卡片编辑页
 * 功能：根据选中的模板版式，将文字应用到图片上，生成卡片
 */
import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { image } from '@kit.ImageKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { systemShare } from '@kit.ShareKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { fileUri } from '@kit.CoreFileKit';
import { RouteParams, RoutePath } from '../../common/Constants';
import { FrameItem, MockDataStore } from '../../common/MockData';
import { PageShell } from '../../common/components/PageShell';
import { AppColors, AppFontSize, AppSpacing } from '../../common/Styles';
import {
  LayoutType,
  TemplateStyle,
  getTemplateById
} from '../../common/TemplateTypes';
import { MediaExportUtil } from '../../common/utils/MediaExportUtil';

@Entry
@Component
struct CardEdit {
  private frameId: string = ''
  @State frame: FrameItem | undefined = undefined
  private templateId: string = ''
  @State template: TemplateStyle | undefined = undefined
  @State editText: string = ''

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, string>
    this.frameId = params[RouteParams.FRAME_ID] ?? ''
    this.templateId = params['templateId'] ?? ''
    this.frame = MockDataStore.getFrameById(this.frameId)
    this.template = getTemplateById(this.templateId)
    
    // 初始化文字内容
    if (this.frame) {
      this.editText = this.frame.momentText
    }
  }

  /**
   * 保存卡片到相册
   */
  private async saveCardToAlbum(): Promise<void> {
    try {
      // 1. 组件截图获取 PixelMap
      const pixelMap = await this.getUIContext().getComponentSnapshot().get('cardPreview', {
        scale: 2, // 2倍分辨率，提高清晰度
        waitUntilRenderFinished: true
      })

      if (!pixelMap) {
        promptAction.showToast({ message: '获取卡片截图失败' })
        return
      }

      // 2. 使用 MediaExportUtil 保存到相册
      const context = getContext(this) as common.UIAbilityContext
      const result = await MediaExportUtil.savePixelMapToGallery(context, pixelMap, 'jpeg', 95)

      if (result.success) {
        promptAction.showToast({ message: '卡片已保存到相册' })
        console.info('卡片保存成功：' + result.uri)
      } else {
        promptAction.showToast({ message: '保存失败：' + result.error })
        console.error('保存卡片失败：', result.error)
      }
      
    } catch (error) {
      const errMsg = error instanceof Error ? error.message : JSON.stringify(error)
      promptAction.showToast({ message: '保存失败：' + errMsg })
      console.error('保存卡片失败：', errMsg)
    }
  }

  /**
   * 分享卡片
   */
  private async shareCard(): Promise<void> {
    try {
      // 1. 组件截图获取 PixelMap
      const pixelMap = await this.getUIContext().getComponentSnapshot().get('cardPreview', {
        scale: 2,
        waitUntilRenderFinished: true
      })

      if (!pixelMap) {
        promptAction.showToast({ message: '获取卡片截图失败' })
        return
      }

      // 2. 将 PixelMap 打包为 JPEG
      const imagePacker = image.createImagePacker()
      const packOpts: image.PackingOption = {
        format: 'image/jpeg',
        quality: 95
      }
      const arrayBuffer = await imagePacker.packing(pixelMap, packOpts)

      // 3. 保存到临时文件
      const context = getContext(this) as common.UIAbilityContext
      const fileName = 'card_share_' + Date.now() + '.jpg'
      const tempFilePath = context.cacheDir + '/' + fileName
      
      const file = fs.openSync(tempFilePath, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY)
      fs.writeSync(file.fd, arrayBuffer)
      fs.closeSync(file)

      // 4. 获取文件 URI
      const uri = fileUri.getUriFromPath(tempFilePath)

      // 5. 创建分享数据
      const shareData: systemShare.SharedData = new systemShare.SharedData({
        utd: utd.UniformDataType.IMAGE,
        uri: uri,
        title: fileName
      })

      // 6. 调起系统分享面板
      const controller: systemShare.ShareController = new systemShare.ShareController(shareData)
      const uiContext = this.getUIContext()
      const abilityContext = uiContext.getHostContext() as common.UIAbilityContext
      
      controller.show(abilityContext, {
        previewMode: systemShare.SharePreviewMode.DETAIL,
        selectionMode: systemShare.SelectionMode.SINGLE
      })

      console.info('分享面板已打开')
      
    } catch (error) {
      const errMsg = error instanceof Error ? error.message : JSON.stringify(error)
      promptAction.showToast({ message: '分享失败：' + errMsg })
      console.error('分享卡片失败：', errMsg)
    }
  }

  build() {
    Column() {
      PageShell({
        title: `编辑 · ${this.template?.name ?? '模板'}`,
        content: () => { this.body() }
      })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  body() {
    Column({ space: AppSpacing.LG }) {
      // 卡片预览区域
      Column() {
        this.cardPreview()
      }
      .id('cardPreview') // 用于组件截图
      .width('100%')

      // 文字编辑区域
      TextArea({ placeholder: '输入你的文字...', text: $$this.editText })
        .width('100%')
        .height(120)
        .fontSize(AppFontSize.BODY)
        .fontColor(AppColors.TEXT_PRIMARY)
        .backgroundColor(AppColors.SURFACE_BG)
        .borderRadius(12)
        .padding(AppSpacing.MD)

      // 操作按钮
      Row({ space: AppSpacing.MD }) {
        // 使用 SaveButton 安全控件保存到相册
        SaveButton()
          .width('45%')
          .fontSize(AppFontSize.BODY)
          .fontColor(AppColors.PAGE_BG)
          .backgroundColor(AppColors.ACCENT_PRIMARY)
          .borderRadius(24)
          .height(44)
          .onClick(async (event: ClickEvent, result: SaveButtonOnClickResult) => {
            if (result === SaveButtonOnClickResult.SUCCESS) {
              await this.saveCardToAlbum()
            }
          })

        Button('分享')
          .width('45%')
          .fontSize(AppFontSize.BODY)
          .fontColor(AppColors.ACCENT_PRIMARY)
          .backgroundColor(AppColors.SURFACE_BG)
          .borderRadius(24)
          .height(44)
          .border({ width: 1, color: AppColors.ACCENT_PRIMARY })
          .onClick(async () => {
            await this.shareCard()
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .padding({
      left: AppSpacing.PAGE_HORIZONTAL,
      right: AppSpacing.PAGE_HORIZONTAL,
      top: AppSpacing.MD,
      bottom: AppSpacing.LG
    })
  }

  /** 卡片预览 - 根据模板版式渲染 */
  @Builder
  cardPreview() {
    if (this.template) {
      // 根据不同的版式类型渲染不同的卡片样式
      if (this.template.layoutType === LayoutType.WIDESCREEN) {
        this.renderWidescreen()
      } else if (this.template.layoutType === LayoutType.LEFT_LINE) {
        this.renderLeftLine()
      } else if (this.template.layoutType === LayoutType.POLAROID) {
        this.renderPolaroid()
      } else if (this.template.layoutType === LayoutType.DIARY) {
        this.renderDiary()
      } else if (this.template.layoutType === LayoutType.DANMAKU) {
        this.renderDanmaku()
      } else if (this.template.layoutType === LayoutType.COLLAGE) {
        this.renderCollage()
      } else if (this.template.layoutType === LayoutType.BORDER) {
        this.renderBorder()
      } else if (this.template.layoutType === LayoutType.SPLIT) {
        this.renderSplit()
      }
    }
  }

  /** 1. 宽屏电影帧：上下黑边 + 底部字幕 */
  @Builder
  renderWidescreen() {
    Column() {
      // 上黑边
      Row()
        .width('100%')
        .height('15%')
        .backgroundColor('#000000')

      // 画面区域
      Stack({ alignContent: Alignment.Center }) {
        this.renderImage()
      }
      .layoutWeight(1)

      // 下黑边 + 字幕
      Stack({ alignContent: Alignment.Center }) {
        Row()
          .width('100%')
          .height('100%')
          .backgroundColor('#000000')
        
        Text(this.getDisplayText())
          .fontSize(this.template?.fontSize ?? 12)
          .fontColor(this.template?.textColor ?? '#FFFFFF')
          .fontWeight(this.template?.fontWeight ?? FontWeight.Normal)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .padding({ left: 16, right: 16 })
      }
      .width('100%')
      .height('15%')
    }
    .width('100%')
    .height(200)
    .borderRadius(12)
    .clip(true)
  }

  /** 2. 左竖线海报：左侧装饰线 + 左对齐大文字 */
  @Builder
  renderLeftLine() {
    Row() {
      // 左侧装饰竖线
      Row()
        .width(4)
        .height('60%')
        .backgroundColor(AppColors.ACCENT_PRIMARY)

      // 文字区域
      Column({ space: 4 }) {
        Text(this.getDisplayText())
          .fontSize(this.template?.fontSize ?? 14)
          .fontColor(this.template?.textColor ?? '#FFFFFF')
          .fontWeight(this.template?.fontWeight ?? FontWeight.Bold)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text('—— 出处')
          .fontSize((this.template?.fontSize ?? 14) - 2)
          .fontColor(this.template?.textColor ?? '#FFFFFF')
          .opacity(0.6)
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
      .layoutWeight(1)
    }
    .width('100%')
    .height(200)
    .padding(12)
    .borderRadius(12)
    .backgroundColor(this.template?.bgColor ?? '#121212')
  }

  /** 3. 拍立得相框：白色宽边 + 底部小字 */
  @Builder
  renderPolaroid() {
    Column() {
      // 图片区域
      Stack({ alignContent: Alignment.Center }) {
        this.renderImage()
      }
      .layoutWeight(1)

      // 底部文字区域
      Row() {
        Text(this.getDisplayText())
          .fontSize(this.template?.fontSize ?? 10)
          .fontColor(this.template?.textColor ?? '#333333')
          .fontWeight(this.template?.fontWeight ?? FontWeight.Normal)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .height(40)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height(200)
    .padding(12)
    .borderRadius(12)
    .backgroundColor(this.template?.bgColor ?? '#FFFFFF')
  }

  /** 4. 手账日记：纸张背景 + 日期角标 */
  @Builder
  renderDiary() {
    Stack({ alignContent: Alignment.TopEnd }) {
      // 主内容区
      Column() {
        // 日期角标
        Row() {
          Text(this.getCurrentDate())
            .fontSize(10)
            .fontColor('#999999')
        }
        .width('100%')
        .justifyContent(FlexAlign.End)
        .margin({ bottom: 8 })

        // 图片区域
        Stack({ alignContent: Alignment.Center }) {
          this.renderImage()
        }
        .width('100%')
        .height(100)
        .borderRadius(8)

        // 文字区域
        Text(this.getDisplayText())
          .fontSize(this.template?.fontSize ?? 11)
          .fontColor(this.template?.textColor ?? '#5D4037')
          .fontWeight(this.template?.fontWeight ?? FontWeight.Normal)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 8 })
      }
      .width('100%')
      .height('100%')
      .padding(12)
    }
    .width('100%')
    .height(200)
    .borderRadius(12)
    .backgroundColor(this.template?.bgColor ?? '#F5F0E6')
  }

  /** 5. 弹幕冲击：错位重影文字 */
  @Builder
  renderDanmaku() {
    Stack() {
      // 背景图片
      this.renderImage()

      // 弹幕文字层（多层错位）
      Column() {
        Text(this.getDisplayText())
          .fontSize(this.template?.fontSize ?? 14)
          .fontColor('#00FF88')
          .fontWeight(FontWeight.Bold)
          .opacity(0.3)
          .offset({ x: 4, y: 0 })

        Text(this.getDisplayText())
          .fontSize(this.template?.fontSize ?? 14)
          .fontColor('#00FF88')
          .fontWeight(FontWeight.Bold)
          .opacity(0.6)
          .offset({ x: 2, y: 0 })

        Text(this.getDisplayText())
          .fontSize(this.template?.fontSize ?? 14)
          .fontColor(this.template?.textColor ?? '#00FF88')
          .fontWeight(this.template?.fontWeight ?? FontWeight.Bold)
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height(200)
    .borderRadius(12)
    .clip(true)
    .backgroundColor(this.template?.bgColor ?? '#1A1A2E')
  }

  /** 6. 杂志拼贴：几何色块 + 粗体标题 */
  @Builder
  renderCollage() {
    Stack() {
      // 背景图片
      this.renderImage()

      // 几何装饰色块
      Row()
        .width(80)
        .height(80)
        .backgroundColor('#FF6B6B')
        .opacity(0.8)
        .rotate({ angle: 45 })
        .position({ x: -20, y: -20 })

      Row()
        .width(60)
        .height(60)
        .backgroundColor('#4ECDC4')
        .opacity(0.8)
        .rotate({ angle: 30 })
        .position({ x: '80%', y: '70%' })

      // 文字层
      Column() {
        Text(this.getDisplayText())
          .fontSize(this.template?.fontSize ?? 15)
          .fontColor(this.template?.textColor ?? '#FFFFFF')
          .fontWeight(this.template?.fontWeight ?? FontWeight.Bold)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .padding(16)
    }
    .width('100%')
    .height(200)
    .borderRadius(12)
    .clip(true)
    .backgroundColor(this.template?.bgColor ?? '#0F0F0F')
  }

  /** 7. 留白边框：四周大面积留白 */
  @Builder
  renderBorder() {
    Column() {
      // 上留白
      Row().height('15%')

      // 内容区域
      Stack() {
        this.renderImage()
      }
      .width('70%')
      .layoutWeight(1)
      .borderRadius(8)

      // 下留白 + 文字
      Column() {
        Text(this.getDisplayText())
          .fontSize(this.template?.fontSize ?? 12)
          .fontColor(this.template?.textColor ?? '#E0E0E0')
          .fontWeight(this.template?.fontWeight ?? FontWeight.Lighter)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .height('15%')
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height(200)
    .borderRadius(12)
    .backgroundColor(this.template?.bgColor ?? '#1A1A1A')
  }

  /** 8. 左右分栏：左图右文 */
  @Builder
  renderSplit() {
    Row() {
      // 左侧图片
      Stack() {
        this.renderImage()
      }
      .width('50%')
      .height('100%')

      // 右侧文字
      Column() {
        Text(this.getDisplayText())
          .fontSize(this.template?.fontSize ?? 11)
          .fontColor(this.template?.textColor ?? '#FFFFFF')
          .fontWeight(this.template?.fontWeight ?? FontWeight.Normal)
          .maxLines(4)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('50%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .padding(16)
    }
    .width('100%')
    .height(200)
    .borderRadius(12)
    .clip(true)
    .backgroundColor(this.template?.bgColor ?? '#121212')
  }

  /** 渲染图片 */
  @Builder
  renderImage() {
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
    } else {
      // 占位图
      Column() {
        Text('📷')
          .fontSize(40)
          .fontColor(AppColors.TEXT_TERTIARY)
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor(AppColors.SURFACE_BG)
    }
  }

  /** 获取显示文字 */
  private getDisplayText(): string {
    return this.editText.length > 0 ? this.editText : '点击上方编辑文字'
  }

  /** 获取当前日期 */
  private getCurrentDate(): string {
    const now = new Date()
    const year = now.getFullYear()
    const month = (now.getMonth() + 1).toString().padStart(2, '0')
    const day = now.getDate().toString().padStart(2, '0')
    return `${year}.${month}.${day}`
  }

  /** 判断是否为 rawfile 路径 */
  private isRawFilePath(uri: string): boolean {
    return uri.length > 0 && !uri.startsWith('file://') && !uri.startsWith('datashare://')
  }
}
