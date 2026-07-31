/**
 * FrameKeep（帧藏）- 灵感合集 Tab 首页
 * 2列网格卡片布局，支持新建合集、排序筛选
 */
import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { AlbumType, RoutePath, RouteParams } from '../../common/Constants';
import { Album, FrameItem, MockDataStore } from '../../common/MockData';
import { MediaAssets } from '../../common/utils/MediaAssetsManager';
import { AppColors, AppFontSize, AppSpacing } from '../../common/Styles';

/** 排序方式 */
type SortType = 'createTime' | 'frameCount'

/** 合集分类筛选标签 */
type AlbumCategory = 'all' | 'image_text' | 'daily' | 'heal' | 'burn'

/** 分类标签显示名称 */
const CATEGORY_LABEL: Record<AlbumCategory, string> = {
  'all': '全部',
  'image_text': '图文',
  'daily': '日常',
  'heal': '治愈',
  'burn': '燃向'
}

@Component
export struct AlbumIndex {
  @State albums: Album[] = []
  @State filteredAlbums: Album[] = [] // 筛选后的合集列表
  @State showCreateDialog: boolean = false
  @State newAlbumName: string = ''
  @State newAlbumDesc: string = ''
  @State newAlbumCoverUri: string = '' // 新建合集的封面URI
  @State currentSort: SortType = 'createTime'
  @State showSortMenu: boolean = false
  // 分类筛选
  @State selectedCategory: AlbumCategory = 'all'
  // 多选模式
  @State isMultiSelectMode: boolean = false
  @State selectedAlbumIds: Set<string> = new Set<string>()
  // 卡片点击态
  @State pressedAlbumId: string = ''

  aboutToAppear(): void {
    this.loadAlbums()
  }

  onPageShow(): void {
    // 每次页面显示时刷新合集列表（从编辑页返回时会触发）
    this.loadAlbums()
  }

  private loadAlbums(): void {
    this.albums = MockDataStore.getAllAlbums()
    this.sortAlbums()
    this.applyCategoryFilter()
  }

  /** 排序合集 */
  private sortAlbums(): void {
    if (this.currentSort === 'createTime') {
      this.albums = this.albums.sort((a: Album, b: Album) => b.createdAt - a.createdAt)
    } else {
      this.albums = this.albums.sort((a: Album, b: Album) => b.frameIds.length - a.frameIds.length)
    }
  }

  /** 应用分类筛选 */
  private applyCategoryFilter(): void {
    if (this.selectedCategory === 'all') {
      this.filteredAlbums = [...this.albums]
    } else if (this.selectedCategory === 'image_text') {
      // 图文：筛选类型为 IMAGE_TEXT 的合集
      this.filteredAlbums = this.albums.filter((album: Album) => album.type === AlbumType.IMAGE_TEXT)
    } else if (this.selectedCategory === 'daily') {
      // 日常：筛选名称或描述包含"日常"的合集（临时方案）
      this.filteredAlbums = this.albums.filter((album: Album) => 
        album.name.includes('日常') || album.description.includes('日常')
      )
    } else if (this.selectedCategory === 'heal') {
      // 治愈：筛选名称或描述包含"治愈"的合集（临时方案）
      this.filteredAlbums = this.albums.filter((album: Album) => 
        album.name.includes('治愈') || album.description.includes('治愈')
      )
    } else if (this.selectedCategory === 'burn') {
      // 燃向：筛选名称或描述包含"燃"的合集（临时方案）
      this.filteredAlbums = this.albums.filter((album: Album) => 
        album.name.includes('燃') || album.description.includes('燃')
      )
    }
  }

  /** 切换排序方式 */
  private toggleSort(sortType: SortType): void {
    this.currentSort = sortType
    this.showSortMenu = false
    this.sortAlbums()
    this.applyCategoryFilter()
  }

  /** 切换分类筛选 */
  private toggleCategory(category: AlbumCategory): void {
    this.selectedCategory = category
    this.applyCategoryFilter()
  }

  /** 获取类型标签文字 */
  private getTypeLabel(type?: AlbumType): string {
    switch (type) {
      case AlbumType.IMAGE_TEXT:
        return '图文'
      case AlbumType.VIDEO_MIX:
        return '视频混剪'
      case AlbumType.MIXED:
        return '混合'
      default:
        return '图文'
    }
  }

  /** 获取类型标签颜色 */
  private getTypeColor(type?: AlbumType): string {
    switch (type) {
      case AlbumType.IMAGE_TEXT:
        return '#4CAF50' // 绿色
      case AlbumType.VIDEO_MIX:
        return '#FF9800' // 橙色
      case AlbumType.MIXED:
        return '#9C27B0' // 紫色
      default:
        return '#4CAF50'
    }
  }

