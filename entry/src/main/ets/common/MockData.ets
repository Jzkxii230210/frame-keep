/**
 * FrameKeep（帧藏）- 本地数据层
 *
 * 统一管理「情绪帧 FrameItem」的增删改查、搜索、筛选与回收站。
 * 使用 Preferences 持久化存储，支持应用重启后数据恢复。
 */

import { AlbumType, EmotionTag, ExportPresetId, SourceType } from './Constants'
import { MediaAssets } from './utils/MediaAssetsManager'
import { prefUtil } from './utils/PreferencesUtil'

// 持久化存储的 key
const PREF_KEY_FRAMES = 'frame_list'
const PREF_KEY_INITIALIZED = 'data_initialized'
const PREF_KEY_VERSION = 'data_version'
const PREF_KEY_ALBUMS = 'album_list'
const PREF_KEY_SCENE_LIBRARIES = 'scene_library_data'

// 数据版本号（修改种子数据时需要更新此版本号）
const DATA_VERSION = 5

/**
 * 情绪帧收藏条目（图影联动核心实体）
 * 不限影视——影视、直播、生活随拍等一切情绪来源均用此结构
 */
export interface FrameItem {
  /** 唯一标识 */
  id: string
  /** 内容来源类型 */
  sourceType: SourceType
  /** 来源名称：剧名 / 直播间 / 场景地点 / 自定义 */
  sourceTitle: string
  /** 情绪文字：台词、弹幕、心情笔记等 */
  momentText: string
  /** 情绪标签，用于 BGM 匹配与筛选 */
  emotion: EmotionTag
  /** 用户自定义标签 */
  tags: string[]
  /** 截图/照片 URI（可为空） */
  screenshotUri: string
  /** 视频/录屏 URI（可为空） */
  videoUri: string
  /** 片段起始时间（毫秒） */
  clipStartMs: number
  /** 片段结束时间（毫秒） */
  clipEndMs: number
  /** 图影主绑定条目 ID（双向关联） */
  linkedItemId: string
  /** 可编辑字幕/心情字轨道文案 */
  subtitleText: string
  /** 当前搭配的 BGM ID */
  bgmId: string
  /** 导出预设 ID */
  exportPreset: string
  /** 是否在回收站 */
  inRecycleBin: boolean
  /** 最后更新时间戳 */
  updatedAt: number
}

/** BGM 条目（Mock 内置轻量音频库 metadata） */
export interface BgmItem {
  id: string
  name: string
  emotion: EmotionTag
  /** 是否为内置免版税占位曲 */
  isBuiltIn: boolean
}

/** 发现页情绪专题 */
export interface EmotionTopic {
  id: string
  title: string
  description: string
  coverColor: string
  /** 情绪标签 */
  emotion?: EmotionTag
  /** 专题内示例 FrameItem ID 列表 */
  frameIds: string[]
}

/** 灵感合集 */
export interface Album {
  /** 合集唯一标识 */
  id: string
  /** 合集名称 */
  name: string
  /** 合集描述 */
  description: string
  /** 封面图 URI（可为空，使用默认封面） */
  coverUri: string
  /** 合集类型 */
  type?: AlbumType
  /** 合集内情绪帧 ID 列表 */
  frameIds: string[]
  /** 创建时间戳 */
  createdAt: number
  /** 最后更新时间戳 */
  updatedAt: number
}

/**
 * 生成唯一 ID（简易 Mock 用，正式环境可换 UUID）
 */
function generateId(): string {
  return `frame_${Date.now()}_${Math.floor(Math.random() * 10000)}`
}

/** 内置 BGM Mock 数据 */
const BGM_LIST: BgmItem[] = [
  { id: 'bgm_heal_1', name: '晚风与树影', emotion: EmotionTag.HEAL, isBuiltIn: true },
  { id: 'bgm_heal_2', name: '温柔留白', emotion: EmotionTag.HEAL, isBuiltIn: true },
  { id: 'bgm_burn_1', name: '破晓前奏', emotion: EmotionTag.BURN, isBuiltIn: true },
  { id: 'bgm_burn_2', name: '逆风而行', emotion: EmotionTag.BURN, isBuiltIn: true },
  { id: 'bgm_sad_1', name: '雨夜独白', emotion: EmotionTag.SAD, isBuiltIn: true },
  { id: 'bgm_sad_2', name: '未寄出的信', emotion: EmotionTag.SAD, isBuiltIn: true },
  { id: 'bgm_funny_1', name: '搞怪节拍', emotion: EmotionTag.FUNNY, isBuiltIn: true },
  { id: 'bgm_funny_2', name: '轻松一下', emotion: EmotionTag.FUNNY, isBuiltIn: true }
]

