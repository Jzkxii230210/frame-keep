/**
 * FrameKeep（帧藏）- 数据统计组件
 * 展示用户的使用统计数据，包括帧数、合集数、情绪和来源分布
 */
import { EmotionTag, SourceType } from '../Constants'
import { AppColors, AppFontSize, AppSpacing } from '../Styles'
import { StatisticsData } from '../MockData'

@Component
export struct DataStatistics {
  @Prop statistics: StatisticsData = new StatisticsData()

  /** 获取情绪标签显示名称 */
  private getEmotionLabel(tag: string): string {
    switch (tag) {
      case EmotionTag.HEAL:
        return '治愈'
      case EmotionTag.BURN:
        return '燃向'
      case EmotionTag.SAD:
        return '伤感'
      case EmotionTag.FUNNY:
        return '搞笑'
      default:
        return tag
    }
  }

  /** 获取情绪标签颜色 */
  private getEmotionColor(tag: string): string {
    switch (tag) {
      case EmotionTag.HEAL:
        return '#4CAF50' // 绿色
      case EmotionTag.BURN:
        return '#FF5722' // 橙红色
      case EmotionTag.SAD:
        return '#2196F3' // 蓝色
      case EmotionTag.FUNNY:
        return '#FFC107' // 黄色
      default:
        return AppColors.TEXT_TERTIARY
    }
  }

  /** 获取来源类型显示名称 */
  private getSourceLabel(type: string): string {
    switch (type) {
      case SourceType.FILM:
        return '影视'
      case SourceType.ANIME:
        return '动漫'
      case SourceType.LIFE:
        return '生活'
      case SourceType.OTHER:
        return '其他'
      default:
        return type
    }
  }

  /** 获取来源类型颜色 */
  private getSourceColor(type: string): string {
    switch (type) {
      case SourceType.FILM:
        return '#E8B923' // 影院金
      case SourceType.ANIME:
        return '#E91E63' // 粉色
      case SourceType.LIFE:
        return '#00BCD4' // 青色
      case SourceType.OTHER:
        return '#9E9E9E' // 灰色
      default:
        return AppColors.TEXT_TERTIARY
    }
  }

  build() {
    Column({ space: AppSpacing.MD }) {
      // 总体数据概览
      this.OverviewCard()
      
      // 情绪分布统计
      this.EmotionDistributionCard()
      
      // 来源分布统计
      this.SourceDistributionCard()
    }
    .width('100%')
  }

  /** 总体数据概览卡片 */
  @Builder
  OverviewCard() {
    Column() {
      Text('数据概览')
        .fontSize(AppFontSize.SUBTITLE)
        .fontWeight(FontWeight.Medium)
        .fontColor(AppColors.TEXT_PRIMARY)
        .width('100%')
        .margin({ bottom: AppSpacing.SM })

      Row({ space: AppSpacing.MD }) {
        // 收藏帧数
        this.StatItem('收藏帧数', this.statistics.totalFrames, $r('sys.symbol.bookmark'))
        
        // 合集数
        this.StatItem('合集数', this.statistics.totalAlbums, $r('sys.symbol.rectangle_stack'))
        
        // 回收站
        this.StatItem('回收站', this.statistics.recycleBinCount, $r('sys.symbol.trash'))
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .padding(AppSpacing.MD)
    .backgroundColor(AppColors.SURFACE_BG)
    .borderRadius(12)
  }

  /** 统计项 */
  @Builder
  StatItem(label: string, count: number, icon: Resource) {
    Column({ space: AppSpacing.XS }) {
      SymbolGlyph(icon)
        .fontSize(24)
        .fontColor([AppColors.ACCENT_PRIMARY])
      
      Text(count.toString())
        .fontSize(AppFontSize.HEADLINE)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppColors.TEXT_PRIMARY)
      
      Text(label)
        .fontSize(AppFontSize.BODY_SM)
        .fontColor(AppColors.TEXT_SECONDARY)
    }
    .layoutWeight(1)
    .padding(AppSpacing.SM)
  }

  /** 情绪分布统计卡片 */
  @Builder
  EmotionDistributionCard() {
    Column() {
      Text('情绪分布')
        .fontSize(AppFontSize.SUBTITLE)
        .fontWeight(FontWeight.Medium)
        .fontColor(AppColors.TEXT_PRIMARY)
        .width('100%')
        .margin({ bottom: AppSpacing.SM })

      Column({ space: AppSpacing.SM }) {
        ForEach([
          EmotionTag.HEAL,
          EmotionTag.BURN,
          EmotionTag.SAD,
          EmotionTag.FUNNY
        ], (tag: string) => {
          this.DistributionItem(
            this.getEmotionLabel(tag),
            this.statistics.emotionDistribution[tag] || 0,
            this.statistics.totalFrames,
            this.getEmotionColor(tag)
          )
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding(AppSpacing.MD)
    .backgroundColor(AppColors.SURFACE_BG)
    .borderRadius(12)
  }

  /** 来源分布统计卡片 */
  @Builder
  SourceDistributionCard() {
    Column() {
      Text('来源分布')
        .fontSize(AppFontSize.SUBTITLE)
        .fontWeight(FontWeight.Medium)
        .fontColor(AppColors.TEXT_PRIMARY)
        .width('100%')
        .margin({ bottom: AppSpacing.SM })

      Column({ space: AppSpacing.SM }) {
        ForEach([
          SourceType.FILM,
          SourceType.ANIME,
          SourceType.LIFE,
          SourceType.OTHER
        ], (type: string) => {
          this.DistributionItem(
            this.getSourceLabel(type),
            this.statistics.sourceDistribution[type] || 0,
            this.statistics.totalFrames,
            this.getSourceColor(type)
          )
        })
      }
      .width('100%')
    }
    .width('100%')
    .padding(AppSpacing.MD)
    .backgroundColor(AppColors.SURFACE_BG)
    .borderRadius(12)
  }

  /** 分布项（带进度条） */
  @Builder
  DistributionItem(label: string, count: number, total: number, color: string) {
    Column({ space: AppSpacing.XS }) {
      Row() {
        Text(label)
          .fontSize(AppFontSize.BODY_SM)
          .fontColor(AppColors.TEXT_SECONDARY)
          .layoutWeight(1)

        Text(`${count}`)
          .fontSize(AppFontSize.BODY_SM)
          .fontColor(AppColors.TEXT_PRIMARY)
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')

      // 进度条
      Stack() {
        // 背景条
        Row()
          .width('100%')
          .height(6)
          .backgroundColor('#2A2A2E')
          .borderRadius(3)

        // 进度条
        Row()
          .width(total > 0 ? `${(count / total) * 100}%` : '0%')
          .height(6)
          .backgroundColor(color)
          .borderRadius(3)
      }
      .width('100%')
      .alignContent(Alignment.Start)
    }
    .width('100%')
  }
}
