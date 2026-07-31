/**
 * FrameKeep（帧藏）- 批量打标签对话框
 * 
 * 用于为多个情绪帧批量添加标签
 */
import { AppColors, AppFontSize, AppSpacing } from '../Styles';

@CustomDialog
export struct BatchTagDialog {
  /** 对话框控制器 */
  controller: CustomDialogController
  
  /** 用户输入的标签（逗号分隔） */
  @State tagInput: string = ''
  
  /** 确认回调 */
  private onConfirm: ((tags: string[]) => void) | undefined = undefined
  
  build() {
    Column({ space: AppSpacing.LG }) {
      // 标题
      Text('批量打标签')
        .fontSize(AppFontSize.TITLE)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppColors.TEXT_PRIMARY)
      
      // 说明文字
      Text('输入标签，多个标签用逗号分隔')
        .fontSize(AppFontSize.BODY_SM)
        .fontColor(AppColors.TEXT_SECONDARY)
      
      // 标签输入框
      TextInput({ placeholder: '例如：经典, 台词, 治愈', text: this.tagInput })
        .width('100%')
        .height(44)
        .backgroundColor(AppColors.PAGE_BG)
        .fontColor(AppColors.TEXT_PRIMARY)
        .placeholderColor(AppColors.TEXT_TERTIARY)
        .onChange((value: string) => {
          this.tagInput = value
        })
      
      // 操作按钮
      Row({ space: AppSpacing.MD }) {
        Button('取消')
          .fontSize(AppFontSize.BODY)
          .fontColor(AppColors.TEXT_SECONDARY)
          .backgroundColor(AppColors.SURFACE_BG)
          .borderRadius(8)
          .layoutWeight(1)
          .onClick(() => {
            this.controller.close()
          })
        
        Button('确定')
          .fontSize(AppFontSize.BODY)
          .fontColor(AppColors.PAGE_BG)
          .backgroundColor(AppColors.ACCENT_PRIMARY)
          .borderRadius(8)
          .layoutWeight(1)
          .enabled(this.tagInput.trim().length > 0)
          .opacity(this.tagInput.trim().length > 0 ? 1.0 : 0.5)
          .onClick(() => {
            // 解析标签（逗号分隔）
            const tags = this.tagInput
              .split(/[,，]/)
              .map((tag: string) => tag.trim())
              .filter((tag: string) => tag.length > 0)
            
            if (tags.length > 0 && this.onConfirm !== undefined) {
              this.onConfirm(tags)
            }
            this.controller.close()
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(AppSpacing.LG)
    .backgroundColor(AppColors.SURFACE_BG)
    .borderRadius(12)
  }
  
  /**
   * 设置确认回调
   */
  setOnConfirm(callback: (tags: string[]) => void): void {
    this.onConfirm = callback
  }
}
