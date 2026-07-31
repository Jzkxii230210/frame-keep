/**
 * FrameKeep（帧藏）- 发现 Tab 首页
 * 卡片式设计，支持搜索、收藏、专题浏览
 * 使用真实图片素材
 */
import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { RouteParams, RoutePath, EmotionTag, EMOTION_TAG_LABEL, SourceType } from '../../common/Constants';
import { EmotionTopic, MockDataStore, FrameItem } from '../../common/MockData';
import { MediaAssets } from '../../common/utils/MediaAssetsManager';
import { AppColors, AppFontSize, AppSpacing } from '../../common/Styles';

/** 热门名场面数据 */
interface HotScene {
  id: string
  title: string
  source: string
  quote: string
  coverImage: string // 改用真实图片路径
}

/** 场景素材库数据 */
interface SceneLibrary {
  id: string
  title: string // 场景名称，如"朋友圈文案向"
  description: string // 场景说明，如"适合发圈的氛围感台词"
  frameIds: string[] // 包含的帧ID列表
  coverImage: string // 封面图片
  usageScenario: string // 使用场景标签，如"朋友圈"、"备考"等
}

@Component
export struct DiscoverIndex {
  @State topics: EmotionTopic[] = []
  @State searchKeyword: string = ''
  @State hotScenes: HotScene[] = []
  @State sceneLibraries: SceneLibrary[] = []
  @State todayQuote: FrameItem | undefined = undefined

  aboutToAppear(): void {
    // 确保数据已初始化后再刷新
    this.ensureDataReady()
  }

  /** 确保数据已初始化 */
  private async ensureDataReady(): Promise<void> {
    await MockDataStore.init()
    this.topics = MockDataStore.getEmotionTopics()
    this.initHotScenes()
    this.initSceneLibraries()
    this.initTodayQuote()
  }

  /** 页面每次显示时刷新数据（包括从其他页面返回） */
  async onPageShow(): Promise<void> {
    await MockDataStore.init()
    this.initSceneLibraries()
  }

  /** 初始化热门名场面 - 使用真实图片 */
  private initHotScenes(): void {
    this.hotScenes = [
      { id: 'hs1', title: '肖申克的救赎', source: '电影', quote: '希望是美好的东西', coverImage: MediaAssets.HEAL_IMAGES.IMG_001 },
      { id: 'hs2', title: '千与千寻', source: '动画', quote: '不管前方的路有多苦', coverImage: MediaAssets.HEAL_IMAGES.IMG_003 || MediaAssets.HEAL_IMAGES.IMG_001 },
      { id: 'hs3', title: '进击的巨人', source: '动画', quote: '心を放せ，全てはこの一瞬のために', coverImage: MediaAssets.BURN_IMAGES.IMG_001 },
      { id: 'hs4', title: '泰坦尼克号', source: '电影', quote: 'You jump, I jump', coverImage: MediaAssets.SAD_IMAGES.IMG_001 },
      { id: 'hs5', title: '蜡笔小新', source: '动画', quote: '动感超人的必杀技', coverImage: MediaAssets.FUNNY_IMAGES.IMG_001 }
    ]
  }

