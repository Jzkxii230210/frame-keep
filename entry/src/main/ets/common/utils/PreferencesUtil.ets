/**
 * FrameKeep（帧藏）- 首选项持久化工具类
 * 用于存储应用数据，支持应用重启后数据恢复
 */
import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { BusinessError } from '@kit.BasicServicesKit'

const PREF_NAME = 'framekeep_data'

/**
 * 首选项工具类
 */
export class PreferencesUtil {
  private static instance: PreferencesUtil
  private preferences: preferences.Preferences | null = null
  private context: common.UIAbilityContext | null = null

  private constructor() {}

  /**
   * 获取单例实例
   */
  static getInstance(): PreferencesUtil {
    if (!PreferencesUtil.instance) {
      PreferencesUtil.instance = new PreferencesUtil()
    }
    return PreferencesUtil.instance
  }

  /**
   * 初始化首选项（在 EntryAbility.onCreate 中调用）
   */
  async init(context: common.UIAbilityContext): Promise<void> {
    this.context = context
    try {
      const options: preferences.Options = { name: PREF_NAME }
      this.preferences = await preferences.getPreferences(context, options)
      console.info('[PreferencesUtil] 初始化成功')
    } catch (err) {
      const error = err as BusinessError
      console.error(`[PreferencesUtil] 初始化失败: ${error.code}, ${error.message}`)
    }
  }

  /**
   * 保存数据
   */
  async put(key: string, value: preferences.ValueType): Promise<boolean> {
    if (!this.preferences) {
      console.error('[PreferencesUtil] 未初始化')
      return false
    }
    try {
      await this.preferences.put(key, value)
      await this.preferences.flush()
      return true
    } catch (err) {
      const error = err as BusinessError
      console.error(`[PreferencesUtil] 保存失败: ${error.code}, ${error.message}`)
      return false
    }
  }

  /**
   * 同步保存数据
   */
  putSync(key: string, value: preferences.ValueType): boolean {
    if (!this.preferences) {
      console.error('[PreferencesUtil] 未初始化')
      return false
    }
    try {
      this.preferences.putSync(key, value)
      this.preferences.flushSync()
      return true
    } catch (err) {
      const error = err as BusinessError
      console.error(`[PreferencesUtil] 同步保存失败: ${error.code}, ${error.message}`)
      return false
    }
  }

  /**
   * 获取数据
   */
  async get(key: string, defaultValue: preferences.ValueType): Promise<preferences.ValueType> {
    if (!this.preferences) {
      console.error('[PreferencesUtil] 未初始化')
      return defaultValue
    }
    try {
      return await this.preferences.get(key, defaultValue)
    } catch (err) {
      const error = err as BusinessError
      console.error(`[PreferencesUtil] 获取失败: ${error.code}, ${error.message}`)
      return defaultValue
    }
  }

  /**
   * 同步获取数据
   */
  getSync(key: string, defaultValue: preferences.ValueType): preferences.ValueType {
    if (!this.preferences) {
      console.error('[PreferencesUtil] 未初始化')
      return defaultValue
    }
    try {
      return this.preferences.getSync(key, defaultValue)
    } catch (err) {
      const error = err as BusinessError
      console.error(`[PreferencesUtil] 同步获取失败: ${error.code}, ${error.message}`)
      return defaultValue
    }
  }

  /**
   * 删除数据
   */
  async delete(key: string): Promise<boolean> {
    if (!this.preferences) {
      console.error('[PreferencesUtil] 未初始化')
      return false
    }
    try {
      await this.preferences.delete(key)
      await this.preferences.flush()
      return true
    } catch (err) {
      const error = err as BusinessError
      console.error(`[PreferencesUtil] 删除失败: ${error.code}, ${error.message}`)
      return false
    }
  }

  /**
   * 检查是否存在
   */
  async has(key: string): Promise<boolean> {
    if (!this.preferences) {
      console.error('[PreferencesUtil] 未初始化')
      return false
    }
    try {
      return await this.preferences.has(key)
    } catch (err) {
      const error = err as BusinessError
      console.error(`[PreferencesUtil] 检查失败: ${error.code}, ${error.message}`)
      return false
    }
  }

  /**
   * 获取所有数据
   */
  async getAll(): Promise<Record<string, preferences.ValueType>> {
    if (!this.preferences) {
      console.error('[PreferencesUtil] 未初始化')
      return {}
    }
    try {
      const all = await this.preferences.getAll()
      return all as Record<string, preferences.ValueType>
    } catch (err) {
      const error = err as BusinessError
      console.error(`[PreferencesUtil] 获取所有失败: ${error.code}, ${error.message}`)
      return {}
    }
  }

  /**
   * 清空所有数据
   */
  async clear(): Promise<boolean> {
    if (!this.preferences) {
      console.error('[PreferencesUtil] 未初始化')
      return false
    }
    try {
      await this.preferences.clear()
      await this.preferences.flush()
      return true
    } catch (err) {
      const error = err as BusinessError
      console.error(`[PreferencesUtil] 清空失败: ${error.code}, ${error.message}`)
      return false
    }
  }

  /**
   * 获取上下文
   */
  getContext(): common.UIAbilityContext | null {
    return this.context
  }
}

// 导出单例
export const prefUtil = PreferencesUtil.getInstance()
