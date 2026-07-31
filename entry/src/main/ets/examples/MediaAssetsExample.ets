/**
 * FrameKeep（帧藏）- 素材使用示例
 * 
 * 演示如何在应用中使用素材资源
 */
import { MediaAssets, MediaAssetsManager, EmotionType } from '../common/utils/MediaAssetsManager';

/**
 * 素材使用示例组件
 * 展示各种素材的加载和使用方式
 */
@Component
export struct MediaAssetsExample {
  build() {
    Scroll() {
      Column({ space: 20 }) {
        // 1. 直接使用预定义常量
        this.example1_DirectUsage()

        // 2. 使用 MediaAssetsManager 动态获取
        this.example2_DynamicUsage()

        // 3. 批量获取素材
        this.example3_BatchUsage()

        // 4. 随机获取素材
        this.example4_RandomUsage()
      }
      .padding(20)
    }
    .width('100%')
    .height('100%')
  }

  /** 示例1：直接使用预定义常量 */
  @Builder
  example1_DirectUsage() {
    Column({ space: 10 }) {
      Text('示例1：直接使用预定义常量')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)

      // 显示治愈系图片
      Image($rawfile(MediaAssets.HEAL_IMAGES.IMG_001))
        .width(200)
        .height(150)
        .objectFit(ImageFit.Cover)

      // 显示燃向图片
      Image($rawfile(MediaAssets.BURN_IMAGES.IMG_001))
        .width(200)
        .height(150)
        .objectFit(ImageFit.Cover)

      // 显示来源封面
      Image($rawfile(MediaAssets.SOURCE_COVERS.FILM_001))
        .width(100)
        .height(150)
        .objectFit(ImageFit.Cover)
    }
    .width('100%')
    .padding(10)
    .backgroundColor('#F5F5F5')
    .borderRadius(8)
  }

  /** 示例2：使用 MediaAssetsManager 动态获取 */
  @Builder
  example2_DynamicUsage() {
    Column({ space: 10 }) {
      Text('示例2：使用 MediaAssetsManager 动态获取')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)

      // 动态获取治愈系图片
      Image($rawfile(MediaAssetsManager.getInstance().getEmotionFrameImage(EmotionType.HEAL, 1)))
        .width(200)
        .height(150)
        .objectFit(ImageFit.Cover)

      // 动态获取燃向视频封面
      Image($rawfile(MediaAssetsManager.getInstance().getEmotionFrameImage(EmotionType.BURN, 2)))
        .width(200)
        .height(150)
        .objectFit(ImageFit.Cover)

      // 动态获取模板背景
      Image($rawfile(MediaAssetsManager.getInstance().getTemplateBackground('gradient', 1)))
        .width(200)
        .height(150)
        .objectFit(ImageFit.Cover)
    }
    .width('100%')
    .padding(10)
    .backgroundColor('#F5F5F5')
    .borderRadius(8)
  }

  /** 示例3：批量获取素材 */
  @Builder
  example3_BatchUsage() {
    Column({ space: 10 }) {
      Text('示例3：批量获取素材')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)

      // 批量获取治愈系图片
      Grid() {
        ForEach(MediaAssetsManager.getInstance().getEmotionFrameImages(EmotionType.HEAL, 2), 
          (imgPath: string, index: number) => {
            GridItem() {
              Image($rawfile(imgPath))
                .width('100%')
                .height(100)
                .objectFit(ImageFit.Cover)
            }
          }, (imgPath: string, index: number) => `img_${index}`)
      }
      .columnsTemplate('1fr 1fr')
      .rowsGap(10)
      .columnsGap(10)
      .height(220)
    }
    .width('100%')
    .padding(10)
    .backgroundColor('#F5F5F5')
    .borderRadius(8)
  }

  /** 示例4：随机获取素材 */
  @Builder
  example4_RandomUsage() {
    Column({ space: 10 }) {
      Text('示例4：随机获取素材')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)

      // 随机获取治愈系图片
      Image($rawfile(MediaAssetsManager.getInstance().getRandomEmotionFrameImage(EmotionType.HEAL)))
        .width(200)
        .height(150)
        .objectFit(ImageFit.Cover)

      // 随机获取燃向图片
      Image($rawfile(MediaAssetsManager.getInstance().getRandomEmotionFrameImage(EmotionType.BURN)))
        .width(200)
        .height(150)
        .objectFit(ImageFit.Cover)
    }
    .width('100%')
    .padding(10)
    .backgroundColor('#F5F5F5')
    .borderRadius(8)
  }
}

/**
 * 使用说明：
 * 
 * 1. 直接使用预定义常量（推荐）
 *    - MediaAssets.HEAL_IMAGES.IMG_001
 *    - MediaAssets.VIDEOS.HEAL_001
 *    - MediaAssets.BGM.HEAL_001
 * 
 * 2. 使用 MediaAssetsManager 动态获取
 *    - MediaAssetsManager.getInstance().getEmotionFrameImage(EmotionType.HEAL, 1)
 *    - MediaAssetsManager.getInstance().getEmotionFrameVideo(EmotionType.BURN, 1)
 *    - MediaAssetsManager.getInstance().getBGM(EmotionType.SAD, 1)
 * 
 * 3. 批量获取
 *    - MediaAssetsManager.getInstance().getEmotionFrameImages(EmotionType.HEAL, 2)
 * 
 * 4. 随机获取
 *    - MediaAssetsManager.getInstance().getRandomEmotionFrameImage(EmotionType.HEAL)
 * 
 * 5. 获取占位图（当素材不存在时）
 *    - MediaAssetsManager.getInstance().getPlaceholder(MediaType.IMAGE)
 */
