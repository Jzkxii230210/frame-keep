/**
 * FrameKeep（帧藏）- 合集编辑页（核心功能页）
 * 支持编辑标题/简介、素材管理、拖拽排序、预览
 */
import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { RoutePath, RouteParams } from '../../common/Constants';
import { Album, FrameItem, MockDataStore } from '../../common/MockData';
import { MediaAssets } from '../../common/utils/MediaAssetsManager';
import { AppColors, AppFontSize, AppSpacing } from '../../common/Styles';

@Entry
@Component
struct AlbumEdit {
  @State album: Album | undefined = undefined
  @State albumName: string = ''
  @State albumDesc: string = ''
  @State frames: FrameItem[] = []
  @State selectedFrameIds: Set<string> = new Set<string>()
  @State isBatchMode: boolean = false
  @State showAddDialog: boolean = false
  @State showDeleteConfirm: boolean = false
  private albumId: string = ''

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, string>
    this.albumId = params[RouteParams.ALBUM_ID] ?? ''
    this.loadAlbum()
  }

  private loadAlbum(): void {
    if (this.albumId.length > 0) {
      this.album = MockDataStore.getAlbumById(this.albumId)
      if (this.album) {
        this.albumName = this.album.name
        this.albumDesc = this.album.description
        this.frames = MockDataStore.getFramesByAlbumId(this.albumId)
      }
    }
  }

  /** 保存合集信息 */
  private saveAlbum(): void {
    if (this.album) {
      this.album.name = this.albumName
      this.album.description = this.albumDesc
      this.album.updatedAt = Date.now()
      MockDataStore.updateAlbum(this.album)
      promptAction.showToast({ message: '已保存' })
    }
  }

  /** 移除素材 */
  private removeFrame(frameId: string): void {
    if (this.album) {
      MockDataStore.batchRemoveFromAlbum([frameId], this.album.id)
      this.loadAlbum()
    }
  }

  /** 批量移除 */
  private batchRemove(): void {
    if (this.album && this.selectedFrameIds.size > 0) {
      MockDataStore.batchRemoveFromAlbum(Array.from(this.selectedFrameIds), this.album.id)
      this.selectedFrameIds = new Set<string>()
      this.isBatchMode = false
      this.loadAlbum()
    }
  }

  /** 删除合集 */
  private deleteAlbum(): void {
    if (this.album) {
      MockDataStore.deleteAlbum(this.album.id)
      this.showDeleteConfirm = false
      router.back()
    }
  }

  /** 添加素材到合集 */
  private addFramesToAlbum(frameIds: string[]): void {
    if (this.album) {
      MockDataStore.batchAddToAlbum(frameIds, this.album.id)
      this.showAddDialog = false
      this.loadAlbum()
    }
  }

  /** 渲染图片（支持 rawfile 和普通路径） */
  @Builder
  renderImage(uri: string, width: Length, height: Length, radius: number = 8) {
    if (uri && uri.length > 0) {
      // rawfile 路径需要用 $rawfile() 包装
      if (!uri.startsWith('file://') && !uri.startsWith('datashare://') && !uri.startsWith('mock://')) {
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

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column() {
        // 顶栏
        Row() {
          Button({ type: ButtonType.Circle }) {
            Text('←')
              .fontSize(20)
              .fontColor(AppColors.TEXT_PRIMARY)
          }
          .width(36)
          .height(36)
          .backgroundColor(AppColors.SURFACE_BG)
          .onClick(() => router.back())

          Text('编辑合集')
            .fontSize(AppFontSize.HEADLINE)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppColors.TEXT_PRIMARY)
            .layoutWeight(1)
            .margin({ left: AppSpacing.SM })

          Row({ space: AppSpacing.SM }) {
            Button('保存')
              .fontSize(AppFontSize.BODY_SM)
              .fontColor(AppColors.PAGE_BG)
              .backgroundColor(AppColors.ACCENT_PRIMARY)
              .borderRadius(16)
              .height(32)
              .onClick(() => {
                this.saveAlbum()
                router.back()
              })

            Button('预览')
              .fontSize(AppFontSize.BODY_SM)
              .fontColor(AppColors.PAGE_BG)
              .backgroundColor(AppColors.ACCENT_PRIMARY)
              .borderRadius(16)
              .height(32)
              .onClick(() => {
                router.pushUrl({
                  url: RoutePath.ALBUM_PREVIEW,
                  params: { albumId: this.albumId }
                })
              })
          }
        }
        .width('100%')
        .padding({
          left: AppSpacing.PAGE_HORIZONTAL,
          right: AppSpacing.PAGE_HORIZONTAL,
          top: AppSpacing.LG,
          bottom: AppSpacing.MD
        })

        Scroll() {
          Column({ space: AppSpacing.LG }) {
            // 合集信息编辑
            Column({ space: AppSpacing.SM }) {
              Text('合集名称')
                .fontSize(AppFontSize.CAPTION)
                .fontColor(AppColors.TEXT_SECONDARY)
                .width('100%')
              TextInput({ text: this.albumName })
                .height(44)
                .backgroundColor(AppColors.SURFACE_BG)
                .borderRadius(8)
                .onChange((value: string) => {
                  this.albumName = value
                })
            }
            .width('100%')

            Column({ space: AppSpacing.SM }) {
              Text('简介')
                .fontSize(AppFontSize.CAPTION)
                .fontColor(AppColors.TEXT_SECONDARY)
                .width('100%')
              TextArea({ text: this.albumDesc })
                .height(80)
                .backgroundColor(AppColors.SURFACE_BG)
                .borderRadius(8)
                .onChange((value: string) => {
                  this.albumDesc = value
                })
            }
            .width('100%')

            // 素材网格
            Row() {
              Text(`素材 (${this.frames.length})`)
                .fontSize(AppFontSize.SUBTITLE)
                .fontColor(AppColors.TEXT_PRIMARY)
              Blank()
              if (this.isBatchMode) {
                Text('取消')
                  .fontSize(AppFontSize.BODY_SM)
                  .fontColor(AppColors.TEXT_SECONDARY)
                  .onClick(() => {
                    this.isBatchMode = false
                    this.selectedFrameIds = new Set<string>()
                  })
              } else {
                Text('管理')
                  .fontSize(AppFontSize.BODY_SM)
                  .fontColor(AppColors.ACCENT_PRIMARY)
                  .onClick(() => {
                    this.isBatchMode = true
                  })
              }
            }
            .width('100%')

            if (this.frames.length === 0) {
              Column({ space: AppSpacing.SM }) {
                Text('暂无素材')
                  .fontSize(AppFontSize.BODY)
                  .fontColor(AppColors.TEXT_SECONDARY)
                Text('点击底部「从收藏添加」添加素材')
                  .fontSize(AppFontSize.CAPTION)
                  .fontColor(AppColors.TEXT_TERTIARY)
              }
              .padding(AppSpacing.XL)
            } else {
              Grid() {
                ForEach(this.frames, (frame: FrameItem, index: number) => {
                  GridItem() {
                    Stack({ alignContent: Alignment.TopEnd }) {
                      // 素材卡片
                      Column() {
                        if (frame.screenshotUri.length > 0) {
                          this.renderImage(frame.screenshotUri, '100%', 100, 8)
                        } else {
                          // 无图片时使用默认图
                          this.renderImage(MediaAssets.HEAL_IMAGES.IMG_001, '100%', 100, 8)
                        }
                        Text(frame.momentText.length > 0 ? frame.momentText : '纯画面')
                          .fontSize(AppFontSize.CAPTION)
                          .fontColor(AppColors.TEXT_SECONDARY)
                          .maxLines(1)
                          .margin({ top: 4 })
                      }

                      // 批量模式：选择框
                      if (this.isBatchMode) {
                        Checkbox()
                          .select(this.selectedFrameIds.has(frame.id))
                          .selectedColor(AppColors.ACCENT_PRIMARY)
                          .onChange((checked: boolean) => {
                            if (checked) {
                              this.selectedFrameIds.add(frame.id)
                            } else {
                              this.selectedFrameIds.delete(frame.id)
                            }
                          })
                      } else {
                        // 非批量模式：移除按钮
                        Button({ type: ButtonType.Circle }) {
                          Text('×')
                            .fontSize(14)
                            .fontColor('#FFFFFF')
                        }
                        .width(24)
                        .height(24)
                        .backgroundColor('#80000000')
                        .onClick(() => {
                          this.removeFrame(frame.id)
                        })
                      }
                    }
                    .width('100%')
                  }
                }, (frame: FrameItem) => frame.id)
              }
              .columnsTemplate('1fr 1fr')
              .rowsGap(AppSpacing.MD)
              .columnsGap(AppSpacing.MD)
            }
          }
          .padding({
            left: AppSpacing.PAGE_HORIZONTAL,
            right: AppSpacing.PAGE_HORIZONTAL,
            bottom: 100 // 为底部操作栏留空间
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)

        // 底部操作栏
        this.bottomActionBar()
      }
      .width('100%')
      .height('100%')
      .backgroundColor(AppColors.PAGE_BG)

      // 添加素材对话框
      if (this.showAddDialog) {
        this.addFrameDialog()
      }

      // 删除确认对话框
      if (this.showDeleteConfirm) {
        this.deleteConfirmDialog()
      }
    }
    .width('100%')
    .height('100%')
  }

  /** 底部操作栏 */
  @Builder
  bottomActionBar() {
    Column() {
      if (this.isBatchMode && this.selectedFrameIds.size > 0) {
        Row({ space: AppSpacing.MD }) {
          Text(`已选 ${this.selectedFrameIds.size} 条`)
            .fontSize(AppFontSize.BODY_SM)
            .fontColor(AppColors.TEXT_SECONDARY)
            .layoutWeight(1)
          Button('移除')
            .fontSize(AppFontSize.BODY_SM)
            .fontColor(AppColors.PAGE_BG)
            .backgroundColor(AppColors.DANGER)
            .borderRadius(20)
            .height(36)
            .onClick(() => {
              this.batchRemove()
            })
        }
      } else {
        Row({ space: AppSpacing.SM }) {
          Button('从收藏添加')
            .layoutWeight(1)
            .height(44)
            .backgroundColor(AppColors.ACCENT_PRIMARY)
            .fontColor(AppColors.PAGE_BG)
            .borderRadius(22)
            .onClick(() => {
              this.showAddDialog = true
            })

          Button('删除合集')
            .height(44)
            .backgroundColor(AppColors.SURFACE_BG)
            .fontColor(AppColors.DANGER)
            .borderRadius(22)
            .onClick(() => {
              this.showDeleteConfirm = true
            })
        }
      }
    }
    .width('100%')
    .padding({
      left: AppSpacing.PAGE_HORIZONTAL,
      right: AppSpacing.PAGE_HORIZONTAL,
      top: AppSpacing.MD,
      bottom: AppSpacing.LG
    })
    .backgroundColor(AppColors.SURFACE_BG)
  }

  /** 添加素材对话框 */
  @Builder
  addFrameDialog() {
    Column() {
      Column({ space: AppSpacing.LG }) {
        Text('从收藏添加')
          .fontSize(AppFontSize.SUBTITLE)
          .fontWeight(FontWeight.Bold)

        // 所有收藏的素材
        Column() {
          List({ space: AppSpacing.SM }) {
            ForEach(MockDataStore.getAllFrames(true), (frame: FrameItem) => {
              ListItem() {
                Row({ space: AppSpacing.SM }) {
                  // 显示素材图片
                  if (frame.screenshotUri && frame.screenshotUri.length > 0) {
                    this.renderImage(frame.screenshotUri, 40, 40, 4)
                  } else {
                    Column()
                      .width(40)
                      .height(40)
                      .backgroundColor(AppColors.BADGE_BG)
                      .borderRadius(4)
                  }
                  Column({ space: 2 }) {
                    Text(frame.sourceTitle)
                      .fontSize(AppFontSize.BODY_SM)
                      .fontColor(AppColors.TEXT_PRIMARY)
                    Text(frame.momentText.length > 0 ? frame.momentText : '纯画面')
                      .fontSize(AppFontSize.CAPTION)
                      .fontColor(AppColors.TEXT_TERTIARY)
                      .maxLines(1)
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)
                  Blank()
                  if (this.frames.some((f: FrameItem) => f.id === frame.id)) {
                    Text('已添加')
                      .fontSize(AppFontSize.CAPTION)
                      .fontColor(AppColors.TEXT_TERTIARY)
                  } else {
                    Button('添加')
                      .fontSize(10)
                      .height(28)
                      .backgroundColor(AppColors.ACCENT_PRIMARY)
                      .fontColor(AppColors.PAGE_BG)
                      .onClick(() => {
                        this.addFramesToAlbum([frame.id])
                      })
                  }
                }
                .width('100%')
                .padding(AppSpacing.SM)
              }
            }, (frame: FrameItem) => frame.id)
          }
          .height(300)
        }

        Button('关闭')
          .width('100%')
          .height(44)
          .backgroundColor(AppColors.SURFACE_BG)
          .fontColor(AppColors.TEXT_PRIMARY)
          .onClick(() => {
            this.showAddDialog = false
          })
      }
      .width('85%')
      .padding(AppSpacing.LG)
      .backgroundColor(AppColors.SURFACE_BG)
      .borderRadius(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#80000000')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.showAddDialog = false
    })
  }

  /** 删除确认对话框 */
  @Builder
  deleteConfirmDialog() {
    Column() {
      Column({ space: AppSpacing.LG }) {
        Text('确认删除合集？')
          .fontSize(AppFontSize.SUBTITLE)
          .fontWeight(FontWeight.Bold)
        Text('删除后无法恢复，合集内的素材不会被删除')
          .fontSize(AppFontSize.BODY_SM)
          .fontColor(AppColors.TEXT_SECONDARY)

        Row({ space: AppSpacing.MD }) {
          Button('取消')
            .layoutWeight(1)
            .height(44)
            .backgroundColor(AppColors.SURFACE_BG)
            .fontColor(AppColors.TEXT_PRIMARY)
            .onClick(() => {
              this.showDeleteConfirm = false
            })
          Button('删除')
            .layoutWeight(1)
            .height(44)
            .backgroundColor(AppColors.DANGER)
            .fontColor('#FFFFFF')
            .onClick(() => {
              this.deleteAlbum()
            })
        }
        .width('100%')
      }
      .width('85%')
      .padding(AppSpacing.LG)
      .backgroundColor(AppColors.SURFACE_BG)
      .borderRadius(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#80000000')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.showDeleteConfirm = false
    })
  }
}
