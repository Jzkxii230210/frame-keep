/**
 * FrameKeep（帧藏）- 批量操作栏组件
 * 
 * 在多选模式下显示，提供批量删除等操作
 */
import { AppColors, AppFontSize, AppSpacing } from '../Styles';

@Component
export struct BatchActionBar {
  /** 选中的数量 */
  @Prop selectedCount: number = 0
  
  /** 批量删除回调 */
  onBatchDelete: () => void = () => {}
  
  /** 取消回调 */
  onCancel: () => void = () => {}
  
  build() {
    Row({ space: AppSpacing.SM }) {
      // 选中数量提示
      Text(`已选 ${this.selectedCount} 项`)
        .fontSize(AppFontSize.BODY_SM)
        .fontColor(AppColors.TEXT_SECONDARY)
        .layoutWeight(1)
      
      // 批量删除按钮 - 蓝色背景
      Button('删除')
        .fontSize(AppFontSize.CAPTION)
        .fontColor(AppColors.PAGE_BG)
        .backgroundColor('#4A90E2')
        .borderRadius(16)
        .height(32)
        .padding({ left: 12, right: 12 })
        .enabled(this.selectedCount > 0)
        .opacity(this.selectedCount > 0 ? 1.0 : 0.5)
        .onClick(() => {
          this.onBatchDelete()
        })
      
      // 取消按钮
      Button('取消')
        .fontSize(AppFontSize.CAPTION)
        .fontColor(AppColors.TEXT_SECONDARY)
        .backgroundColor(AppColors.SURFACE_BG)
        .borderRadius(16)
        .height(32)
        .padding({ left: 12, right: 12 })
        .onClick(() => {
          this.onCancel()
        })
    }
    .width('100%')
    .height(56)
    .padding({ left: AppSpacing.PAGE_HORIZONTAL, right: AppSpacing.PAGE_HORIZONTAL })
    .backgroundColor(AppColors.SURFACE_BG)
    .shadow({
      radius: 8,
      color: '#000000',
      offsetX: 0,
      offsetY: -2
    })
  }
}