/**
 * 跨来源种子数据（8 条）
 * 刻意混合影视、直播、生活、其他，避免 Demo 呈现「只做影视」的观感
 * 图片和视频素材从 resources/rawfile 加载
 */
const SEED_FRAMES: FrameItem[] = [
  {
    id: 'frame_seed_001',
    sourceType: SourceType.FILM,
    sourceTitle: '肖申克的救赎',
    momentText: '希望是美好的，也许是人间至善，而美好的事物永不消逝。',
    emotion: EmotionTag.HEAL,
    tags: ['经典', '台词'],
    screenshotUri: MediaAssets.HEAL_IMAGES.IMG_001, // 治愈系图片1
    videoUri: '', // 暂无视频文件
    clipStartMs: 0,
    clipEndMs: 30000,
    linkedItemId: 'frame_seed_001',
    subtitleText: '希望是美好的，也许是人间至善，而美好的事物永不消逝。',
    bgmId: 'bgm_heal_1',
    exportPreset: ExportPresetId.WECHAT_MOMENTS,
    inRecycleBin: false,
    updatedAt: Date.now() - 86400000 * 1
  },
  {
    id: 'frame_seed_002',
    sourceType: SourceType.ANIME,
    sourceTitle: '进击的巨人',
    momentText: '心を放せ、全てはこの一瞬のために。',
    emotion: EmotionTag.BURN,
    tags: ['动漫', '燃'],
    screenshotUri: MediaAssets.BURN_IMAGES.IMG_001, // 燃向图片1
    videoUri: '', // 暂无视频文件
    clipStartMs: 5000,
    clipEndMs: 35000,
    linkedItemId: 'frame_seed_002',
    subtitleText: '心を放せ、全てはこの一瞬のために。',
    bgmId: 'bgm_burn_1',
    exportPreset: ExportPresetId.XIAOHONGSHU,
    inRecycleBin: false,
    updatedAt: Date.now() - 86400000 * 2
  },
  {
    id: 'frame_seed_003',
    sourceType: SourceType.FILM,
    sourceTitle: '泰坦尼克号',
    momentText: 'You jump, I jump.',
    emotion: EmotionTag.SAD,
    tags: ['经典', '爱情'],
    screenshotUri: MediaAssets.SAD_IMAGES.IMG_001, // 伤感图片1
    videoUri: '', // 暂无视频文件
    clipStartMs: 0,
    clipEndMs: 25000,
    linkedItemId: 'frame_seed_003',
    subtitleText: 'You jump, I jump.',
    bgmId: 'bgm_sad_1',
    exportPreset: ExportPresetId.WECHAT_MOMENTS,
    inRecycleBin: false,
    updatedAt: Date.now() - 86400000 * 3
  },
  {
    id: 'frame_seed_004',
    sourceType: SourceType.ANIME,
    sourceTitle: '蜡笔小新',
    momentText: '动感超人的必杀技！',
    emotion: EmotionTag.FUNNY,
    tags: ['搞笑', '童年'],
    screenshotUri: MediaAssets.FUNNY_IMAGES.IMG_001, // 搞笑图片1
    videoUri: '', // 暂无视频文件
    clipStartMs: 0,
    clipEndMs: 15000,
    linkedItemId: 'frame_seed_004',
    subtitleText: '动感超人的必杀技！',
    bgmId: 'bgm_funny_1',
    exportPreset: ExportPresetId.XIAOHONGSHU,
    inRecycleBin: false,
    updatedAt: Date.now() - 86400000 * 4
  },
  {
    id: 'frame_seed_005',
    sourceType: SourceType.LIFE,
    sourceTitle: '家附近的海边',
    momentText: '风很大，但那一刻突然就不焦虑了。',
    emotion: EmotionTag.HEAL,
    tags: ['旅行', '海边', '随拍'],
    screenshotUri: MediaAssets.HEAL_IMAGES.IMG_002 || MediaAssets.HEAL_IMAGES.IMG_001, // 治愈系图片2
    videoUri: '',
    clipStartMs: 0,
    clipEndMs: 20000,
    linkedItemId: 'frame_seed_005',
    subtitleText: '风很大，但那一刻突然就不焦虑了。',
    bgmId: 'bgm_heal_1',
    exportPreset: ExportPresetId.XIAOHONGSHU,
    inRecycleBin: false,
    updatedAt: Date.now() - 86400000 * 5
  },
  {
    id: 'frame_seed_008',
    sourceType: SourceType.ANIME,
    sourceTitle: '千与千寻',
    momentText: '不管前方的路有多苦，只要走的方向正确，都比站在原地更接近幸福。',
    emotion: EmotionTag.HEAL,
    tags: ['宫崎骏', '台词'],
    screenshotUri: MediaAssets.HEAL_IMAGES.IMG_003 || MediaAssets.HEAL_IMAGES.IMG_001, // 治愈系图片3
    videoUri: '',
    clipStartMs: 0,
    clipEndMs: 0,
    linkedItemId: 'frame_seed_008',
    subtitleText: '不管前方的路有多苦，只要走的方向正确，都比站在原地更接近幸福。',
    bgmId: 'bgm_heal_1',
    exportPreset: ExportPresetId.ARCHIVE_HD,
    inRecycleBin: false,
    updatedAt: Date.now() - 86400000 * 8
  }
]

