/**
 * FrameKeep（帧藏）- 批量加入合集对话框
 * 
 * 用于将多个情绪帧批量加入合集
 */
import { AppColors, AppFontSize, AppSpacing } from '../Styles';
import { Album, MockDataStore } from '../MockData';

@CustomDialog
export struct BatchAddToAlbumDialog {
  /** 对话框控制器 */
  controller: CustomDialogController
  
  /** 合集列表 */
  @State albums: Album[] = []
  
  /** 选中的合集 ID */
  @State selectedAlbumId: string = ''
  
  /** 确认回调 */
  private onConfirm: ((albumId: string) => void) | undefined = undefined
  
  aboutToAppear(): void {
    this.albums = MockDataStore.getAllAlbums()
  }
  
  build() {
    Column({ space: AppSpacing.LG }) {
      // 标题
      Text('加入合集')
        .fontSize(AppFontSize.TITLE)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppColors.TEXT_PRIMARY)
      
      // 合集列表
      if (this.albums.length === 0) {
        Column({ space: AppSpacing.SM }) {
          Text('暂无合集')
            .fontSize(AppFontSize.BODY)
            .fontColor(AppColors.TEXT_SECONDARY)
          Text('请先创建合集')
            .fontSize(AppFontSize.CAPTION)
            .fontColor(AppColors.TEXT_TERTIARY)
        }
        .padding(AppSpacing.LG)
      } else {
        List({ space: AppSpacing.SM }) {
          ForEach(this.albums, (album: Album) => {
            ListItem() {
              Row({ space: AppSpacing.MD }) {
                // 选中指示器
                Column()
                  .width(20)
                  .height(20)
                  .borderRadius(10)
                  .backgroundColor(this.selectedAlbumId === album.id ? AppColors.ACCENT_PRIMARY : 'transparent')
                  .border({
                    width: 2,
                    color: this.selectedAlbumId === album.id ? AppColors.ACCENT_PRIMARY : AppColors.TEXT_TERTIARY
                  })
                
                // 合集信息
                Column({ space: 4 }) {
                  Text(album.name)
                    .fontSize(AppFontSize.BODY)
                    .fontColor(AppColors.TEXT_PRIMARY)
                  Text(`${album.frameIds.length} 个情绪帧`)
                    .fontSize(AppFontSize.CAPTION)
                    .fontColor(AppColors.TEXT_TERTIARY)
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
              }
              .width('100%')
              .padding(AppSpacing.MD)
              .backgroundColor(this.selectedAlbumId === album.id ? AppColors.BADGE_BG : 'transparent')
              .borderRadius(8)
              .onClick(() => {
                this.selectedAlbumId = album.id
              })
            }
          }, (album: Album) => album.id)
        }
        .width('100%')
        .height(200)
        .scrollBar(BarState.Off)
      }
      
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
          .enabled(this.selectedAlbumId.length > 0)
          .opacity(this.selectedAlbumId.length > 0 ? 1.0 : 0.5)
          .onClick(() => {
            if (this.selectedAlbumId.length > 0 && this.onConfirm !== undefined) {
              this.onConfirm(this.selectedAlbumId)
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
  setOnConfirm(callback: (albumId: string) => void): void {
    this.onConfirm = callback
  }
}
