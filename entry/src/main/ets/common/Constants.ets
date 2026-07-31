/**
 * FrameKeep（帧藏）- 全局常量配置
 *
 * 集中管理路由路径、来源类型、情绪标签、时长约束、导出预设等，
 * 避免魔法字符串分散在各页面，便于统一维护与跳转。
 */

/** 内容来源类型：情绪从哪来 */
export enum SourceType {
  /** 影视 */
  FILM = 'film',
  /** 动漫 */
  ANIME = 'anime',
  /** 生活随拍、随手记录 */
  LIFE = 'life',
  /** 其他自定义来源 */
  OTHER = 'other'
}

/** 情绪标签：与 BGM 分类一一对应，跨所有来源通用 */
export enum EmotionTag {
  /** 治愈 */
  HEAL = 'heal',
  /** 燃向 */
  BURN = 'burn',
  /** 伤感 */
  SAD = 'sad',
  /** 搞笑 */
  FUNNY = 'funny'
}

/** 合集类型：区分不同内容形式 */
export enum AlbumType {
  /** 图文：静态图片+文字 */
  IMAGE_TEXT = 'image_text',
  /** 视频混剪：多段视频剪辑 */
  VIDEO_MIX = 'video_mix',
  /** 混合：图文+视频 */
  MIXED = 'mixed'
}

/** 导出平台预设标识 */
export enum ExportPresetId {
  /** 朋友圈：1:1，最长 15 秒 */
  WECHAT_MOMENTS = 'wechat_moments',
  /** 小红书：9:16，最长 60 秒 */
  XIAOHONGSHU = 'xiaohongshu',
  /** 高清存档：原比例 1080p */
  ARCHIVE_HD = 'archive_hd'
}

/**
 * 路由路径常量
 * 与 main_pages.json 中注册的页面路径保持一致（步骤 8 统一注册）
 */
export class RoutePath {
  /** 主入口：底部 Tab 导航页 */
  static readonly INDEX: string = 'pages/Index'
  /** 登录注册模块 */
  static readonly LOGIN: string = 'pages/auth/LoginPage'
  static readonly REGISTER: string = 'pages/auth/RegisterPage'
  /** 收藏模块 */
  static readonly COLLECT_INDEX: string = 'pages/collect/CollectIndex'
  static readonly IMPORT_PAGE: string = 'pages/collect/ImportPage'
  static readonly TAG_MANAGE: string = 'pages/collect/TagManage'
  static readonly MATERIAL_DETAIL: string = 'pages/collect/MaterialDetail'
  static readonly RECYCLE_BIN: string = 'pages/collect/RecycleBin'
  /** 创作模块 */
  static readonly CREATE_HUB: string = 'pages/create/CreateHub'
  /** 静态卡片模块 */
  static readonly TEMPLATE_SELECT: string = 'pages/card/TemplateSelect'
  static readonly CARD_EDIT: string = 'pages/card/CardEdit'
  static readonly CARD_EXPORT: string = 'pages/card/CardExport'
  static readonly MY_TEMPLATE: string = 'pages/card/MyTemplate'
  static readonly CARD_MANAGE: string = 'pages/create/CardManage'
  /** 动态片段模块 */
  static readonly VIDEO_CLIP: string = 'pages/video/VideoClip'
  static readonly SUBTITLE_EDIT: string = 'pages/video/SubtitleEdit'
  static readonly AUDIO_CONFIG: string = 'pages/video/AudioConfig'
  static readonly VIDEO_EXPORT: string = 'pages/video/VideoExport'
  /** 发现模块 */
  static readonly DISCOVER_INDEX: string = 'pages/discover/DiscoverIndex'
  static readonly TOPIC_DETAIL: string = 'pages/discover/TopicDetail'
  static readonly FILM_LIST: string = 'pages/discover/FilmList'
  static readonly SCENE_LIBRARY_DETAIL: string = 'pages/discover/SceneLibraryDetail'
  /** 灵感合集模块 */
  static readonly ALBUM_INDEX: string = 'pages/album/AlbumIndex'
  static readonly ALBUM_EDIT: string = 'pages/album/AlbumEdit'
  static readonly ALBUM_PREVIEW: string = 'pages/album/AlbumPreview'
  /** 个人中心模块 */
  static readonly PROFILE_INDEX: string = 'pages/profile/ProfileIndex'
  static readonly SETTING_PAGE: string = 'pages/profile/SettingPage'
  static readonly HELP_FEEDBACK: string = 'pages/profile/HelpFeedback'
  static readonly DATA_STATISTICS: string = 'pages/profile/DataStatisticsPage'
}

/** 来源类型中文展示名 */
export const SOURCE_TYPE_LABEL: Record<string, string> = {
  [SourceType.FILM]: '影视',
  [SourceType.ANIME]: '动漫',
  [SourceType.LIFE]: '生活',
  [SourceType.OTHER]: '其他'
}

/** 情绪标签中文展示名 */
export const EMOTION_TAG_LABEL: Record<string, string> = {
  [EmotionTag.HEAL]: '治愈',
  [EmotionTag.BURN]: '燃向',
  [EmotionTag.SAD]: '伤感',
  [EmotionTag.FUNNY]: '搞笑'
}

/** 导出预设中文展示名 */
export const EXPORT_PRESET_LABEL: Record<string, string> = {
  [ExportPresetId.WECHAT_MOMENTS]: '朋友圈',
  [ExportPresetId.XIAOHONGSHU]: '小红书',
  [ExportPresetId.ARCHIVE_HD]: '高清存档'
}

/**
 * 片段时长约束（毫秒）
 * 适配「30 秒出片」产品定位，限制高光片段在 15s–60s
 */
export class ClipDuration {
  /** 最短片段：15 秒 */
  static readonly MIN_MS: number = 15 * 1000
  /** 最长片段：60 秒 */
  static readonly MAX_MS: number = 60 * 1000
  /** 默认截取长度：30 秒 */
  static readonly DEFAULT_MS: number = 30 * 1000
}

/** 路由跳转时传递参数的 Key，统一命名避免拼写错误 */
export class RouteParams {
  /** 情绪帧条目 ID */
  static readonly FRAME_ID: string = 'frameId'
  /** 来源类型（导入页预选） */
  static readonly SOURCE_TYPE: string = 'sourceType'
  /** 专题 ID（发现模块） */
  static readonly TOPIC_ID: string = 'topicId'
  /** 合集 ID */
  static readonly ALBUM_ID: string = 'albumId'
}

/** 应用级固定文案 */
export class AppConst {
  /** 应用中文名 */
  static readonly APP_NAME: string = '帧藏'
  /** 应用英文名 */
  static readonly APP_NAME_EN: string = 'FrameKeep'
  /** 品牌 Slogan */
  static readonly SLOGAN: string = '收藏触动你的每一帧'
}