/** 发现页专题 Mock */
const EMOTION_TOPICS: EmotionTopic[] = [
  {
    id: 'topic_001',
    title: '雨天的情绪',
    description: '影视、生活里那些和雨有关的瞬间',
    coverColor: '#2C3E50',
    emotion: EmotionTag.SAD,
    frameIds: ['frame_seed_001', 'frame_seed_005']
  },
  {
    id: 'topic_002',
    title: '那些燃起来的瞬间',
    description: '不限来源，只要此刻血液沸腾',
    coverColor: '#4A1942',
    emotion: EmotionTag.BURN,
    frameIds: ['frame_seed_002']
  }
]

/** 种子合集数据 */
const SEED_ALBUMS: Album[] = [
  {
    id: 'album_seed_001',
    name: '雨 day 情绪集',
    description: '雨天相关的情绪帧合集',
    coverUri: '',
    type: AlbumType.IMAGE_TEXT,
    frameIds: ['frame_seed_001', 'frame_seed_005'],
    createdAt: Date.now() - 86400000 * 10,
    updatedAt: Date.now() - 86400000 * 5
  },
  {
    id: 'album_seed_002',
    name: '直播高光混剪',
    description: '直播中的精彩瞬间',
    coverUri: '',
    type: AlbumType.VIDEO_MIX,
    frameIds: ['frame_seed_002'],
    createdAt: Date.now() - 86400000 * 8,
    updatedAt: Date.now() - 86400000 * 3
  },
  {
    id: 'album_seed_003',
    name: '生活碎片 2024',
    description: '2024年的生活记录',
    coverUri: '',
    type: AlbumType.MIXED,
    frameIds: ['frame_seed_005'],
    createdAt: Date.now() - 86400000 * 6,
    updatedAt: Date.now() - 86400000 * 2
  }
]

/**
 * 帧藏本地数据仓库（单例式静态类）
 * 全应用通过 MockDataStore 读写 FrameItem，保证数据一致
 * 使用 Preferences 持久化存储
 */
export class MockDataStore {
  /** 内存中的情绪帧列表（可变） */
  private static frameList: FrameItem[] = []
  
  /** 内存中的合集列表（可变） */
  private static albumList: Album[] = []
  
  /** 内存中的场景素材库数据（可变）- 存储每个场景素材库的 frameId 列表 */
  private static sceneLibraryData: Record<string, string[]> = {}
  
  /** 是否已初始化 */
  private static initialized: boolean = false

