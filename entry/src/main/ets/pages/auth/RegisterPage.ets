/**
 * FrameKeep（帧藏）- 注册页面
 */
import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { userStore } from '../../common/store/UserStore';
import { RoutePath } from '../../common/Constants';
import { AppColors, AppFontSize, AppSpacing, AppRadius } from '../../common/Styles';

@Entry
@Component
struct RegisterPage {
  @State username: string = ''
  @State password: string = ''
  @State confirmPassword: string = ''
  @State nickname: string = ''
  @State isLoading: boolean = false
  @State passwordVisible: boolean = false

  build() {
    Column() {
      // 顶部区域
      Column({ space: AppSpacing.LG }) {
        // 返回按钮
        Row() {
          Button('← 返回')
            .fontSize(AppFontSize.BODY)
            .backgroundColor(Color.Transparent)
            .fontColor(AppColors.TEXT_SECONDARY)
            .onClick(() => {
              router.back()
            })
        }
        .width('100%')
        .padding({ left: AppSpacing.PAGE_HORIZONTAL })

        // 标题
        Column({ space: AppSpacing.SM }) {
          Text('创建账号')
            .fontSize(AppFontSize.HEADLINE)
            .fontWeight(FontWeight.Bold)
            .fontColor(AppColors.TEXT_PRIMARY)

          Text('加入帧藏，开始收藏你的每一帧')
            .fontSize(AppFontSize.BODY_SM)
            .fontColor(AppColors.TEXT_SECONDARY)
        }
      }
      .width('100%')
      .margin({ top: 40, bottom: 40 })

      // 注册表单
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

        // 昵称输入框
        Column({ space: AppSpacing.XS }) {
          Text('昵称')
            .fontSize(AppFontSize.CAPTION)
            .fontColor(AppColors.TEXT_SECONDARY)
            .width('100%')
          
          TextInput({ placeholder: '请输入昵称', text: this.nickname })
            .height(48)
            .backgroundColor(AppColors.SURFACE_BG)
            .borderRadius(AppRadius.MD)
            .fontColor(AppColors.TEXT_PRIMARY)
            .placeholderColor(AppColors.TEXT_TERTIARY)
            .onChange((value: string) => {
              this.nickname = value
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
            TextInput({ placeholder: '请输入密码（至少6位）', text: this.password })
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

        // 确认密码输入框
        Column({ space: AppSpacing.XS }) {
          Text('确认密码')
            .fontSize(AppFontSize.CAPTION)
            .fontColor(AppColors.TEXT_SECONDARY)
            .width('100%')
          
          TextInput({ placeholder: '请再次输入密码', text: this.confirmPassword })
            .height(48)
            .backgroundColor(AppColors.SURFACE_BG)
            .borderRadius(AppRadius.MD)
            .fontColor(AppColors.TEXT_PRIMARY)
            .placeholderColor(AppColors.TEXT_TERTIARY)
            .type(InputType.Password)
            .onChange((value: string) => {
              this.confirmPassword = value
            })
        }
        .width('100%')

        // 注册按钮
        Button(this.isLoading ? '注册中...' : '注册')
          .width('100%')
          .height(48)
          .backgroundColor(this.isLoading ? AppColors.BADGE_BG : AppColors.ACCENT_PRIMARY)
          .fontColor(this.isLoading ? AppColors.TEXT_TERTIARY : AppColors.PAGE_BG)
          .fontSize(AppFontSize.BODY)
          .fontWeight(FontWeight.Medium)
          .borderRadius(AppRadius.MD)
          .enabled(!this.isLoading)
          .onClick(() => {
            this.handleRegister()
          })

        // 登录提示
        Row({ space: AppSpacing.XS }) {
          Text('已有账号？')
            .fontSize(AppFontSize.BODY_SM)
            .fontColor(AppColors.TEXT_SECONDARY)
          
          Text('立即登录')
            .fontSize(AppFontSize.BODY_SM)
            .fontColor(AppColors.ACCENT_PRIMARY)
            .onClick(() => {
              router.back()
            })
        }
        .margin({ top: AppSpacing.LG })
      }
      .width('100%')
      .padding({ left: AppSpacing.XXL, right: AppSpacing.XXL })

      Blank()

      // 底部提示
      Text('注册即表示同意《用户协议》和《隐私政策》')
        .fontSize(AppFontSize.CAPTION)
        .fontColor(AppColors.TEXT_TERTIARY)
        .margin({ bottom: 40 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppColors.PAGE_BG)
  }

  /**
   * 处理注册
   */
  private async handleRegister(): Promise<void> {
    // 验证输入
    if (this.username.length === 0) {
      promptAction.showToast({ message: '请输入用户名' })
      return
    }
    
    if (this.nickname.length === 0) {
      promptAction.showToast({ message: '请输入昵称' })
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
    
    if (this.confirmPassword !== this.password) {
      promptAction.showToast({ message: '两次密码输入不一致' })
      return
    }

    // 设置加载状态
    this.isLoading = true

    try {
      // 调用注册
      const success = await userStore.register(this.username, this.password, this.nickname)
      
      if (success) {
        promptAction.showToast({ message: '注册成功，请登录' })
        // 跳转到登录页
        router.replaceUrl({ url: RoutePath.LOGIN })
      } else {
        promptAction.showToast({ message: '注册失败，请重试' })
      }
    } catch (error) {
      promptAction.showToast({ message: '注册失败，请重试' })
    } finally {
      this.isLoading = false
    }
  }
}
