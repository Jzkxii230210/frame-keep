/**
 * FrameKeep（帧藏）- 登录页面
 */
import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { userStore } from '../../common/store/UserStore';
import { RoutePath } from '../../common/Constants';
import { AppColors, AppFontSize, AppSpacing, AppRadius } from '../../common/Styles';

@Entry
@Component
struct LoginPage {
  @State username: string = ''
  @State password: string = ''
  @State isLoading: boolean = false
  @State passwordVisible: boolean = false

  build() {
    Column() {
      // 顶部Logo区域
      Column({ space: AppSpacing.LG }) {
        // Logo图标
        Column() {
          Text('🎬')
            .fontSize(64)
        }
        .width(100)
        .height(100)
        .borderRadius(50)
        .backgroundColor(AppColors.SURFACE_BG)
        .justifyContent(FlexAlign.Center)

        // 应用名称
        Text('帧藏')
          .fontSize(AppFontSize.DISPLAY)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppColors.TEXT_PRIMARY)

        // Slogan
        Text('收藏触动你的每一帧')
          .fontSize(AppFontSize.BODY_SM)
          .fontColor(AppColors.TEXT_SECONDARY)
      }
      .margin({ top: 80, bottom: 60 })

      // 登录表单
      Column({ space: AppSpacing.LG }) {
        // 用户名输入框
        Column({ space: AppSpacing.XS }) {
          Text('用户名')
            .fontSize(AppFontSize.CAPTION)
            .fontColor(AppColors.TEXT_SECONDARY)
            .width('100%')
          
          TextInput({ placeholder: '请输入用户名', text: this.username })
            .height(48)
            .backgroundColor(AppColors.SURFACE_BG)
            .borderRadius(AppRadius.MD)
            .fontColor(AppColors.TEXT_PRIMARY)
            .placeholderColor(AppColors.TEXT_TERTIARY)
            .onChange((value: string) => {
              this.username = value
            })
        }
        .width('100%')

        // 密码输入框
        Column({ space: AppSpacing.XS }) {
          Text('密码')
            .fontSize(AppFontSize.CAPTION)
            .fontColor(AppColors.TEXT_SECONDARY)
            .width('100%')
          
          Row() {
            TextInput({ placeholder: '请输入密码', text: this.password })
              .height(48)
              .backgroundColor(AppColors.SURFACE_BG)
              .borderRadius(AppRadius.MD)
              .fontColor(AppColors.TEXT_PRIMARY)
              .placeholderColor(AppColors.TEXT_TERTIARY)
              .type(this.passwordVisible ? InputType.Normal : InputType.Password)
              .onChange((value: string) => {
                this.password = value
              })
              .layoutWeight(1)
            
            // 密码显示/隐藏按钮
            Button(this.passwordVisible ? '隐藏' : '显示')
              .fontSize(AppFontSize.CAPTION)
              .height(48)
              .backgroundColor(AppColors.SURFACE_BG)
              .fontColor(AppColors.TEXT_SECONDARY)
              .margin({ left: AppSpacing.SM })
              .onClick(() => {
                this.passwordVisible = !this.passwordVisible
              })
          }
          .width('100%')
        }
        .width('100%')

        // 登录按钮
        Button(this.isLoading ? '登录中...' : '登录')
          .width('100%')
          .height(48)
          .backgroundColor(this.isLoading ? AppColors.BADGE_BG : AppColors.ACCENT_PRIMARY)
          .fontColor(this.isLoading ? AppColors.TEXT_TERTIARY : AppColors.PAGE_BG)
          .fontSize(AppFontSize.BODY)
          .fontWeight(FontWeight.Medium)
          .borderRadius(AppRadius.MD)
          .enabled(!this.isLoading)
          .onClick(() => {
            this.handleLogin()
          })

        // 注册提示
        Row({ space: AppSpacing.XS }) {
          Text('还没有账号？')
            .fontSize(AppFontSize.BODY_SM)
            .fontColor(AppColors.TEXT_SECONDARY)
          
          Text('立即注册')
            .fontSize(AppFontSize.BODY_SM)
            .fontColor(AppColors.ACCENT_PRIMARY)
            .onClick(() => {
              router.pushUrl({ url: RoutePath.REGISTER })
            })
        }
        .margin({ top: AppSpacing.LG })
      }
      .width('100%')
      .padding({ left: AppSpacing.XXL, right: AppSpacing.XXL })

      Blank()

      // 底部提示
      Text('登录即表示同意《用户协议》和《隐私政策》')
        .fontSize(AppFontSize.CAPTION)
        .fontColor(AppColors.TEXT_TERTIARY)
        .margin({ bottom: 40 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppColors.PAGE_BG)
  }

  /**
   * 处理登录
   */
  private async handleLogin(): Promise<void> {
    // 验证输入
    if (this.username.length === 0) {
      promptAction.showToast({ message: '请输入用户名' })
      return
    }
    
    if (this.password.length === 0) {
      promptAction.showToast({ message: '请输入密码' })
      return
    }
    
    if (this.password.length < 6) {
      promptAction.showToast({ message: '密码长度至少6位' })
      return
    }

    // 设置加载状态
    this.isLoading = true

    try {
      // 调用登录
      const success = await userStore.login(this.username, this.password)
      
      if (success) {
        promptAction.showToast({ message: '登录成功' })
        // 跳转到主页
        router.replaceUrl({ url: RoutePath.INDEX })
      } else {
        promptAction.showToast({ message: '登录失败，请检查用户名和密码' })
      }
    } catch (error) {
      promptAction.showToast({ message: '登录失败，请重试' })
    } finally {
      this.isLoading = false
    }
  }
}