  /**
   * 初始化数据（从 Preferences 加载或使用种子数据）
   * 在应用启动时调用
   */
  static async init(): Promise<void> {
    if (MockDataStore.initialized) {
      return
    }
    
    try {
      // 检查数据版本
      const savedVersion = await prefUtil.get(PREF_KEY_VERSION, 0) as number
      const needReset = savedVersion < DATA_VERSION
      
      if (needReset) {
        // 版本不匹配，强制使用新的种子数据
        console.info(`[MockDataStore] 数据版本不匹配 (${savedVersion} < ${DATA_VERSION})，重新初始化种子数据`)
        MockDataStore.frameList = [...SEED_FRAMES]
        MockDataStore.albumList = [...SEED_ALBUMS]
        MockDataStore.sceneLibraryData = {}
        await MockDataStore.save()
        console.info(`[MockDataStore] 初始化种子数据 ${MockDataStore.frameList.length} 条帧，${MockDataStore.albumList.length} 个合集`)
      } else {
        // 版本匹配，从 Preferences 加载数据
        const hasData = await prefUtil.has(PREF_KEY_INITIALIZED)
        if (hasData) {
          const framesJson = await prefUtil.get(PREF_KEY_FRAMES, '[]') as string
          MockDataStore.frameList = JSON.parse(framesJson) as FrameItem[]
          
          const albumsJson = await prefUtil.get(PREF_KEY_ALBUMS, '[]') as string
          MockDataStore.albumList = JSON.parse(albumsJson) as Album[]
          
          const sceneLibraryJson = await prefUtil.get(PREF_KEY_SCENE_LIBRARIES, '{}') as string
          MockDataStore.sceneLibraryData = JSON.parse(sceneLibraryJson) as Record<string, string[]>
          
          console.info(`[MockDataStore] 从持久化加载 ${MockDataStore.frameList.length} 条帧，${MockDataStore.albumList.length} 个合集`)
        } else {
          MockDataStore.frameList = [...SEED_FRAMES]
          MockDataStore.albumList = [...SEED_ALBUMS]
          MockDataStore.sceneLibraryData = {}
          await MockDataStore.save()
          console.info(`[MockDataStore] 初始化种子数据 ${MockDataStore.frameList.length} 条帧，${MockDataStore.albumList.length} 个合集`)
        }
      }
      
      MockDataStore.initialized = true
    } catch (err) {
      console.error(`[MockDataStore] 初始化失败: ${err}`)
      MockDataStore.frameList = [...SEED_FRAMES]
      MockDataStore.albumList = [...SEED_ALBUMS]
      MockDataStore.initialized = true
    }
  }

  /**
   * 保存数据到 Preferences
   */
  private static async save(): Promise<void> {
    try {
      const framesJson = JSON.stringify(MockDataStore.frameList)
      await prefUtil.put(PREF_KEY_FRAMES, framesJson)
      
      const albumsJson = JSON.stringify(MockDataStore.albumList)
      await prefUtil.put(PREF_KEY_ALBUMS, albumsJson)
      
      const sceneLibraryJson = JSON.stringify(MockDataStore.sceneLibraryData)
      await prefUtil.put(PREF_KEY_SCENE_LIBRARIES, sceneLibraryJson)
      
      await prefUtil.put(PREF_KEY_INITIALIZED, true)
      await prefUtil.put(PREF_KEY_VERSION, DATA_VERSION)
    } catch (err) {
      console.error(`[MockDataStore] 保存失败: ${err}`)
    }
  }

  /**
   * 获取所有未在回收站的情绪帧
   * @param sortByUpdated 是否按更新时间倒序（默认 true，最新在前）
   */
  static getAllFrames(sortByUpdated: boolean = true): FrameItem[] {
    const list = MockDataStore.frameList.filter((item: FrameItem) => !item.inRecycleBin)
    if (sortByUpdated) {
      return list.sort((a: FrameItem, b: FrameItem) => b.updatedAt - a.updatedAt)
    }
    return list
  }

  /** 根据 ID 获取单条（含回收站条目） */
  static getFrameById(id: string): FrameItem | undefined {
    return MockDataStore.frameList.find((item: FrameItem) => item.id === id)
  }

