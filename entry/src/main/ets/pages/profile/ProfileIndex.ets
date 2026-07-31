/**
 * FrameKeep（帧藏）- 个人中心 Tab 首页
 */
import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { RoutePath } from '../../common/Constants';
import { MockDataStore } from '../../common/MockData';
import { AppColors, AppFontSize, AppSpacing } from '../../common/Styles';
import { userStore } from '../../common/store/UserStore';

@Component
export struct ProfileIndex {
  build() {
    Column() {
      Column({ space: AppSpacing.SM }) {
        Text('我的')
          .fontSize(AppFontSize.HEADLINE)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.TEXT_PRIMARY)
        Text('FrameKeep · 帧藏')
          .fontSize(AppFontSize.BODY_SM)
          .fontColor(AppColors.TEXT_SECONDARY)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      .padding({
        left: AppSpacing.PAGE_HORIZONTAL,
        right: AppSpacing.PAGE_HORIZONTAL,
        top: AppSpacing.XL,
        bottom: AppSpacing.LG
      })

      Scroll() {
        Column({ space: AppSpacing.LG }) {
          // 用户信息卡片
          this.userInfoCard()

          // 数据统计
          this.menuRow('数据统计', () => router.pushUrl({ url: RoutePath.DATA_STATISTICS }))

          // 回收站
          this.menuRow('回收站', () => router.pushUrl({ url: RoutePath.RECYCLE_BIN }))

          // 我的模板
          this.menuRow('我的模板', () => router.pushUrl({ url: RoutePath.MY_TEMPLATE }))

          this.menuRow('偏好设置', () => router.pushUrl({ url: RoutePath.SETTING_PAGE }))
          this.menuRow('帮助与反馈', () => router.pushUrl({ url: RoutePath.HELP_FEEDBACK }))
        }
        .padding({ left: AppSpacing.PAGE_HORIZONTAL, right: AppSpacing.PAGE_HORIZONTAL, bottom: AppSpacing.XL })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppColors.PAGE_BG)
  }

  /**
   * 用户信息卡片
   */
  @Builder
  userInfoCard() {
    Column({ space: AppSpacing.MD }) {
      // 用户头像和基本信息
      Row({ space: AppSpacing.MD }) {
        // 头像
        Column() {
          Text(userStore.currentUser?.nickname?.charAt(0) ?? 'U')
            .fontSize(32)
            .fontColor(AppColors.PAGE_BG)
            .fontWeight(FontWeight.Bold)
        }
        .width(64)
        .height(64)
        .borderRadius(32)
        .backgroundColor(AppColors.ACCENT_PRIMARY)
        .justifyContent(FlexAlign.Center)

        // 用户名和昵称
        Column({ space: AppSpacing.XS }) {
          Text(userStore.currentUser?.nickname ?? '未登录')
            .fontSize(AppFontSize.BODY)
            .fontWeight(FontWeight.Medium)
            .fontColor(AppColors.TEXT_PRIMARY)

          Text(userStore.currentUser?.username ?? '')
            .fontSize(AppFontSize.CAPTION)
            .fontColor(AppColors.TEXT_SECONDARY)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')

      // 退出登录按钮
      Button('退出登录')
        .width('100%')
        .height(40)
        .backgroundColor(AppColors.SURFACE_BG)
        .fontColor(AppColors.ACCENT_PRIMARY)
        .fontSize(AppFontSize.BODY_SM)
        .borderRadius(8)
        .onClick(async () => {
          await userStore.logout()
          promptAction.showToast({ message: '已退出登录' })
          router.replaceUrl({ url: RoutePath.LOGIN })
        })
    }
    .width('100%')
    .padding(AppSpacing.LG)
    .backgroundColor(AppColors.SURFACE_BG)
    .borderRadius(12)
  }

  @Builder
  menuRow(title: string, onTap: () => void) {
    Row() {
      Text(title).fontColor(AppColors.TEXT_PRIMARY).layoutWeight(1)
      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontSize(16)
        .fontColor([AppColors.TEXT_TERTIARY])
    }
    .width('100%')
    .padding(AppSpacing.LG)
    .backgroundColor(AppColors.SURFACE_BG)
    .borderRadius(12)
    .onClick(onTap)
  }
}
