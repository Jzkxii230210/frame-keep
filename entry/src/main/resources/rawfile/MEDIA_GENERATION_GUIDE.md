# FrameKeep 素材生成指南

## 快速生成占位素材

由于无法直接提供图片和视频文件，您可以按照以下步骤快速生成占位素材：

### 方法一：使用在线占位图服务

#### 1. 图片素材

访问以下网站下载免费图片：
- **Unsplash**: https://unsplash.com
- **Pexels**: https://www.pexels.com
- **Pixabay**: https://pixabay.com

推荐搜索关键词：
- 治愈系：`warm`, `peaceful`, `sunset`, `nature`
- 燃向：`action`, `dynamic`, `energy`, `sports`
- 伤感：`rain`, `melancholy`, `lonely`, `sad`
- 搞笑：`fun`, `happy`, `smile`, `joy`
- 纯音：`stars`, `night`, `minimal`, `zen`

#### 2. 视频素材

访问以下网站下载免费视频：
- **Pexels Videos**: https://www.pexels.com/videos
- **Pixabay Videos**: https://pixabay.com/videos
- **Coverr**: https://coverr.co

推荐下载 5-10 秒的短视频片段。

### 方法二：使用命令行生成占位图

#### Windows PowerShell

```powershell
# 创建目录结构
$baseDir = "E:\DevEcoStudioProjects\FrameKeep\entry\src\main\resources\rawfile"

# 创建图片目录
New-Item -ItemType Directory -Force -Path "$baseDir\images\emotion_frames"
New-Item -ItemType Directory -Force -Path "$baseDir\images\source_covers"
New-Item -ItemType Directory -Force -Path "$baseDir\images\template_backgrounds"
New-Item -ItemType Directory -Force -Path "$baseDir\images\avatars"

# 创建视频目录
New-Item -ItemType Directory -Force -Path "$baseDir\videos\emotion_videos"
New-Item -ItemType Directory -Force -Path "$baseDir\videos\template_videos"

# 创建音频目录
New-Item -ItemType Directory -Force -Path "$baseDir\audios\bgm"
```

### 方法三：使用 HarmonyOS 资源占位

如果暂时没有素材，可以使用 HarmonyOS 内置资源作为占位：

#### 修改 MediaAssetsManager.ets

```typescript
// 使用内置资源作为占位
getEmotionFrameImage(emotion: EmotionType, index: number = 1): Resource | string {
  // 临时使用启动图标作为占位
  return $r('app.media.startIcon');
}
```

## 素材规格建议

### 图片素材

| 类型 | 尺寸 | 格式 | 文件大小 |
|------|------|------|----------|
| 情绪帧 | 1080x1920 | JPG | 500KB-2MB |
| 来源封面 | 500x750 | JPG | 200KB-500KB |
| 模板背景 | 1080x1920 | JPG | 500KB-2MB |
| 用户头像 | 200x200 | JPG | 50KB-100KB |

### 视频素材

| 类型 | 分辨率 | 时长 | 格式 | 文件大小 |
|------|--------|------|------|----------|
| 情绪帧视频 | 1080x1920 | 5-10秒 | MP4 | 5MB-20MB |
| 模板视频 | 1080x1920 | 3-5秒 | MP4 | 3MB-10MB |

### 音频素材

| 类型 | 时长 | 格式 | 文件大小 |
|------|------|------|----------|
| 背景音乐 | 30-60秒 | MP3 | 500KB-2MB |

## 素材命名规范

### 图片命名

```
[情绪类型]_[序号].jpg
```

示例：
- `heal_001.jpg` - 治愈系第1张
- `burn_002.jpg` - 燃向第2张
- `sad_001.jpg` - 伤感第1张

### 视频命名

```
[情绪类型]_[序号].mp4
```

示例：
- `heal_001.mp4` - 治愈系视频1
- `burn_001.mp4` - 燃向视频1

### 音频命名

```
[情绪类型]_bgm_[序号].mp3
```

示例：
- `heal_bgm_001.mp3` - 治愈系BGM 1
- `burn_bgm_001.mp3` - 燃向BGM 1

## 素材目录结构

```
entry/src/main/resources/rawfile/
├── images/
│   ├── emotion_frames/          # 情绪帧图片
│   │   ├── heal_001.jpg
│   │   ├── heal_002.jpg
│   │   ├── burn_001.jpg
│   │   ├── burn_002.jpg
│   │   ├── sad_001.jpg
│   │   ├── sad_002.jpg
│   │   ├── funny_001.jpg
│   │   ├── funny_002.jpg
│   │   ├── pure_001.jpg
│   │   └── pure_002.jpg
│   ├── source_covers/           # 来源封面
│   │   ├── film_001.jpg
│   │   ├── film_002.jpg
│   │   ├── anime_001.jpg
│   │   ├── anime_002.jpg
│   │   ├── life_001.jpg
│   │   └── life_002.jpg
│   ├── template_backgrounds/    # 模板背景
│   │   ├── gradient_001.jpg
│   │   ├── gradient_002.jpg
│   │   ├── texture_001.jpg
│   │   └── texture_002.jpg
│   └── avatars/                 # 用户头像
│       ├── avatar_001.jpg
│       ├── avatar_002.jpg
│       └── avatar_003.jpg
├── videos/
│   ├── emotion_videos/          # 情绪帧视频
│   │   ├── heal_001.mp4
│   │   ├── burn_001.mp4
│   │   ├── sad_001.mp4
│   │   └── funny_001.mp4
│   └── template_videos/         # 模板视频
│       ├── particle_001.mp4
│       └── transition_001.mp4
└── audios/
    └── bgm/                     # 背景音乐
        ├── heal_bgm_001.mp3
        ├── burn_bgm_001.mp3
        ├── sad_bgm_001.mp3
        ├── funny_bgm_001.mp3
        └── pure_bgm_001.mp3
```

## 注意事项

1. **版权问题**：请确保使用的素材是免费或已授权的
2. **文件大小**：控制素材文件大小，避免应用体积过大
3. **格式兼容**：使用通用的图片格式（JPG/PNG）和视频格式（MP4）
4. **分辨率适配**：考虑不同设备的屏幕分辨率
5. **加载优化**：大图建议使用缩略图，按需加载原图

## 测试素材加载

素材放置完成后，可以在代码中测试加载：

```typescript
// 测试图片加载
Image(MediaAssets.HEAL_IMAGES.IMG_001)
  .width(200)
  .height(200)

// 测试视频加载
Video(MediaAssets.VIDEOS.HEAL_001)
  .width(300)
  .height(200)
```