  /**
   * 按来源类型筛选
   * @param sourceType 来源枚举，传 undefined 表示不过滤
   */
  static getFramesBySource(sourceType?: SourceType): FrameItem[] {
    return MockDataStore.getAllFrames().filter((item: FrameItem) => {
      if (sourceType === undefined) {
        return true
      }
      return item.sourceType === sourceType
    })
  }

  /**
   * 按情绪标签筛选
   * @param emotion 情绪枚举，传 undefined 表示不过滤
   */
  static getFramesByEmotion(emotion?: EmotionTag): FrameItem[] {
    return MockDataStore.getAllFrames().filter((item: FrameItem) => {
      if (emotion === undefined) {
        return true
      }
      return item.emotion === emotion
    })
  }

  /**
   * 组合筛选：来源 + 情绪
   */
  static filterFrames(sourceType?: SourceType, emotion?: EmotionTag): FrameItem[] {
    return MockDataStore.getAllFrames().filter((item: FrameItem) => {
      const matchSource = sourceType === undefined || item.sourceType === sourceType
      const matchEmotion = emotion === undefined || item.emotion === emotion
      return matchSource && matchEmotion
    })
  }

  /**
   * 关键词搜索：匹配来源名、情绪文字、标签、字幕
   */
  static searchFrames(keyword: string): FrameItem[] {
    const key = keyword.trim().toLowerCase()
    if (key.length === 0) {
      return MockDataStore.getAllFrames()
    }
    return MockDataStore.getAllFrames().filter((item: FrameItem) => {
      const tagStr = item.tags.join(' ').toLowerCase()
      return item.sourceTitle.toLowerCase().includes(key) ||
        item.momentText.toLowerCase().includes(key) ||
        item.subtitleText.toLowerCase().includes(key) ||
        tagStr.includes(key)
    })
  }

  /** 获取回收站条目 */
  static getRecycleBinFrames(): FrameItem[] {
    return MockDataStore.frameList
      .filter((item: FrameItem) => item.inRecycleBin)
      .sort((a: FrameItem, b: FrameItem) => b.updatedAt - a.updatedAt)
  }

  /** 新增情绪帧 */
  static addFrame(frame: FrameItem): void {
    frame.updatedAt = Date.now()
    MockDataStore.frameList.unshift(frame)
    MockDataStore.save()
  }

  /** 创建并添加空条目（导入流程用） */
  static createEmptyFrame(sourceType: SourceType, sourceTitle: string, momentText: string): FrameItem {
    const newFrame: FrameItem = {
      id: generateId(),
      sourceType: sourceType,
      sourceTitle: sourceTitle,
      momentText: momentText,
      emotion: EmotionTag.HEAL,
      tags: [],
      screenshotUri: '',
      videoUri: '',
      clipStartMs: 0,
      clipEndMs: 0,
      linkedItemId: '',
      subtitleText: momentText,
      bgmId: 'bgm_heal_1',
      exportPreset: ExportPresetId.WECHAT_MOMENTS,
      inRecycleBin: false,
      updatedAt: Date.now()
    }
    newFrame.linkedItemId = newFrame.id
    MockDataStore.addFrame(newFrame)
    return newFrame
  }

  /** 更新已有条目（按 id 匹配） */
  static updateFrame(updated: FrameItem): boolean {
    const index = MockDataStore.frameList.findIndex((item: FrameItem) => item.id === updated.id)
    if (index < 0) {
      return false
    }
    updated.updatedAt = Date.now()
    MockDataStore.frameList[index] = updated
    MockDataStore.save()
    return true
  }

  /** 软删除：移入回收站 */
  static moveToRecycleBin(id: string): boolean {
    const frame = MockDataStore.getFrameById(id)
    if (frame === undefined) {
      return false
    }
    frame.inRecycleBin = true
    frame.updatedAt = Date.now()
    MockDataStore.save()
    return true
  }

  /** 从回收站恢复 */
  static restoreFromRecycleBin(id: string): boolean {
    const frame = MockDataStore.getFrameById(id)
    if (frame === undefined) {
      return false
    }
    frame.inRecycleBin = false
    frame.updatedAt = Date.now()
    MockDataStore.save()
    return true
  }