  /** 进入多选模式 */
  private enterMultiSelectMode(): void {
    this.isMultiSelectMode = true
    this.selectedAlbumIds = new Set<string>()
  }

  /** 退出多选模式 */
  private exitMultiSelectMode(): void {
    this.isMultiSelectMode = false
    this.selectedAlbumIds = new Set<string>()
  }

  /** 切换选中状态 */
  private toggleSelection(albumId: string): void {
    const newSet = new Set<string>(this.selectedAlbumIds)
    if (newSet.has(albumId)) {
      newSet.delete(albumId)
    } else {
      newSet.add(albumId)
    }
    this.selectedAlbumIds = newSet
  }

  /** 全选/取消全选 */
  private toggleSelectAll(): void {
    if (this.selectedAlbumIds.size === this.albums.length) {
      // 已全选，取消全选
      this.selectedAlbumIds = new Set<string>()
    } else {
      // 全选
      const allIds = new Set<string>()
      this.albums.forEach((album: Album) => allIds.add(album.id))
      this.selectedAlbumIds = allIds
    }
  }

  /** 批量删除 */
  private batchDelete(): void {
    if (this.selectedAlbumIds.size === 0) {
      promptAction.showToast({ message: '请先选择要删除的合集' })
      return
    }
    // 删除选中的合集
    this.selectedAlbumIds.forEach((id: string) => {
      MockDataStore.deleteAlbum(id)
    })
    promptAction.showToast({ message: `已删除 ${this.selectedAlbumIds.size} 个合集` })
    this.exitMultiSelectMode()
    this.loadAlbums()
  }

  /** 批量导出 */
  private batchExport(): void {
    if (this.selectedAlbumIds.size === 0) {
      promptAction.showToast({ message: '请先选择要导出的合集' })
      return
    }
    promptAction.showToast({ message: `正在导出 ${this.selectedAlbumIds.size} 个合集...` })
    // TODO: 实现导出逻辑
  }

  /** 选择封面照片 */
  private async pickCoverPhoto(): Promise<void> {
    try {
      const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions()
      photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE
      photoSelectOptions.maxSelectNumber = 1
      
      const photoPicker = new photoAccessHelper.PhotoViewPicker()
      const photoSelectResult = await photoPicker.select(photoSelectOptions)
      
      if (photoSelectResult.photoUris && photoSelectResult.photoUris.length > 0) {
        this.newAlbumCoverUri = photoSelectResult.photoUris[0]
        console.info('选择封面照片成功：' + this.newAlbumCoverUri)
      }
    } catch (error) {
      console.error('选择封面照片失败：', JSON.stringify(error))
      promptAction.showToast({ message: '选择照片失败' })
    }
  }

  /** 创建合集 */
  private createAlbum(): void {
    if (this.newAlbumName.trim().length === 0) {
      promptAction.showToast({ message: '请输入合集名称' })
      return
    }
    const newAlbum = MockDataStore.createAlbum(this.newAlbumName.trim(), this.newAlbumDesc.trim(), this.newAlbumCoverUri)
    this.showCreateDialog = false
    this.newAlbumName = ''
    this.newAlbumDesc = ''
    this.newAlbumCoverUri = ''
    this.loadAlbums()
    // 跳转到编辑页
    router.pushUrl({
      url: RoutePath.ALBUM_EDIT,
      params: { albumId: newAlbum.id }
    })
  }

  /** 获取合集封面（首张素材） */
  private getAlbumCover(album: Album): string {
    if (album.frameIds.length > 0) {
      const frame = MockDataStore.getFrameById(album.frameIds[0])
      if (frame && frame.screenshotUri.length > 0) {
        return frame.screenshotUri
      }
    }
    return '' // 无封面
  }

