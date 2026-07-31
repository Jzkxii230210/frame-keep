/**
 * FrameKeep（帧藏）- 素材资源管理工具
 * 
 * 统一管理应用内的图片、视频、音频素材资源
 * 支持从 resources/rawfile 加载素材
 */

/** 素材类型 */
export enum MediaType {
  /** 图片 */
  IMAGE = 'image',
  /** 视频 */
  VIDEO = 'video',
  /** 音频 */
  AUDIO = 'audio'
}

/** 情绪标签 */
export enum EmotionType {
  /** 治愈 */
  HEAL = 'heal',
  /** 燃向 */
  BURN = 'burn',
  /** 伤感 */
  SAD = 'sad',
  /** 搞笑 */
  FUNNY = 'funny'
}

/** 来源类型 */
export enum SourceType {
  /** 影视 */
  FILM = 'film',
  /** 动漫 */
  ANIME = 'anime',
  /** 生活 */
  LIFE = 'life'
}

/**
 * 素材资源管理器
 */
export class MediaAssetsManager {
  private static instance: MediaAssetsManager | null = null;

  private constructor() {}

  /**
   * 获取单例实例
   */
  static getInstance(): MediaAssetsManager {
    if (!MediaAssetsManager.instance) {
      MediaAssetsManager.instance = new MediaAssetsManager();
    }
    return MediaAssetsManager.instance;
  }

  /**
   * 获取情绪帧图片路径
   * @param emotion 情绪类型
   * @param index 序号
   * @returns 图片资源路径
   */
  getEmotionFrameImage(emotion: EmotionType, index: number = 1): string {
    const paddedIndex = index.toString().padStart(3, '0');
    return `images/emotion_frames/${emotion}_${paddedIndex}.jpg`;
  }

  /**
   * 获取情绪帧视频路径
   * @param emotion 情绪类型
   * @param index 序号
   * @returns 视频资源路径
   */
  getEmotionFrameVideo(emotion: EmotionType, index: number = 1): string {
    const paddedIndex = index.toString().padStart(3, '0');
    return `videos/emotion_videos/${emotion}_${paddedIndex}.mp4`;
  }

  /**
   * 获取来源封面图片路径
   * @param source 来源类型
   * @param index 序号
   * @returns 图片资源路径
   */
  getSourceCoverImage(source: SourceType, index: number = 1): string {
    const paddedIndex = index.toString().padStart(3, '0');
    return `images/source_covers/${source}_${paddedIndex}.jpg`;
  }

  /**
   * 获取模板背景图片路径
   * @param type 背景类型 (gradient/texture)
   * @param index 序号
   * @returns 图片资源路径
   */
  getTemplateBackground(type: 'gradient' | 'texture', index: number = 1): string {
    const paddedIndex = index.toString().padStart(3, '0');
    return `images/template_backgrounds/${type}_${paddedIndex}.jpg`;
  }

  /**
   * 获取用户头像路径
   * @param index 序号
   * @returns 图片资源路径
   */
  getAvatar(index: number = 1): string {
    const paddedIndex = index.toString().padStart(3, '0');
    return `images/avatars/avatar_${paddedIndex}.jpg`;
  }

  /**
   * 获取背景音乐路径
   * @param emotion 情绪类型
   * @param index 序号
   * @returns 音频资源路径
   */
  getBGM(emotion: EmotionType, index: number = 1): string {
    const paddedIndex = index.toString().padStart(3, '0');
    return `audios/bgm/${emotion}_bgm_${paddedIndex}.mp3`;
  }

  /**
   * 获取模板视频路径
   * @param type 视频类型 (particle/transition)
   * @param index 序号
   * @returns 视频资源路径
   */
  getTemplateVideo(type: 'particle' | 'transition', index: number = 1): string {
    const paddedIndex = index.toString().padStart(3, '0');
    return `videos/template_videos/${type}_${paddedIndex}.mp4`;
  }

  /**
   * 批量获取情绪帧图片
   * @param emotion 情绪类型
   * @param count 数量
   * @returns 图片路径数组
   */
  getEmotionFrameImages(emotion: EmotionType, count: number = 2): string[] {
    const images: string[] = [];
    for (let i = 1; i <= count; i++) {
      images.push(this.getEmotionFrameImage(emotion, i));
    }
    return images;
  }