  /** 永久删除（仅回收站内操作） */
  static deletePermanently(id: string): boolean {
    const index = MockDataStore.frameList.findIndex((item: FrameItem) => item.id === id)
    if (index < 0) {
      return false
    }
    MockDataStore.frameList.splice(index, 1)
    MockDataStore.save()
    return true
  }

  /** 判断条目是否有关联视频（用于创作入口是否可剪片段） */
  static hasVideo(frame: FrameItem): boolean {
    return frame.videoUri.length > 0
  }

  /** 判断是否具备图影联动（截图 + 视频均存在） */
  static hasImageVideoLink(frame: FrameItem): boolean {
    return frame.screenshotUri.length > 0 && frame.videoUri.length > 0
  }

  /** 获取全部 BGM */
  static getAllBgm(): BgmItem[] {
    return [...BGM_LIST]
  }

  /** 按情绪推荐 BGM */
  static getBgmByEmotion(emotion: EmotionTag): BgmItem[] {
    return BGM_LIST.filter((bgm: BgmItem) => bgm.emotion === emotion)
  }

  /** 根据 ID 获取 BGM */
  static getBgmById(id: string): BgmItem | undefined {
    return BGM_LIST.find((bgm: BgmItem) => bgm.id === id)
  }

  /** 获取发现页专题列表 */
  static getEmotionTopics(): EmotionTopic[] {
    return [...EMOTION_TOPICS]
  }

  /** 根据专题 ID 获取专题 */
  static getTopicById(id: string): EmotionTopic | undefined {
    return EMOTION_TOPICS.find((topic: EmotionTopic) => topic.id === id)
  }

  /** 根据专题 ID 获取关联 FrameItem 列表 */
  static getFramesByTopicId(topicId: string): FrameItem[] {
    const topic = MockDataStore.getTopicById(topicId)
    if (topic === undefined) {
      return []
    }
    const result: FrameItem[] = []
    topic.frameIds.forEach((fid: string) => {
      // 先从 frameList 查找
      let item = MockDataStore.getFrameById(fid)
      // 如果找不到，从种子数据中查找
      if (item === undefined) {
        item = SEED_FRAMES.find((f: FrameItem) => f.id === fid)
      }
      if (item !== undefined && !item.inRecycleBin) {
        result.push(item)
      }
    })
    return result
  }

  // ========== 合集管理方法 ==========

  /** 获取所有合集（返回深拷贝，确保 UI 状态更新） */
  static getAllAlbums(): Album[] {
    const albums: Album[] = MockDataStore.albumList.map((album: Album): Album => {
      const copy: Album = {
        id: album.id,
        name: album.name,
        description: album.description,
        coverUri: album.coverUri,
        type: album.type,
        frameIds: [...album.frameIds],  // 深拷贝 frameIds 数组
        createdAt: album.createdAt,
        updatedAt: album.updatedAt
      }
      return copy
    })
    return albums.sort((a: Album, b: Album) => b.updatedAt - a.updatedAt)
  }

  /** 根据 ID 获取合集 */
  static getAlbumById(id: string): Album | undefined {
    return MockDataStore.albumList.find((album: Album) => album.id === id)
  }

  /** 创建新合集 */
  static createAlbum(name: string, description: string = '', coverUri: string = ''): Album {
    const newAlbum: Album = {
      id: `album_${Date.now()}_${Math.floor(Math.random() * 10000)}`,
      name: name,
      description: description,
      coverUri: coverUri,
      frameIds: [],
      createdAt: Date.now(),
      updatedAt: Date.now()
    }
    MockDataStore.albumList.push(newAlbum)
    MockDataStore.save()
    return newAlbum
  }

  /** 更新合集 */
  static updateAlbum(updated: Album): boolean {
    const index = MockDataStore.albumList.findIndex((album: Album) => album.id === updated.id)
    if (index < 0) {
      return false
    }
    updated.updatedAt = Date.now()
    MockDataStore.albumList[index] = updated
    MockDataStore.save()
    return true
  }