  /** 初始化场景素材库 - 根据实际数据筛选 */
  private initSceneLibraries(): void {
    const allFrames = MockDataStore.getAllFrames(false)
    
    // 辅助函数：获取场景素材库的帧ID列表
    const getFrameIds = (libraryId: string, defaultFilter: (f: FrameItem) => boolean): string[] => {
      const customFrameIds = MockDataStore.getSceneLibraryFrameIds(libraryId)
      if (customFrameIds !== undefined) {
        return customFrameIds
      }
      return allFrames.filter(defaultFilter).map((f: FrameItem) => f.id)
    }
    
    // 朋友圈文案向：治愈或伤感情绪，适合发圈
    const momentsIds = getFrameIds('sl1', (f: FrameItem) => f.emotion === EmotionTag.HEAL || f.emotion === EmotionTag.SAD)
    
    // 备考励志向：燃向情绪，学习打气
    const studyIds = getFrameIds('sl2', (f: FrameItem) => f.emotion === EmotionTag.BURN)
    
    // 低谷治愈向：治愈情绪，emo时必看
    const healIds = getFrameIds('sl3', (f: FrameItem) => f.emotion === EmotionTag.HEAL)
    
    // 剪辑备用向：燃向或搞笑，高燃转场素材
    const editIds = getFrameIds('sl4', (f: FrameItem) => f.emotion === EmotionTag.BURN || f.emotion === EmotionTag.FUNNY)
    
    this.sceneLibraries = [
      {
        id: 'sl1',
        title: '朋友圈文案向',
        description: '适合发圈的氛围感台词',
        frameIds: momentsIds,
        coverImage: MediaAssets.HEAL_IMAGES.IMG_001,
        usageScenario: '朋友圈'
      },
      {
        id: 'sl2',
        title: '备考励志向',
        description: '考研/学习打气金句',
        frameIds: studyIds,
        coverImage: MediaAssets.BURN_IMAGES.IMG_001,
        usageScenario: '备考'
      },
      {
        id: 'sl3',
        title: '低谷治愈向',
        description: 'emo时必看的治愈片段',
        frameIds: healIds,
        coverImage: MediaAssets.HEAL_IMAGES.IMG_003 || MediaAssets.HEAL_IMAGES.IMG_001,
        usageScenario: '治愈'
      },
      {
        id: 'sl4',
        title: '剪辑备用向',
        description: '高燃转场名场面素材',
        frameIds: editIds,
        coverImage: MediaAssets.BURN_IMAGES.IMG_002 || MediaAssets.BURN_IMAGES.IMG_001,
        usageScenario: '剪辑'
      }
    ]
  }

  /** 初始化今日一句 */
  private initTodayQuote(): void {
    const frames = MockDataStore.getAllFrames(true)
    if (frames.length > 0) {
      this.todayQuote = frames[0]
    }
  }

  /** 收藏今日一句 */
  private collectTodayQuote(): void {
    if (this.todayQuote) {
      // 已存在，无需重复收藏
      if (MockDataStore.getFrameById(this.todayQuote.id)) {
        promptAction.showToast({ message: '该素材已在收藏中' })
        return
      }
      // 添加到收藏
      MockDataStore.addFrame(this.todayQuote)
      promptAction.showToast({ message: '已收藏到我的' })
    }
  }

  /** 收藏热门名场面 */
  private collectHotScene(scene: HotScene): void {
    const frameId = 'scene_' + scene.id
    // 已存在，无需重复收藏
    if (MockDataStore.getFrameById(frameId)) {
      promptAction.showToast({ message: '该素材已在收藏中' })
      return
    }
    
    const newFrame: FrameItem = {
      id: frameId,
      sourceType: SourceType.OTHER,
      sourceTitle: scene.title,
      momentText: scene.quote,
      emotion: EmotionTag.HEAL,
      tags: [],
      screenshotUri: scene.coverImage,
      videoUri: '',
      clipStartMs: 0,
      clipEndMs: 0,
      linkedItemId: '',
      subtitleText: scene.quote,
      bgmId: '',
      exportPreset: '',
      inRecycleBin: false,
      updatedAt: Date.now()
    }
    MockDataStore.addFrame(newFrame)
    promptAction.showToast({ message: '已收藏到我的' })
  }