  /**
   * 随机获取情绪帧图片
   * @param emotion 情绪类型
   * @returns 随机图片路径
   */
  getRandomEmotionFrameImage(emotion: EmotionType): string {
    const index = Math.floor(Math.random() * 2) + 1; // 1-2随机
    return this.getEmotionFrameImage(emotion, index);
  }
}

/**
 * 素材资源常量
 * 提供预定义的素材路径常量，方便直接使用
 * 注意：使用时需要用 $rawfile() 包装，例如 Image($rawfile(MediaAssets.HEAL_IMAGES.IMG_001))
 */

/** 图片素材接口 */
interface ImageAssets {
  IMG_001: string
  IMG_002?: string  // 可选，仅治愈系有
  IMG_003?: string  // 可选，仅治愈系有
}

/** 视频素材接口 */
interface VideoAssets {
  HEAL_001: string
  BURN_001: string
  SAD_001: string
  FUNNY_001: string
}

/** 来源封面素材接口 */
interface SourceCoverAssets {
  FILM_001: string
  FILM_002: string
  ANIME_001: string
  ANIME_002: string
  LIFE_001: string
  LIFE_002: string
}

/** 模板背景素材接口 */
interface TemplateAssets {
  GRADIENT_001: string
  GRADIENT_002: string
  TEXTURE_001: string
  TEXTURE_002: string
}

/** 头像素材接口 */
interface AvatarAssets {
  AVATAR_001: string
  AVATAR_002: string
  AVATAR_003: string
}

/** BGM素材接口 */
interface BgmAssets {
  HEAL_001: string
  BURN_001: string
  SAD_001: string
  FUNNY_001: string
}

export class MediaAssets {
  /** 情绪帧图片 - 治愈系 */
  static readonly HEAL_IMAGES: ImageAssets = {
    IMG_001: 'images/emotion_frames/heal_001.jpg',
    IMG_002: 'images/emotion_frames/heal_002.jpg',
    IMG_003: 'images/emotion_frames/heal_003.jpg'
  };

  /** 情绪帧图片 - 燃向 */
  static readonly BURN_IMAGES: ImageAssets = {
    IMG_001: 'images/emotion_frames/burn_001.jpg'
  };

  /** 情绪帧图片 - 伤感 */
  static readonly SAD_IMAGES: ImageAssets = {
    IMG_001: 'images/emotion_frames/sad_001.jpg'
  };

  /** 情绪帧图片 - 搞笑 */
  static readonly FUNNY_IMAGES: ImageAssets = {
    IMG_001: 'images/emotion_frames/funny_001.jpg'
  };

  /** 情绪帧视频 */
  static readonly VIDEOS: VideoAssets = {
    HEAL_001: 'videos/emotion_videos/heal_001.mp4',
    BURN_001: 'videos/emotion_videos/burn_001.mp4',
    SAD_001: 'videos/emotion_videos/sad_001.mp4',
    FUNNY_001: 'videos/emotion_videos/funny_001.mp4'
  };

  /** 来源封面 */
  static readonly SOURCE_COVERS: SourceCoverAssets = {
    FILM_001: 'images/source_covers/film_001.jpg',
    FILM_002: 'images/source_covers/film_002.jpg',
    ANIME_001: 'images/source_covers/anime_001.jpg',
    ANIME_002: 'images/source_covers/anime_002.jpg',
    LIFE_001: 'images/source_covers/life_001.jpg',
    LIFE_002: 'images/source_covers/life_002.jpg'
  };

  /** 模板背景 */
  static readonly TEMPLATES: TemplateAssets = {
    GRADIENT_001: 'images/template_backgrounds/gradient_001.jpg',
    GRADIENT_002: 'images/template_backgrounds/gradient_002.jpg',
    TEXTURE_001: 'images/template_backgrounds/texture_001.jpg',
    TEXTURE_002: 'images/template_backgrounds/texture_002.jpg'
  };

  /** 用户头像 */
  static readonly AVATARS: AvatarAssets = {
    AVATAR_001: 'images/avatars/avatar_001.jpg',
    AVATAR_002: 'images/avatars/avatar_002.jpg',
    AVATAR_003: 'images/avatars/avatar_003.jpg'
  };

  /** 背景音乐 */
  static readonly BGM: BgmAssets = {
    HEAL_001: 'audios/bgm/heal_bgm_001.mp3',
    BURN_001: 'audios/bgm/burn_bgm_001.mp3',
    SAD_001: 'audios/bgm/sad_bgm_001.mp3',
    FUNNY_001: 'audios/bgm/funny_bgm_001.mp3'
  };
}
