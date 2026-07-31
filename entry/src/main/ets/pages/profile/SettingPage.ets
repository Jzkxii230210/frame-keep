/**
 * FrameKeep（帧藏）- 设置页
 */
import { PageShell } from '../../common/components/PageShell';
import { AppColors, AppFontSize, AppSpacing } from '../../common/Styles';

@Entry
@Component
struct SettingPage {
  @State defaultQuality: number = 1
  @State autoSave: boolean = true

  build() {
    Column() {
      PageShell({ title: '偏好设置', content: () => { this.body() } })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  body() {
    Column({ space: AppSpacing.LG }) {
      Row() {
        Text('默认导出质量')
          .fontColor(AppColors.TEXT_PRIMARY)
          .layoutWeight(1)
        Select([
          { value: '省空间 720p' },
          { value: '平衡 1080p' },
          { value: '高画质' }
        ])
          .selected(this.defaultQuality)
          .value('平衡 1080p')
          .font({ size: AppFontSize.BODY_SM })
          .fontColor(AppColors.TEXT_SECONDARY)
          .onSelect((index: number) => { this.defaultQuality = index })
      }
      .width('100%')
      .padding(AppSpacing.MD)
      .backgroundColor(AppColors.SURFACE_BG)
      .borderRadius(12)

      Row() {
        Text('自动保存草稿')
          .fontColor(AppColors.TEXT_PRIMARY)
          .layoutWeight(1)
        Toggle({ type: ToggleType.Switch, isOn: this.autoSave })
          .selectedColor(AppColors.ACCENT_PRIMARY)
          .onChange((v: boolean) => { this.autoSave = v })
      }
      .width('100%')
      .padding(AppSpacing.MD)
      .backgroundColor(AppColors.SURFACE_BG)
      .borderRadius(12)

      Text('备份同步 · ' + $r('app.string.coming_soon'))
        .fontSize(AppFontSize.CAPTION)
        .fontColor(AppColors.TEXT_TERTIARY)
    }
    .padding(AppSpacing.PAGE_HORIZONTAL)
  }
}
