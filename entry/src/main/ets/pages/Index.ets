/**
 * FrameKeep（帧藏）- 主入口页
 * 底部 Tabs + TabContent 五标签导航：收藏 / 创作 / 发现 / 合集 / 我的
 */
import { router } from '@kit.ArkUI';
import { CollectIndex } from './collect/CollectIndex';
import { CreateHub } from './create/CreateHub';
import { DiscoverIndex } from './discover/DiscoverIndex';
import { AlbumIndex } from './album/AlbumIndex';
import { ProfileIndex } from './profile/ProfileIndex';
import { AppColors, TAB_BAR_HEIGHT } from '../common/Styles';
import { userStore } from '../common/store/UserStore';
import { RoutePath } from '../common/Constants';

@Entry
@Component
struct Index {
  /** 当前选中的 Tab 索引，0=收藏（收藏优先） */
  @State currentIndex: number = 0

  /** Tab 标题资源 */
  private tabTitles: Resource[] = [
    $r('app.string.tab_collect'),
    $r('app.string.tab_create'),
    $r('app.string.tab_discover'),
    $r('app.string.tab_album'),
    $r('app.string.tab_profile')
  ]

  /** Tab 系统符号图标 */
  private tabIcons: Resource[] = [
    $r('sys.symbol.bookmark'),
    $r('sys.symbol.plus_circle'),
    $r('sys.symbol.compass'),
    $r('sys.symbol.rectangle_stack'),
    $r('sys.symbol.person')
  ]

  /**
   * 组件即将显示时检查登录状态
   */
  aboutToAppear(): void {
    // 检查用户是否已登录
    if (!userStore.isLoggedIn) {
      // 未登录，跳转到登录页面
      router.replaceUrl({ url: RoutePath.LOGIN })
    }
  }

  build() {
    Tabs({ barPosition: BarPosition.End, index: this.currentIndex }) {
      TabContent() {
        CollectIndex()
      }
      .tabBar(this.tabBarBuilder(0))

      TabContent() {
        CreateHub()
      }
      .tabBar(this.tabBarBuilder(1))

      TabContent() {
        DiscoverIndex()
      }
      .tabBar(this.tabBarBuilder(2))

      TabContent() {
        AlbumIndex()
      }
      .tabBar(this.tabBarBuilder(3))

      TabContent() {
        ProfileIndex()
      }
      .tabBar(this.tabBarBuilder(4))
    }
    .width('100%')
    .height('100%')
    .barMode(BarMode.Fixed)
    .scrollable(false)
    .barHeight(TAB_BAR_HEIGHT)
    .animationDuration(200)
    .backgroundColor(AppColors.PAGE_BG)
    .barBackgroundColor(AppColors.TAB_BAR_BG)
    .onChange((index: number) => {
      this.currentIndex = index
    })
  }

  /**
   * 自定义 TabBar：图标 + 文字，选中态使用影院金强调色
   */
  @Builder
  tabBarBuilder(index: number) {
    Column({ space: 4 }) {
      SymbolGlyph(this.tabIcons[index])
        .fontSize(22)
        .fontColor([this.currentIndex === index ? AppColors.ACCENT_PRIMARY : AppColors.TEXT_TERTIARY])
      Text(this.tabTitles[index])
        .fontSize(10)
        .fontColor(this.currentIndex === index ? AppColors.ACCENT_PRIMARY : AppColors.TEXT_TERTIARY)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
