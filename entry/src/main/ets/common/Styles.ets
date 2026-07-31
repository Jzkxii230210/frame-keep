/**
 * FrameKeep（帧藏）- 公共样式定义
 *
 * 统一管理间距、圆角、字号与常用 @Extend 样式，
 * 保证全应用简约深色、电影质感视觉一致。
 * 颜色常量在此定义 hex 值，步骤 3 将同步写入 color.json 资源。
 */

/**
 * 应用色板（深色主题 · 电影质感）
 * 主色深灰 + 暖白强调，适配情绪向收藏工具调性
 */
export class AppColors {
  /** 页面主背景（近黑） */
  static readonly PAGE_BG: string = '#0A0A0B'
  /** 卡片/内容区表面色 */
  static readonly SURFACE_BG: string = '#141416'
  /** 底部 Tab 栏背景 */
  static readonly TAB_BAR_BG: string = '#111113'
  /** Tab 栏分割线 */
  static readonly TAB_DIVIDER: string = '#1E1E22'
  /** 主文字（暖白） */
  static readonly TEXT_PRIMARY: string = '#F5F0E8'
  /** 次要文字 */
  static readonly TEXT_SECONDARY: string = '#8E8E93'
  /** 三级/占位文字 */
  static readonly TEXT_TERTIARY: string = '#6B6B70'
  /** 主强调色（影院金） */
  static readonly ACCENT_PRIMARY: string = '#E8B923'
  /** 次强调/选中态辅助 */
  static readonly ACCENT_WARM: string = '#F5F0E8'
  /** 来源角标背景 */
  static readonly BADGE_BG: string = '#1E1E22'
  /** 分割线 */
  static readonly DIVIDER: string = '#2A2A2E'
  /** 危险/删除 */
  static readonly DANGER: string = '#FF453A'
  /** 成功态 */
  static readonly SUCCESS: string = '#30D158'
}

/** 间距体系（vp） */
export class AppSpacing {
  static readonly XS: number = 4
  static readonly SM: number = 8
  static readonly MD: number = 12
  static readonly LG: number = 16
  static readonly XL: number = 24
  static readonly XXL: number = 32
  /** 页面左右安全边距 */
  static readonly PAGE_HORIZONTAL: number = 16
  /** 列表项垂直间距 */
  static readonly LIST_ITEM_GAP: number = 12
}

/** 圆角体系（vp） */
export class AppRadius {
  static readonly SM: number = 6
  static readonly MD: number = 10
  static readonly LG: number = 14
  static readonly XL: number = 20
  /** 卡片统一圆角 */
  static readonly CARD: number = 12
}

/** 字号体系（fp） */
export class AppFontSize {
  static readonly CAPTION: number = 11
  static readonly BODY_SM: number = 13
  static readonly BODY: number = 15
  static readonly SUBTITLE: number = 17
  static readonly TITLE: number = 20
  static readonly HEADLINE: number = 24
  static readonly DISPLAY: number = 28
}

/** 字重常用值封装，便于页面引用 */
export class AppFontWeight {
  static readonly REGULAR: FontWeight = FontWeight.Regular
  static readonly MEDIUM: FontWeight = FontWeight.Medium
  static readonly BOLD: FontWeight = FontWeight.Bold
}

/** 底部 Tab 栏高度 */
export const TAB_BAR_HEIGHT: number = 56

/** 统一顶栏高度（PageShell 使用） */
export const PAGE_HEADER_HEIGHT: number = 48

/**
 * 扩展 Text：页面大标题
 */
@Extend(Text)
function textHeadline() {
  .fontSize(AppFontSize.HEADLINE)
  .fontWeight(AppFontWeight.BOLD)
  .fontColor(AppColors.TEXT_PRIMARY)
}

/**
 * 扩展 Text：区块标题
 */
@Extend(Text)
function textTitle() {
  .fontSize(AppFontSize.TITLE)
  .fontWeight(AppFontWeight.MEDIUM)
  .fontColor(AppColors.TEXT_PRIMARY)
}

/**
 * 扩展 Text：正文
 */
@Extend(Text)
function textBody() {
  .fontSize(AppFontSize.BODY)
  .fontWeight(AppFontWeight.REGULAR)
  .fontColor(AppColors.TEXT_PRIMARY)
}

/**
 * 扩展 Text：次要说明
 */
@Extend(Text)
function textSecondary() {
  .fontSize(AppFontSize.BODY_SM)
  .fontWeight(AppFontWeight.REGULAR)
  .fontColor(AppColors.TEXT_SECONDARY)
}

/**
 * 扩展 Text：占位/空态提示
 */
@Extend(Text)
function textHint() {
  .fontSize(AppFontSize.BODY_SM)
  .fontWeight(AppFontWeight.REGULAR)
  .fontColor(AppColors.TEXT_TERTIARY)
}

/**
 * 扩展 Column：页面根容器（全屏深色背景）
 */
@Extend(Column)
function pageRoot() {
  .width('100%')
  .height('100%')
  .backgroundColor(AppColors.PAGE_BG)
}

/**
 * 扩展 Column：卡片容器
 */
@Extend(Column)
function cardSurface() {
  .backgroundColor(AppColors.SURFACE_BG)
  .borderRadius(AppRadius.CARD)
  .padding(AppSpacing.LG)
}