  /** 渲染图片（支持 rawfile 和普通路径） */
  @Builder
  renderImage(uri: string, width: Length, height: Length, radius: number = 8) {
    if (uri && uri.length > 0) {
      // 网络图片（http/https）
      if (uri.startsWith('http://') || uri.startsWith('https://')) {
        Image(uri)
          .width(width)
          .height(height)
          .objectFit(ImageFit.Cover)
          .borderRadius(radius)
      }
      // rawfile 路径需要用 $rawfile() 包装
      else if (!uri.startsWith('file://') && !uri.startsWith('datashare://') && !uri.startsWith('mock://')) {
        Image($rawfile(uri))
          .width(width)
          .height(height)
          .objectFit(ImageFit.Cover)
          .borderRadius(radius)
      } else {
        Image(uri)
          .width(width)
          .height(height)
          .objectFit(ImageFit.Cover)
          .borderRadius(radius)
      }
    }
  }

  /** 根据情绪标签获取图片 */
  private getEmotionImage(emotion: EmotionTag, index: number = 1): string {
    switch (emotion) {
      case EmotionTag.HEAL:
        return index === 1 ? MediaAssets.HEAL_IMAGES.IMG_001 : (MediaAssets.HEAL_IMAGES.IMG_002 || MediaAssets.HEAL_IMAGES.IMG_001)
      case EmotionTag.BURN:
        return index === 1 ? MediaAssets.BURN_IMAGES.IMG_001 : MediaAssets.BURN_IMAGES.IMG_001
      case EmotionTag.SAD:
        return index === 1 ? MediaAssets.SAD_IMAGES.IMG_001 : MediaAssets.SAD_IMAGES.IMG_001
      case EmotionTag.FUNNY:
        return index === 1 ? MediaAssets.FUNNY_IMAGES.IMG_001 : MediaAssets.FUNNY_IMAGES.IMG_001
      default:
        return MediaAssets.HEAL_IMAGES.IMG_001
    }
  }