  /** 删除合集 */
  static deleteAlbum(id: string): boolean {
    const index = MockDataStore.albumList.findIndex((album: Album) => album.id === id)
    if (index < 0) {
      return false
    }
    MockDataStore.albumList.splice(index, 1)
    MockDataStore.save()
    return true
  }

  /** 获取合集内的情绪帧列表 */
  static getFramesByAlbumId(albumId: string): FrameItem[] {
    const album = MockDataStore.getAlbumById(albumId)
    if (album === undefined) {
      return []
    }
    const result: FrameItem[] = []
    album.frameIds.forEach((fid: string) => {
      // 先从 frameList 查找
      let item = MockDataStore.getFrameById(fid)
      // 如果找不到，从种子数据中查找
      if (item === undefined) {
        item = SEED_FRAMES.find((f: FrameItem) => f.id === fid)
      }
      if (item !== undefined && !item.inRecycleBin) {
        result.push(item)
      }
    })
    return result
  }

  // ========== 批量操作方法 ==========

  /**
   * 批量添加标签
   * @param ids 情绪帧 ID 数组
   * @param tags 要添加的标签数组
   * @returns 成功更新的数量
   */
  static batchAddTags(ids: string[], tags: string[]): number {
    let count = 0
    ids.forEach((id: string) => {
      const frame = MockDataStore.getFrameById(id)
      if (frame !== undefined) {
        // 合并标签，去重
        const newTags = new Set([...frame.tags, ...tags])
        frame.tags = Array.from(newTags)
        frame.updatedAt = Date.now()
        count++
      }
    })
    if (count > 0) {
      MockDataStore.save()
    }
    return count
  }

  /**
   * 批量删除（移入回收站）
   * @param ids 情绪帧 ID 数组
   * @returns 成功删除的数量
   */
  static batchDelete(ids: string[]): number {
    let count = 0
    ids.forEach((id: string) => {
      const frame = MockDataStore.getFrameById(id)
      if (frame !== undefined && !frame.inRecycleBin) {
        frame.inRecycleBin = true
        frame.updatedAt = Date.now()
        count++
      }
    })
    if (count > 0) {
      MockDataStore.save()
    }
    return count
  }

  /**
   * 批量加入合集
   * @param ids 情绪帧 ID 数组
   * @param albumId 合集 ID
   * @returns 成功添加的数量
   */
  static batchAddToAlbum(ids: string[], albumId: string): number {
    const album = MockDataStore.getAlbumById(albumId)
    if (album === undefined) {
      return 0
    }
    
    let count = 0
    ids.forEach((id: string) => {
      // 检查情绪帧是否存在且不在回收站
      const frame = MockDataStore.getFrameById(id)
      if (frame !== undefined && !frame.inRecycleBin) {
        // 检查是否已在合集中
        if (!album.frameIds.includes(id)) {
          album.frameIds.push(id)
          count++
        }
      }
    })
    
    if (count > 0) {
      album.updatedAt = Date.now()
      MockDataStore.save()
    }
    return count
  }

  /**
   * 从合集移除情绪帧
   * @param ids 情绪帧 ID 数组
   * @param albumId 合集 ID
   * @returns 成功移除的数量
   */
  static batchRemoveFromAlbum(ids: string[], albumId: string): number {
    const album = MockDataStore.getAlbumById(albumId)
    if (album === undefined) {
      return 0
    }
    
    let count = 0
    ids.forEach((id: string) => {
      const index = album.frameIds.indexOf(id)
      if (index >= 0) {
        album.frameIds.splice(index, 1)
        count++
      }
    })
    
    if (count > 0) {
      album.updatedAt = Date.now()
      MockDataStore.save()
    }
    return count
  }
  
  // ==================== 场景素材库相关方法 ====================
  
  /**
   * 获取场景素材库的帧 ID 列表
   * @param libraryId 场景素材库 ID
   * @returns 帧 ID 列表（如果没有自定义数据则返回 undefined）
   */
  static getSceneLibraryFrameIds(libraryId: string): string[] | undefined {
    return MockDataStore.sceneLibraryData[libraryId]
  }
  
  /**
   * 设置场景素材库的帧 ID 列表
   * @param libraryId 场景素材库 ID
   * @param frameIds 帧 ID 列表
   */
  static async setSceneLibraryFrameIds(libraryId: string, frameIds: string[]): Promise<void> {
    MockDataStore.sceneLibraryData[libraryId] = frameIds
    await MockDataStore.save()
  }
  
