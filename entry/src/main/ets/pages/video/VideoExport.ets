/**
 * FrameKeep（帧藏）- 视频导出（平台预设）
 */
import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { ExportPresetId, EXPORT_PRESET_LABEL, RouteParams } from '../../common/Constants';
import { FrameItem, MockDataStore } from '../../common/MockData';
import { PageShell } from '../../common/components/PageShell';
import { AppColors, AppFontSize, AppSpacing } from '../../common/Styles';

@Entry
@Component
struct VideoExport {
  @State frame: FrameItem | undefined = undefined
  @State selectedPreset: string = ExportPresetId.WECHAT_MOMENTS
  @State exportProgress: number = 0
  @State isExporting: boolean = false
  private frameId: string = ''
  private presets: string[] = [
    ExportPresetId.WECHAT_MOMENTS,
    ExportPresetId.XIAOHONGSHU,
    ExportPresetId.ARCHIVE_HD
  ]

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, string>
    this.frameId = params[RouteParams.FRAME_ID] ?? ''
    this.frame = MockDataStore.getFrameById(this.frameId)
    if (this.frame) {
      this.selectedPreset = this.frame.exportPreset
    }
  }

  build() {
    Column() {
      PageShell({ title: '导出视频', content: () => { this.body() } })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  body() {
    Column({ space: AppSpacing.LG }) {
      Text('选择发布预设')
        .fontColor(AppColors.TEXT_PRIMARY)

      ForEach(this.presets, (preset: string) => {
        Row() {
          Column({ space: 4 }) {
            Text(EXPORT_PRESET_LABEL[preset])
              .fontColor(AppColors.TEXT_PRIMARY)
            Text(this.presetDesc(preset))
              .fontSize(AppFontSize.CAPTION)
              .fontColor(AppColors.TEXT_TERTIARY)
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          Radio({ value: preset, group: 'export' })
            .checked(this.selectedPreset === preset)
            .onChange((checked: boolean) => {
              if (checked) {
                this.selectedPreset = preset
              }
            })
        }
        .width('100%')
        .padding(AppSpacing.MD)
        .backgroundColor(AppColors.SURFACE_BG)
        .borderRadius(12)
        .onClick(() => { this.selectedPreset = preset })
      }, (preset: string) => preset)

      if (this.isExporting) {
        Progress({ value: this.exportProgress, total: 100, type: ProgressType.Linear })
          .color(AppColors.ACCENT_PRIMARY)
      }

      Button($r('app.string.btn_export'))
        .width('100%')
        .backgroundColor(AppColors.ACCENT_PRIMARY)
        .fontColor(AppColors.PAGE_BG)
        .enabled(!this.isExporting)
        .onClick(() => {
          this.mockExport()
        })
    }
    .padding(AppSpacing.PAGE_HORIZONTAL)
  }

  private presetDesc(preset: string): string {
    if (preset === ExportPresetId.WECHAT_MOMENTS) {
      return '1:1 · 最长 15s · 720p'
    }
    if (preset === ExportPresetId.XIAOHONGSHU) {
      return '9:16 · 最长 60s · 1080p'
    }
    return '原比例 · 1080p'
  }

  private mockExport(): void {
    this.isExporting = true
    this.exportProgress = 0
    const timer = setInterval(() => {
      this.exportProgress += 20
      if (this.exportProgress >= 100) {
        clearInterval(timer)
        this.isExporting = false
        if (this.frame) {
          this.frame.exportPreset = this.selectedPreset
          MockDataStore.updateFrame(this.frame)
        }
        promptAction.showToast({ message: '导出成功，已归档到收藏' })
        router.back()
      }
    }, 200)
  }
}
