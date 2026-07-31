/**
 * FrameKeep（帧藏）- 模板类型定义
 * 统一管理模板分类、版式类型、模板数据
 */

/** 模板四大分类 */
export enum TemplateCategory {
  FILM = 'film',      // 电影质感
  LIFE = 'life',      // 生活记录
  TREND = 'trend',    // 潮流设计
  MINIMAL = 'minimal' // 极简高级
}

/** 模板版式类型 */
export enum LayoutType {
  WIDESCREEN = 'widescreen',   // 宽屏电影帧
  LEFT_LINE = 'leftLine',      // 左竖线海报
  POLAROID = 'polaroid',       // 拍立得相框
  DIARY = 'diary',             // 手账日记
  DANMAKU = 'danmaku',         // 弹幕冲击
  COLLAGE = 'collage',         // 杂志拼贴
  BORDER = 'border',           // 留白边框
  SPLIT = 'split'              // 左右分栏
}

/** 模板完整数据结构 */
export interface TemplateStyle {
  id: string
  name: string
  category: TemplateCategory
  layoutType: LayoutType
  // 通用样式配置
  textColor: string
  bgColor: string
  fontSize: number
  fontWeight: FontWeight
}

/** 分类标签映射 */
export const CATEGORY_LABELS: Record<TemplateCategory, string> = {
  [TemplateCategory.FILM]: '电影质感',
  [TemplateCategory.LIFE]: '生活记录',
  [TemplateCategory.TREND]: '潮流设计',
  [TemplateCategory.MINIMAL]: '极简高级'
}

/** 8种真实版式模板定义 */
export const TEMPLATES: TemplateStyle[] = [
  // ========== 电影质感类 ==========
  {
    id: 'widescreen_film',
    name: '宽屏电影帧',
    category: TemplateCategory.FILM,
    layoutType: LayoutType.WIDESCREEN,
    textColor: '#FFFFFF',
    bgColor: '#000000',
    fontSize: 12,
    fontWeight: FontWeight.Normal
  },
  {
    id: 'left_line_poster',
    name: '左竖线海报',
    category: TemplateCategory.FILM,
    layoutType: LayoutType.LEFT_LINE,
    textColor: '#FFFFFF',
    bgColor: '#121212',
    fontSize: 14,
    fontWeight: FontWeight.Bold
  },
  // ========== 生活记录类 ==========
  {
    id: 'polaroid',
    name: '拍立得相框',
    category: TemplateCategory.LIFE,
    layoutType: LayoutType.POLAROID,
    textColor: '#333333',
    bgColor: '#FFFFFF',
    fontSize: 10,
    fontWeight: FontWeight.Normal
  },
  {
    id: 'diary',
    name: '手账日记',
    category: TemplateCategory.LIFE,
    layoutType: LayoutType.DIARY,
    textColor: '#5D4037',
    bgColor: '#F5F0E6',
    fontSize: 11,
    fontWeight: FontWeight.Normal
  },
  // ========== 潮流设计类 ==========
  {
    id: 'danmaku',
    name: '弹幕冲击',
    category: TemplateCategory.TREND,
    layoutType: LayoutType.DANMAKU,
    textColor: '#00FF88',
    bgColor: '#1A1A2E',
    fontSize: 14,
    fontWeight: FontWeight.Bold
  },
  {
    id: 'collage',
    name: '杂志拼贴',
    category: TemplateCategory.TREND,
    layoutType: LayoutType.COLLAGE,
    textColor: '#FFFFFF',
    bgColor: '#0F0F0F',
    fontSize: 15,
    fontWeight: FontWeight.Bold
  },
  // ========== 极简高级类 ==========
  {
    id: 'border',
    name: '留白边框',
    category: TemplateCategory.MINIMAL,
    layoutType: LayoutType.BORDER,
    textColor: '#E0E0E0',
    bgColor: '#1A1A1A',
    fontSize: 12,
    fontWeight: FontWeight.Lighter
  },
  {
    id: 'split',
    name: '左右分栏',
    category: TemplateCategory.MINIMAL,
    layoutType: LayoutType.SPLIT,
    textColor: '#FFFFFF',
    bgColor: '#121212',
    fontSize: 11,
    fontWeight: FontWeight.Normal
  }
]

/** 根据 ID 获取模板 */
export function getTemplateById(id: string): TemplateStyle | undefined {
  return TEMPLATES.find(t => t.id === id)
}

/** 根据分类获取模板列表 */
export function getTemplatesByCategory(category: TemplateCategory | 'all'): TemplateStyle[] {
  if (category === 'all') {
    return TEMPLATES
  }
  return TEMPLATES.filter(t => t.category === category)
}
