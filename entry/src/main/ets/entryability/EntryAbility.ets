/**
 * FrameKeep（帧藏）- 应用入口 Ability
 * Stage 模型 UIAbility，负责深色模式与沉浸式系统栏配置。
 */
import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { prefUtil } from '../common/utils/PreferencesUtil';
import { fileUtil } from '../common/utils/FileUtil';
import { MockDataStore } from '../common/MockData';
import { userStore } from '../common/store/UserStore';

const DOMAIN = 0x0000;
const TAG = 'FrameKeep';

export default class EntryAbility extends UIAbility {
  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    // 强制深色模式，与帧藏简约深色视觉一致
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    
    // 初始化工具类
    await prefUtil.init(this.context);
    fileUtil.init(this.context);
    
    // 初始化数据（从持久化加载或使用种子数据）
    await MockDataStore.init();
    
    // 初始化用户状态（从持久化加载登录状态）
    await userStore.init();
    
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, TAG, 'Failed to load content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, TAG, 'Succeeded in loading content.');

      // 设置沉浸式状态栏与导航栏，避免白边闪烁
      windowStage.getMainWindow().then((mainWindow: window.Window) => {
        mainWindow.setWindowSystemBarProperties({
          statusBarColor: '#0A0A0B',
          navigationBarColor: '#111113',
          statusBarContentColor: '#FFFFFF',
          navigationBarContentColor: '#FFFFFF'
        });
      }).catch((e: Error) => {
        hilog.error(DOMAIN, TAG, 'Failed to set system bar. Cause: %{public}s', JSON.stringify(e));
      });
    });
  }

  onWindowStageDestroy(): void {
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    hilog.info(DOMAIN, TAG, '%{public}s', 'Ability onBackground');
  }
}