  build() {
    Column() {
      // 顶栏：标题 + 搜索框
      Column({ space: AppSpacing.SM }) {
        Text('发现')
          .fontSize(AppFontSize.HEADLINE)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.TEXT_PRIMARY)
        
        // 搜索框
        Row({ space: AppSpacing.SM }) {
          Text('🔍')
            .fontSize(16)
          TextInput({ placeholder: '搜索台词、专题、片单...', text: this.searchKeyword })
            .layoutWeight(1)
            .height(36)
            .backgroundColor(AppColors.SURFACE_BG)
            .borderRadius(18)
            .onChange((value: string) => {
              this.searchKeyword = value
            })
        }
        .width('100%')
        .padding({ left: 12, right: 12 })
        .backgroundColor(AppColors.SURFACE_BG)
        .borderRadius(20)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding({
        left: AppSpacing.PAGE_HORIZONTAL,
        right: AppSpacing.PAGE_HORIZONTAL,
        top: AppSpacing.XL,
        bottom: AppSpacing.LG
      })

      Scroll() {
        Column({ space: AppSpacing.LG }) {
          // 今日一句 - 卡片式设计（带真实图片）
          this.todayQuoteCard()

          // 热门名场面 - 横向滚动（带真实图片）
          this.hotScenesSection()

          // 情绪专题（带真实图片）
          this.topicsSection()

          // 场景素材库（带真实图片）
          this.sceneLibrariesSection()
        }
        .padding({ left: AppSpacing.PAGE_HORIZONTAL, right: AppSpacing.PAGE_HORIZONTAL, bottom: AppSpacing.XL })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppColors.PAGE_BG)
  }

  /** 今日一句卡片 - 带背景图 */
  @Builder
  todayQuoteCard() {
    Column() {
      Row() {
        Text('今日一句')
          .fontSize(AppFontSize.SUBTITLE)
          .fontColor(AppColors.TEXT_PRIMARY)
        Blank()
        Text('换一条')
          .fontSize(AppFontSize.CAPTION)
          .fontColor(AppColors.ACCENT_PRIMARY)
          .onClick(() => {
            // 随机换一条
            const frames = MockDataStore.getAllFrames(true)
            if (frames.length > 0) {
              const randomIndex = Math.floor(Math.random() * frames.length)
              this.todayQuote = frames[randomIndex]
            }
          })
      }
      .width('100%')
      .margin({ bottom: AppSpacing.SM })

      Stack({ alignContent: Alignment.BottomEnd }) {
        // 背景图 - 直接渲染以响应状态变化
        if (this.todayQuote && this.todayQuote.screenshotUri.length > 0) {
          Image($rawfile(this.todayQuote.screenshotUri))
            .width('100%')
            .height(160)
            .objectFit(ImageFit.Cover)
            .borderRadius(12)
        } else {
          // 默认背景图
          Image($rawfile(MediaAssets.HEAL_IMAGES.IMG_001))
            .width('100%')
            .height(160)
            .objectFit(ImageFit.Cover)
            .borderRadius(12)
        }

        // 半透明遮罩
        Column()
          .width('100%')
          .height(160)
          .backgroundColor('#40000000')
          .borderRadius(12)

        // 文字内容
        Column({ space: AppSpacing.SM }) {
          Text(`「${this.todayQuote?.momentText ?? '风很大，但那一刻突然就不焦虑了。'}」`)
            .fontSize(AppFontSize.BODY)
            .fontColor('#FFFFFF')
            .lineHeight(24)
            .textShadow({ radius: 4, color: '#80000000', offsetX: 0, offsetY: 2 })
          Text(`来自 · ${this.todayQuote?.sourceTitle ?? '生活随拍'}`)
            .fontSize(AppFontSize.CAPTION)
            .fontColor('#CCCCCC')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding(AppSpacing.LG)

        // 收藏到我的按钮
        Button('收藏到我的')
          .fontSize(AppFontSize.CAPTION)
          .fontColor(AppColors.PAGE_BG)
          .backgroundColor(AppColors.ACCENT_PRIMARY)
          .borderRadius(16)
          .height(32)
          .padding({ left: 12, right: 12 })
          .margin({ right: AppSpacing.MD, bottom: AppSpacing.MD })
          .onClick(() => {
            this.collectTodayQuote()
          })
      }
    }
    .width('100%')
  }

  /** 热门名场面 - 横向滚动（真实图片） */
  @Builder
  hotScenesSection() {
    Column({ space: AppSpacing.SM }) {
      Text('热门名场面')
        .fontSize(AppFontSize.SUBTITLE)
        .fontColor(AppColors.TEXT_PRIMARY)
        .width('100%')

      Scroll() {
        Row({ space: AppSpacing.MD }) {
          ForEach(this.hotScenes, (scene: HotScene) => {
            Column() {
              Stack({ alignContent: Alignment.BottomEnd }) {
                // 封面 - 直接渲染以响应状态变化
                Image($rawfile(scene.coverImage))
                  .width(140)
                  .height(100)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(8)

                // 来源标签
                Text(scene.source)
                  .fontSize(10)
                  .fontColor('#FFFFFF')
                  .backgroundColor('#80000000')
                  .borderRadius(4)
                  .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                  .margin({ right: 6, bottom: 6 })
              }

              Column({ space: 4 }) {
                Text(scene.title)
                  .fontSize(AppFontSize.BODY_SM)
                  .fontColor(AppColors.TEXT_PRIMARY)
                  .maxLines(1)
                Text(`「${scene.quote}」`)
                  .fontSize(AppFontSize.CAPTION)
                  .fontColor(AppColors.TEXT_TERTIARY)
                  .maxLines(1)
              }
              .width(140)
              .alignItems(HorizontalAlign.Start)
              .margin({ top: AppSpacing.SM })

              // 收藏按钮
              Button('收藏')
                .fontSize(10)
                .fontColor(AppColors.PAGE_BG)
                .backgroundColor(AppColors.ACCENT_PRIMARY)
                .borderRadius(12)
                .height(24)
                .width(140)
                .onClick(() => {
                  this.collectHotScene(scene)
                })
            }
          }, (scene: HotScene) => scene.id)
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  /** 情绪专题板块 - 真实图片 */
  @Builder
  topicsSection() {
    Column({ space: AppSpacing.SM }) {
      Row() {
        Text($r('app.string.topic_list_title'))
          .fontSize(AppFontSize.SUBTITLE)
          .fontColor(AppColors.TEXT_PRIMARY)
        Blank()
        Text('全部')
          .fontColor(AppColors.ACCENT_PRIMARY)
          .onClick(() => router.pushUrl({ url: RoutePath.FILM_LIST }))
      }
      .width('100%')

      // 专题列表（纵向卡片）
      ForEach(this.topics, (topic: EmotionTopic, index: number) => {
        Row({ space: AppSpacing.MD }) {
          // 封面图 - 使用真实图片
          this.renderImage(
            this.getEmotionImage(topic.emotion ?? EmotionTag.HEAL, (index % 2) + 1),
            80,
            80,
            8
          )

          // 标题 + 简介
          Column({ space: 4 }) {
            Text(topic.title)
              .fontSize(AppFontSize.BODY)
              .fontColor(AppColors.TEXT_PRIMARY)
              .maxLines(1)
            Text(topic.description)
              .fontSize(AppFontSize.CAPTION)
              .fontColor(AppColors.TEXT_TERTIARY)
              .maxLines(2)
            Text(`${topic.frameIds.length} 条素材`)
              .fontSize(10)
              .fontColor(AppColors.ACCENT_PRIMARY)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
        }
        .width('100%')
        .padding(AppSpacing.MD)
        .backgroundColor(AppColors.SURFACE_BG)
        .borderRadius(12)
        .onClick(() => {
          router.pushUrl({
            url: RoutePath.TOPIC_DETAIL,
            params: { topicId: topic.id }
          })
        })
      }, (topic: EmotionTopic) => topic.id)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  /** 场景素材库板块 - 真实图片 */
  @Builder
  sceneLibrariesSection() {
    Column({ space: AppSpacing.SM }) {
      Row({ space: 8 }) {
        Text('场景素材库')
          .fontSize(AppFontSize.SUBTITLE)
          .fontColor(AppColors.TEXT_PRIMARY)
        Text('即用素材集')
          .fontSize(12)
          .fontColor(AppColors.TEXT_TERTIARY)
          .backgroundColor(AppColors.SURFACE_BG)
          .borderRadius(8)
          .padding({ left: 8, right: 8, top: 2, bottom: 2 })
      }
      .width('100%')

      List({ space: AppSpacing.MD }) {
        ForEach(this.sceneLibraries, (library: SceneLibrary) => {
          ListItem() {
            Row({ space: AppSpacing.MD }) {
              // 封面 - 真实图片
              this.renderImage(library.coverImage, 60, 60, 8)

              Column({ space: 4 }) {
                Row({ space: 6 }) {
                  Text(library.title)
                    .fontSize(AppFontSize.BODY)
                    .fontColor(AppColors.TEXT_PRIMARY)
                  Text(library.usageScenario)
                    .fontSize(10)
                    .fontColor(AppColors.ACCENT_PRIMARY)
                    .backgroundColor('#1A4A90E2')
                    .borderRadius(4)
                    .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                }
                Text(library.description)
                  .fontSize(AppFontSize.CAPTION)
                  .fontColor(AppColors.TEXT_TERTIARY)
                Text(`${library.frameIds.length} 条素材`)
                  .fontSize(10)
                  .fontColor(AppColors.TEXT_SECONDARY)
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Text('→')
                .fontSize(16)
                .fontColor(AppColors.TEXT_TERTIARY)
            }
            .width('100%')
            .padding(AppSpacing.MD)
            .backgroundColor(AppColors.SURFACE_BG)
            .borderRadius(12)
            .onClick(() => {
              router.pushUrl({
                url: RoutePath.SCENE_LIBRARY_DETAIL,
                params: { libraryId: library.id }
              })
            })
          }
        }, (library: SceneLibrary) => library.id)
      }
      .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