  /** 渲染图片（支持 rawfile 和普通路径） */
  @Builder
  renderImage(uri: string, width: Length, height: Length, radius: number = 12) {
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
        // 顶栏 - 根据模式切换
        if (this.isMultiSelectMode) {
          // 多选模式顶栏 - 渐变背景
          Column() {
            Row() {
              Text('取消')
                .fontSize(AppFontSize.BODY)
                .fontColor(AppColors.TEXT_PRIMARY)
                .fontWeight(FontWeight.Medium)
                .onClick(() => this.exitMultiSelectMode())
              Blank()
              Text(`已选 ${this.selectedAlbumIds.size} 项`)
                .fontSize(AppFontSize.BODY)
                .fontWeight(FontWeight.Bold)
                .fontColor(AppColors.TEXT_PRIMARY)
              Blank()
              Text(this.selectedAlbumIds.size === this.albums.length ? '取消全选' : '全选')
                .fontSize(AppFontSize.BODY)
                .fontColor(AppColors.ACCENT_PRIMARY)
                .fontWeight(FontWeight.Medium)
                .onClick(() => this.toggleSelectAll())
            }
            .width('100%')
            .padding({
              left: AppSpacing.PAGE_HORIZONTAL,
              right: AppSpacing.PAGE_HORIZONTAL,
              top: AppSpacing.SM,
              bottom: AppSpacing.SM
            })
          }
          .width('100%')
          .linearGradient({
            angle: 180,
            colors: [[AppColors.SURFACE_BG, 0.0], [AppColors.PAGE_BG, 1.0]]
          })
        } else {
          // 正常模式顶栏 - 渐变背景
          Column() {
            Row() {
              // 标题带装饰
              Column({ space: 4 }) {
                Text('灵感合集')
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(AppColors.TEXT_PRIMARY)
                Text('收集美好瞬间')
                  .fontSize(AppFontSize.BODY)
                  .fontColor(AppColors.TEXT_TERTIARY)
              }
              .alignItems(HorizontalAlign.Start)
              
              Blank()
              
              // 操作按钮组
              Row({ space: AppSpacing.SM }) {
                // 排序按钮 - 优化样式
                Row({ space: 6 }) {
                  Text('⚙️')
                    .fontSize(14)
                  Text(this.currentSort === 'createTime' ? '时间' : '数量')
                    .fontSize(AppFontSize.CAPTION)
                    .fontColor(AppColors.TEXT_SECONDARY)
                    .fontWeight(FontWeight.Medium)
                }
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .backgroundColor(AppColors.SURFACE_BG)
                .borderRadius(16)
                .shadow({ radius: 4, color: '#15000000', offsetY: 1 })
                .onClick(() => {
                  this.showSortMenu = !this.showSortMenu
                })
                
                // 多选按钮 - 优化样式
                Row({ space: 4 }) {
                  Text('☑️')
                    .fontSize(14)
                  Text('选择')
                    .fontSize(AppFontSize.CAPTION)
                    .fontColor(AppColors.TEXT_SECONDARY)
                    .fontWeight(FontWeight.Medium)
                }
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .backgroundColor(AppColors.SURFACE_BG)
                .borderRadius(16)
                .shadow({ radius: 4, color: '#15000000', offsetY: 1 })
                .onClick(() => this.enterMultiSelectMode())
                
                // 新建按钮 - 渐变效果
                Row({ space: 4 }) {
                  Text('✨')
                    .fontSize(14)
                  Text('新建')
                    .fontSize(AppFontSize.CAPTION)
                    .fontColor(Color.White)
                    .fontWeight(FontWeight.Medium)
                }
                .padding({ left: 14, right: 14, top: 6, bottom: 6 })
                .linearGradient({
                  angle: 90,
                  colors: [['#667eea', 0.0], ['#764ba2', 1.0]]
                })
                .borderRadius(16)
                .shadow({ radius: 6, color: '#30764ba2', offsetY: 2 })
                .onClick(() => {
                  this.showCreateDialog = true
                })
              }
            }
            .width('100%')
            .padding({
              left: AppSpacing.PAGE_HORIZONTAL,
              right: AppSpacing.PAGE_HORIZONTAL,
              top: AppSpacing.MD,
              bottom: AppSpacing.MD
            })
          }
          .width('100%')
          .linearGradient({
            angle: 180,
            colors: [[AppColors.SURFACE_BG, 0.0], [AppColors.PAGE_BG, 1.0]]
          })
        }

        // 排序菜单 - 浮动卡片样式
        if (this.showSortMenu) {
          Column({ space: AppSpacing.SM }) {
            Text('排序方式')
              .fontSize(AppFontSize.CAPTION)
              .fontColor(AppColors.TEXT_TERTIARY)
              .fontWeight(FontWeight.Medium)
            
            Row({ space: AppSpacing.MD }) {
              // 按时间排序
              Column() {
                Text('🕐')
                  .fontSize(20)
                Text('创建时间')
                  .fontSize(AppFontSize.CAPTION)
                  .fontColor(this.currentSort === 'createTime' ? AppColors.ACCENT_PRIMARY : AppColors.TEXT_SECONDARY)
                  .fontWeight(this.currentSort === 'createTime' ? FontWeight.Bold : FontWeight.Normal)
                  .margin({ top: 4 })
              }
              .padding(12)
              .backgroundColor(this.currentSort === 'createTime' ? '#1A667eea' : Color.Transparent)
              .borderRadius(12)
              .border({
                width: 1,
                color: this.currentSort === 'createTime' ? AppColors.ACCENT_PRIMARY : '#20000000'
              })
              .onClick(() => this.toggleSort('createTime'))
              
              // 按数量排序
              Column() {
                Text('📊')
                  .fontSize(20)
                Text('素材数量')
                  .fontSize(AppFontSize.CAPTION)
                  .fontColor(this.currentSort === 'frameCount' ? AppColors.ACCENT_PRIMARY : AppColors.TEXT_SECONDARY)
                  .fontWeight(this.currentSort === 'frameCount' ? FontWeight.Bold : FontWeight.Normal)
                  .margin({ top: 4 })
              }
              .padding(12)
              .backgroundColor(this.currentSort === 'frameCount' ? '#1A667eea' : Color.Transparent)
              .borderRadius(12)
              .border({
                width: 1,
                color: this.currentSort === 'frameCount' ? AppColors.ACCENT_PRIMARY : '#20000000'
              })
              .onClick(() => this.toggleSort('frameCount'))
            }
          }
          .width('92%')
          .margin({ left: '4%', right: '4%', top: AppSpacing.XS })
          .padding({ left: AppSpacing.MD, right: AppSpacing.MD, top: AppSpacing.SM, bottom: AppSpacing.SM })
          .backgroundColor(AppColors.SURFACE_BG)
          .borderRadius(16)
          .shadow({ radius: 8, color: '#1A000000', offsetY: 2 })
        }

        // 分类筛选标签 - 横向滚动，参照收藏页风格
        Scroll() {
          Row({ space: AppSpacing.SM }) {
            Text('全部')
              .fontSize(AppFontSize.CAPTION)
              .fontColor(this.selectedCategory === 'all' ? AppColors.PAGE_BG : AppColors.TEXT_SECONDARY)
              .backgroundColor(this.selectedCategory === 'all' ? AppColors.ACCENT_PRIMARY : AppColors.SURFACE_BG)
              .padding({ left: 14, right: 14, top: 6, bottom: 6 })
              .borderRadius(18)
              .onClick(() => this.toggleCategory('all'))
            
            Text('图文')
              .fontSize(AppFontSize.CAPTION)
              .fontColor(this.selectedCategory === 'image_text' ? AppColors.PAGE_BG : AppColors.TEXT_SECONDARY)
              .backgroundColor(this.selectedCategory === 'image_text' ? AppColors.ACCENT_PRIMARY : AppColors.SURFACE_BG)
              .padding({ left: 14, right: 14, top: 6, bottom: 6 })
              .borderRadius(18)
              .onClick(() => this.toggleCategory('image_text'))
            
            Text('日常')
              .fontSize(AppFontSize.CAPTION)
              .fontColor(this.selectedCategory === 'daily' ? AppColors.PAGE_BG : AppColors.TEXT_SECONDARY)
              .backgroundColor(this.selectedCategory === 'daily' ? AppColors.ACCENT_PRIMARY : AppColors.SURFACE_BG)
              .padding({ left: 14, right: 14, top: 6, bottom: 6 })
              .borderRadius(18)
              .onClick(() => this.toggleCategory('daily'))
            
            Text('治愈')
              .fontSize(AppFontSize.CAPTION)
              .fontColor(this.selectedCategory === 'heal' ? AppColors.PAGE_BG : AppColors.TEXT_SECONDARY)
              .backgroundColor(this.selectedCategory === 'heal' ? AppColors.ACCENT_PRIMARY : AppColors.SURFACE_BG)
              .padding({ left: 14, right: 14, top: 6, bottom: 6 })
              .borderRadius(18)
              .onClick(() => this.toggleCategory('heal'))
            
            Text('燃向')
              .fontSize(AppFontSize.CAPTION)
              .fontColor(this.selectedCategory === 'burn' ? AppColors.PAGE_BG : AppColors.TEXT_SECONDARY)
              .backgroundColor(this.selectedCategory === 'burn' ? AppColors.ACCENT_PRIMARY : AppColors.SURFACE_BG)
              .padding({ left: 14, right: 14, top: 6, bottom: 6 })
              .borderRadius(18)
              .onClick(() => this.toggleCategory('burn'))
          }
          .padding({ left: AppSpacing.PAGE_HORIZONTAL, right: AppSpacing.PAGE_HORIZONTAL })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .height(36)
        .margin({ top: AppSpacing.XS, bottom: 0 })

        if (this.filteredAlbums.length === 0 && this.albums.length === 0) {
          // 空状态 - 精美的插画 + 引导文案 + 新建按钮
          Column({ space: AppSpacing.LG }) {
            // 精美插画 - 渐变背景卡片
            Column() {
              Stack() {
                // 背景装饰圆
                Column()
                  .width(140)
                  .height(140)
                  .borderRadius(70)
                  .linearGradient({
                    angle: 135,
                    colors: [['#E8F4FF', 0.0], ['#F3E8FF', 1.0]]
                  })
                  .opacity(0.6)
                
                // 主图标
                Column({ space: 6 }) {
                  Text('📚')
                    .fontSize(56)
                    .textShadow({ radius: 8, color: '#20000000', offsetX: 0, offsetY: 4 })
                  
                  // 装饰元素
                  Row({ space: 8 }) {
                    Text('✨')
                      .fontSize(18)
                      .opacity(0.8)
                    Text('💫')
                      .fontSize(16)
                      .opacity(0.6)
                    Text('🌟')
                      .fontSize(18)
                      .opacity(0.8)
                  }
                  .margin({ top: 6 })
                }
              }
              .width(160)
              .height(160)
            }
            .margin({ bottom: AppSpacing.XS })

            // 引导文案 - 分层设计
            Column({ space: 6 }) {
              Text('开始你的收藏之旅')
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor(AppColors.TEXT_PRIMARY)
                .textShadow({ radius: 1, color: '#10000000', offsetX: 0, offsetY: 1 })
              
              Column({ space: 3 }) {
                Text('创建灵感合集，整理美好瞬间')
                  .fontSize(AppFontSize.BODY)
                  .fontColor(AppColors.TEXT_SECONDARY)
                  .fontWeight(FontWeight.Medium)
                
                Text('将喜欢的情绪帧归类收藏，随时回顾')
                  .fontSize(AppFontSize.CAPTION)
                  .fontColor(AppColors.TEXT_TERTIARY)
              }
            }
            .padding({ left: AppSpacing.LG, right: AppSpacing.LG })

            // 新建合集按钮 - 渐变效果
            Column() {
              Row({ space: 6 }) {
                Text('✨')
                  .fontSize(16)
                Text('创建第一个合集')
                  .fontSize(AppFontSize.BODY)
                  .fontColor(Color.White)
                  .fontWeight(FontWeight.Bold)
              }
              .padding({ left: 24, right: 24, top: 12, bottom: 12 })
              .linearGradient({
                angle: 90,
                colors: [['#667eea', 0.0], ['#764ba2', 1.0]]
              })
              .borderRadius(24)
              .shadow({ radius: 12, color: '#35764ba2', offsetY: 4 })
            }
            .onClick(() => {
              this.showCreateDialog = true
            })
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .width('100%')
          .padding({ bottom: 60 }) // 为底部导航留空间
        } else if (this.filteredAlbums.length === 0) {
          // 筛选结果为空
          Column() {
            Column({ space: AppSpacing.LG }) {
              Text('🔍')
                .fontSize(48)
                .opacity(0.6)
              
              Column({ space: 6 }) {
                Text('暂无相关合集')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(AppColors.TEXT_PRIMARY)
                
                Text('试试其他分类或创建新合集')
                  .fontSize(AppFontSize.BODY)
                  .fontColor(AppColors.TEXT_SECONDARY)
              }
            }
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .width('100%')
        } else {
          // 2列网格卡片
          Scroll() {
            Grid() {
              ForEach(this.filteredAlbums, (album: Album) => {
                GridItem() {
                  this.albumCard(album)
                }
              }, (album: Album) => album.id)
            }
            .columnsTemplate('1fr 1fr')
            .rowsGap(AppSpacing.SM)
            .columnsGap(AppSpacing.SM)
            .padding({
              left: AppSpacing.PAGE_HORIZONTAL,
              right: AppSpacing.PAGE_HORIZONTAL,
              top: AppSpacing.MD,
              bottom: AppSpacing.LG
            })
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(AppColors.PAGE_BG)

      // 新建合集对话框
      if (this.showCreateDialog) {
        this.createAlbumDialog()
      }

      // 多选模式底部操作栏 - 优化设计
      if (this.isMultiSelectMode) {
        Column() {
          // 分隔线
          Column()
            .width(40)
            .height(4)
            .backgroundColor('#20000000')
            .borderRadius(2)
            .margin({ bottom: AppSpacing.MD })
          
          Row({ space: AppSpacing.MD }) {
            // 导出按钮 - 优化样式
            Column() {
              Row({ space: 6 }) {
                Text('📤')
                  .fontSize(16)
                Text('导出')
                  .fontSize(AppFontSize.BODY)
                  .fontColor(this.selectedAlbumIds.size > 0 ? AppColors.ACCENT_PRIMARY : AppColors.TEXT_TERTIARY)
                  .fontWeight(FontWeight.Medium)
              }
            }
            .layoutWeight(1)
            .height(48)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(this.selectedAlbumIds.size > 0 ? '#F0F4FF' : AppColors.SURFACE_BG)
            .borderRadius(16)
            .border({
              width: 1,
              color: this.selectedAlbumIds.size > 0 ? AppColors.ACCENT_PRIMARY : '#10000000'
            })
            .opacity(this.selectedAlbumIds.size > 0 ? 1.0 : 0.5)
            .onClick(() => this.batchExport())
            
            // 删除按钮 - 优化样式
            Column() {
              Row({ space: 6 }) {
                Text('🗑️')
                  .fontSize(16)
                Text('删除')
                  .fontSize(AppFontSize.BODY)
                  .fontColor(this.selectedAlbumIds.size > 0 ? '#FF4444' : AppColors.TEXT_TERTIARY)
                  .fontWeight(FontWeight.Medium)
              }
            }
            .layoutWeight(1)
            .height(48)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(this.selectedAlbumIds.size > 0 ? '#FFF0F0' : AppColors.SURFACE_BG)
            .borderRadius(16)
            .border({
              width: 1,
              color: this.selectedAlbumIds.size > 0 ? '#FF4444' : '#10000000'
            })
            .opacity(this.selectedAlbumIds.size > 0 ? 1.0 : 0.5)
            .onClick(() => this.batchDelete())
          }
          .width('100%')
          .padding({ left: AppSpacing.PAGE_HORIZONTAL, right: AppSpacing.PAGE_HORIZONTAL })
        }
        .width('100%')
        .backgroundColor(AppColors.SURFACE_BG)
        .borderRadius({ topLeft: 24, topRight: 24 })
        .shadow({ radius: 16, color: '#1A000000', offsetY: -4 })
        .padding({ top: AppSpacing.MD, bottom: AppSpacing.XL + 8 })
      }
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Bottom)
  }

  /** 合集卡片 */
  @Builder
  albumCard(album: Album) {
    Stack({ alignContent: Alignment.TopStart }) {
      // 卡片主体 - 支持点击态
      Column() {
        Stack({ alignContent: Alignment.TopEnd }) {
          // 封面层
          Column() {
            if (this.getAlbumCover(album).length > 0) {
              this.renderImage(this.getAlbumCover(album), '100%', 140, 12)
            } else {
              // 无封面时显示渐变色背景
              Column() {
                Column({ space: 8 }) {
                  Text('📷')
                    .fontSize(32)
                  Text('暂无素材')
                    .fontSize(AppFontSize.CAPTION)
                    .fontColor(AppColors.TEXT_TERTIARY)
                }
              }
              .width('100%')
              .height(140)
              .justifyContent(FlexAlign.Center)
              .linearGradient({
                angle: 135,
                colors: [['#1A1A2E', 0.0], ['#16213E', 0.5], ['#0F3460', 1.0]]
              })
              .borderRadius(12)
            }
          }
          .width('100%')
          .borderRadius(12)
          .clip(true)

          // 底部渐变蒙层（从下往上的渐变黑色）- 优化渐变效果
          Column() {
            Blank()
            // 文字信息层 - 增强可读性
            Column({ space: 4 }) {
              Text(album.name)
                .fontSize(16) // 标题稍大
                .fontColor('#FFFFFF')
                .fontWeight(FontWeight.Bold)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .textShadow({ radius: 2, color: '#40000000', offsetX: 0, offsetY: 1 })
              
              Row({ space: 6 }) {
                Text('🎞️')
                  .fontSize(12)
                Text(`${album.frameIds.length} 条素材`)
                  .fontSize(12)
                  .fontColor('#E0E0E0')
                  .fontWeight(FontWeight.Medium)
              }
            }
            .width('100%')
            .padding({ left: AppSpacing.MD, right: AppSpacing.MD, bottom: AppSpacing.MD })
          }
          .width('100%')
          .height('100%')
          .linearGradient({
            angle: 180,
            colors: [['#00000000', 0.0], ['#00000000', 0.3], ['#60000000', 0.6], ['#CC000000', 1.0]]
          })
          .borderRadius(16)

          // 右上角类型标签 Badge - 优化样式
          Row({ space: 4 }) {
            Text(this.getTypeIcon(album.type))
              .fontSize(10)
            Text(this.getTypeLabel(album.type))
              .fontSize(10)
              .fontColor('#FFFFFF')
              .fontWeight(FontWeight.Medium)
          }
          .backgroundColor(this.getTypeColor(album.type))
          .borderRadius(12)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .margin({ top: 10, right: 10 })
          .shadow({ radius: 4, color: '#30000000', offsetY: 1 })
        }
        .width('100%')
        .height(160) // 增加高度
      }
      .width('100%')
      .height(160)
      .borderRadius(16) // 更大的圆角
      .clip(true)
      // 优化点击态效果 - 更流畅的动画
      .opacity(this.pressedAlbumId === album.id ? 0.85 : 1.0)
      .scale({ x: this.pressedAlbumId === album.id ? 0.96 : 1.0, y: this.pressedAlbumId === album.id ? 0.96 : 1.0 })
      .animation({ duration: 200, curve: Curve.FastOutSlowIn })
      .onTouch((event: TouchEvent) => {
        if (event.type === TouchType.Down) {
          this.pressedAlbumId = album.id
        } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
          this.pressedAlbumId = ''
        }
      })
      .onClick(() => {
        if (this.isMultiSelectMode) {
          // 多选模式：切换选中状态
          this.toggleSelection(album.id)
        } else {
          // 正常模式：进入编辑页
          router.pushUrl({
            url: RoutePath.ALBUM_EDIT,
            params: { albumId: album.id }
          })
        }
      })

      // 多选模式：左上角勾选框
      if (this.isMultiSelectMode) {
        Row() {
          Checkbox()
            .select(this.selectedAlbumIds.has(album.id))
            .selectedColor(AppColors.ACCENT_PRIMARY)
            .shape(CheckBoxShape.CIRCLE)
            .width(20)
            .height(20)
            .onChange((isChecked: boolean) => {
              this.toggleSelection(album.id)
            })
        }
        .width(28)
        .height(28)
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .backgroundColor(Color.White)
        .borderRadius(14)
        .shadow({ radius: 4, color: '#33000000' })
        .margin({ top: 8, left: 8 })
      }
    }
    .width('100%')
    .height(140)
  }

  /** 新建合集对话框 - 优化设计 */
  @Builder
  createAlbumDialog() {
    Column() {
      Column({ space: AppSpacing.LG }) {
        // 标题区域 - 添加装饰
        Column({ space: 8 }) {
          Row({ space: 8 }) {
            Text('✨')
              .fontSize(24)
            Text('新建合集')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(AppColors.TEXT_PRIMARY)
          }
          
          Text('创建一个专属的灵感收藏空间')
            .fontSize(AppFontSize.CAPTION)
            .fontColor(AppColors.TEXT_TERTIARY)
        }
        .padding({ top: AppSpacing.MD })

        // 输入区域 - 优化样式
        Column({ space: AppSpacing.MD }) {
          Column({ space: 8 }) {
            Row({ space: 6 }) {
              Text('📝')
                .fontSize(14)
              Text('合集名称')
                .fontSize(AppFontSize.CAPTION)
                .fontColor(AppColors.TEXT_SECONDARY)
                .fontWeight(FontWeight.Medium)
            }
            .width('100%')
            
            TextInput({ placeholder: '给合集起个名字吧', text: this.newAlbumName })
              .height(48)
              .backgroundColor('#1E1E22')
              .borderRadius(12)
              .border({ width: 1.5, color: '#2A2A2E' })
              .padding({ left: 16, right: 16 })
              .fontSize(AppFontSize.BODY)
              .fontColor(AppColors.TEXT_PRIMARY)
              .placeholderColor(AppColors.TEXT_TERTIARY)
              .onChange((value: string) => {
                this.newAlbumName = value
              })
          }
          .width('100%')

          Column({ space: 8 }) {
            Row({ space: 6 }) {
              Text('💭')
                .fontSize(14)
              Text('合集描述')
                .fontSize(AppFontSize.CAPTION)
                .fontColor(AppColors.TEXT_SECONDARY)
                .fontWeight(FontWeight.Medium)
            }
            .width('100%')
            
            TextArea({ placeholder: '添加一些描述（可选）', text: this.newAlbumDesc })
              .height(80)
              .backgroundColor('#1E1E22')
              .borderRadius(12)
              .border({ width: 1.5, color: '#2A2A2E' })
              .padding(16)
              .fontSize(AppFontSize.BODY)
              .fontColor(AppColors.TEXT_PRIMARY)
              .placeholderColor(AppColors.TEXT_TERTIARY)
              .onChange((value: string) => {
                this.newAlbumDesc = value
              })
          }
          .width('100%')

          // 封面选择区域
          Column({ space: 8 }) {
            Row({ space: 6 }) {
              Text('🖼️')
                .fontSize(14)
              Text('封面照片')
                .fontSize(AppFontSize.CAPTION)
                .fontColor(AppColors.TEXT_SECONDARY)
                .fontWeight(FontWeight.Medium)
            }
            .width('100%')
            
            // 封面预览和选择按钮
            if (this.newAlbumCoverUri.length > 0) {
              // 已选择封面 - 显示预览
              Stack({ alignContent: Alignment.TopEnd }) {
                Image(this.newAlbumCoverUri)
                  .width('100%')
                  .height(120)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(12)
                
                // 删除按钮
                Button({ type: ButtonType.Circle }) {
                  Text('×')
                    .fontSize(18)
                    .fontColor(Color.White)
                }
                .width(28)
                .height(28)
                .backgroundColor('#80000000')
                .margin({ top: 8, right: 8 })
                .onClick(() => {
                  this.newAlbumCoverUri = ''
                })
              }
              .width('100%')
            } else {
              // 未选择封面 - 显示选择按钮
              Column() {
                Row({ space: 8 }) {
                  Text('📷')
                    .fontSize(20)
                  Text('点击选择封面照片')
                    .fontSize(AppFontSize.BODY)
                    .fontColor(AppColors.TEXT_TERTIARY)
                }
              }
              .width('100%')
              .height(120)
              .justifyContent(FlexAlign.Center)
              .backgroundColor('#1E1E22')
              .borderRadius(12)
              .border({ width: 1.5, color: '#2A2A2E', style: BorderStyle.Dashed })
              .onClick(async () => {
                await this.pickCoverPhoto()
              })
            }
            
            Text('建议选择16:9比例的图片作为封面')
              .fontSize(AppFontSize.CAPTION)
              .fontColor(AppColors.TEXT_TERTIARY)
              .margin({ top: 4 })
          }
          .width('100%')
        }
        .width('100%')

        // 按钮区域 - 优化样式
        Row({ space: AppSpacing.MD }) {
          // 取消按钮
          Column() {
            Text('取消')
              .fontSize(AppFontSize.BODY)
              .fontColor(AppColors.TEXT_SECONDARY)
              .fontWeight(FontWeight.Medium)
          }
          .layoutWeight(1)
          .height(48)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(AppColors.SURFACE_BG)
          .borderRadius(16)
          .onClick(() => {
            this.showCreateDialog = false
            this.newAlbumName = ''
            this.newAlbumDesc = ''
          })

          // 创建按钮 - 渐变效果
          Column() {
            Row({ space: 6 }) {
              Text('✨')
                .fontSize(16)
              Text('创建')
                .fontSize(AppFontSize.BODY)
                .fontColor(Color.White)
                .fontWeight(FontWeight.Bold)
            }
          }
          .layoutWeight(1)
          .height(48)
          .justifyContent(FlexAlign.Center)
          .linearGradient({
            angle: 90,
            colors: [['#667eea', 0.0], ['#764ba2', 1.0]]
          })
          .borderRadius(16)
          .shadow({ radius: 8, color: '#30764ba2', offsetY: 2 })
          .onClick(() => {
            this.createAlbum()
          })
        }
        .width('100%')
      }
      .width('88%')
      .padding(AppSpacing.XL)
      .backgroundColor(AppColors.SURFACE_BG)
      .borderRadius(24)
      .shadow({ radius: 24, color: '#26000000', offsetY: 8 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#80000000')
    .onClick(() => {
      // 点击背景关闭对话框
      this.showCreateDialog = false
      this.newAlbumName = ''
      this.newAlbumDesc = ''
    })
  }

  /** 获取类型图标 */
  private getTypeIcon(type: AlbumType | undefined): string {
    if (!type) {
      return '📁'
    }
    switch (type) {
      case AlbumType.IMAGE_TEXT:
        return '🖼️'
      case AlbumType.VIDEO_MIX:
        return '🎬'
      case AlbumType.MIXED:
        return '🎨'
      default:
        return '📁'
    }
  }
}