  /**
   * 从场景素材库删除帧
   * @param libraryId 场景素材库 ID
   * @param frameId 帧 ID
   * @returns 是否删除成功
   */
  static async deleteFrameFromSceneLibrary(libraryId: string, frameId: string): Promise<boolean> {
    const frameIds = MockDataStore.sceneLibraryData[libraryId]
    if (frameIds === undefined) {
      return false
    }
    
    const index = frameIds.indexOf(frameId)
    if (index >= 0) {
      frameIds.splice(index, 1)
      await MockDataStore.save()
      return true
    }
    return false
  }
  
  /**
   * 移动帧到另一个场景素材库
   * @param fromLibraryId 源场景素材库 ID
   * @param toLibraryId 目标场景素材库 ID
   * @param frameId 帧 ID
   * @returns 是否移动成功
   */
  static async moveFrameToSceneLibrary(fromLibraryId: string, toLibraryId: string, frameId: string): Promise<boolean> {
    // 从源场景删除
    const fromFrameIds = MockDataStore.sceneLibraryData[fromLibraryId]
    if (fromFrameIds === undefined) {
      return false
    }
    
    const index = fromFrameIds.indexOf(frameId)
    if (index < 0) {
      return false
    }
    
    fromFrameIds.splice(index, 1)
    
    // 添加到目标场景
    if (MockDataStore.sceneLibraryData[toLibraryId] === undefined) {
      MockDataStore.sceneLibraryData[toLibraryId] = []
    }
    
    // 避免重复添加
    if (!MockDataStore.sceneLibraryData[toLibraryId].includes(frameId)) {
      MockDataStore.sceneLibraryData[toLibraryId].push(frameId)
    }
    
    await MockDataStore.save()
    return true
  }
  
  /**
   * 初始化场景素材库数据（如果不存在则创建）
   * @param libraryId 场景素材库 ID
   * @param frameIds 初始帧 ID 列表
   */
  static async initSceneLibraryData(libraryId: string, frameIds: string[]): Promise<void> {
    if (MockDataStore.sceneLibraryData[libraryId] === undefined) {
      MockDataStore.sceneLibraryData[libraryId] = [...frameIds]
      await MockDataStore.save()
    }
  }
}

/** 统计数据类 */
export class StatisticsData {
  totalFrames: number = 0
  totalAlbums: number = 0
  recycleBinCount: number = 0
  emotionDistribution: Record<string, number> = {}
  sourceDistribution: Record<string, number> = {}
}

export class MockDataStoreExt {
  /**
   * 获取统计数据
   * @returns 统计数据对象
   */
  static getStatistics(): StatisticsData {
    const allFrames = MockDataStore.getAllFrames()
    const recycleBinFrames = MockDataStore.getRecycleBinFrames()
    const normalFrames = allFrames.filter(f => !f.inRecycleBin)
    
    // 情绪分布统计
    const emotionDistribution: Record<string, number> = {
      [EmotionTag.HEAL]: 0,
      [EmotionTag.BURN]: 0,
      [EmotionTag.SAD]: 0,
      [EmotionTag.FUNNY]: 0
    }
    
    normalFrames.forEach(frame => {
      if (emotionDistribution[frame.emotion] !== undefined) {
        emotionDistribution[frame.emotion]++
      }
    })
    
    // 来源分布统计
    const sourceDistribution: Record<string, number> = {
      [SourceType.FILM]: 0,
      [SourceType.ANIME]: 0,
      [SourceType.LIFE]: 0,
      [SourceType.OTHER]: 0
    }
    
    normalFrames.forEach(frame => {
      if (sourceDistribution[frame.sourceType] !== undefined) {
        sourceDistribution[frame.sourceType]++
      }
    })
    
    const result = new StatisticsData()
    result.totalFrames = normalFrames.length
    result.totalAlbums = 0
    result.recycleBinCount = recycleBinFrames.length
    result.emotionDistribution = emotionDistribution
    result.sourceDistribution = sourceDistribution
    
    return result
  }
}
