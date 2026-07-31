/**
 * FrameKeep（帧藏）- 用户状态管理
 * 管理用户登录状态、用户信息等，支持持久化存储
 */
import { prefUtil } from '../utils/PreferencesUtil'

/** 用户信息接口 */
export interface UserInfo {
  /** 用户ID */
  id: string
  /** 用户名 */
  username: string
  /** 昵称 */
  nickname: string
  /** 头像URL */
  avatar?: string
  /** 邮箱 */
  email?: string
  /** 手机号 */
  phone?: string
}

/** 用户注册数据（包含密码） */
interface UserRegisterData {
  id: string
  username: string
  password: string
  nickname: string
  email?: string
}

/** 用户状态管理类 */
export class UserStore {
  /** 单例实例 */
  private static instance: UserStore | null = null
  
  /** 当前用户信息 */
  private _currentUser: UserInfo | null = null
  
  /** 登录状态 */
  private _isLoggedIn: boolean = false
  
  /** 持久化存储的键名 */
  private readonly KEY_USERS = 'registered_users'  // 已注册用户列表
  private readonly KEY_CURRENT_USER = 'current_user'  // 当前登录用户
  private readonly KEY_LOGIN_STATE = 'login_state'  // 登录状态
  
  /** 私有构造函数（单例模式） */
  private constructor() {}
  
  /** 获取单例实例 */
  static getInstance(): UserStore {
    if (!UserStore.instance) {
      UserStore.instance = new UserStore()
    }
    return UserStore.instance
  }
  
  /** 获取当前用户 */
  get currentUser(): UserInfo | null {
    return this._currentUser
  }
  
  /** 获取登录状态 */
  get isLoggedIn(): boolean {
    return this._isLoggedIn
  }
  
  /**
   * 初始化用户状态（应用启动时调用）
   * 从持久化存储加载登录状态和用户信息
   */
  async init(): Promise<void> {
    try {
      // 加载登录状态
      const loginState = await prefUtil.get(this.KEY_LOGIN_STATE, false) as boolean
      
      if (loginState) {
        // 加载当前用户信息
        const userJson = await prefUtil.get(this.KEY_CURRENT_USER, '') as string
        if (userJson && userJson.length > 0) {
          this._currentUser = JSON.parse(userJson) as UserInfo
          this._isLoggedIn = true
          console.info('[UserStore] 恢复登录状态成功')
        }
      }
    } catch (error) {
      console.error('[UserStore] 初始化失败:', error)
    }
  }
  
  /**
   * 用户注册
   * @param username 用户名
   * @param password 密码
   * @param nickname 昵称
   * @returns 注册是否成功
   */
  async register(username: string, password: string, nickname: string): Promise<boolean> {
    try {
      // 检查用户名是否已存在
      const users = await this.getRegisteredUsers()
      const existingUser = users.find((u: UserRegisterData) => u.username === username)
      
      if (existingUser) {
        console.warn('[UserStore] 用户名已存在')
        return false
      }
      
      // 创建新用户
      const newUser: UserRegisterData = {
        id: `user_${Date.now()}`,
        username: username,
        password: password,
        nickname: nickname,
        email: `${username}@framekeep.com`
      }
      
      // 保存到已注册用户列表
      users.push(newUser)
      const success = await prefUtil.put(this.KEY_USERS, JSON.stringify(users))
      
      if (success) {
        console.info('[UserStore] 注册成功')
        return true
      }
      
      return false
    } catch (error) {
      console.error('[UserStore] 注册失败:', error)
      return false
    }
  }
  
  /**
   * 用户登录
   * @param username 用户名
   * @param password 密码
   * @returns 登录是否成功
   */
  async login(username: string, password: string): Promise<boolean> {
    try {
      // 获取已注册用户列表
      const users = await this.getRegisteredUsers()
      
      // 查找匹配的用户
      const user = users.find((u: UserRegisterData) => 
        u.username === username && u.password === password
      )
      
      if (user) {
        // 设置当前用户信息
        this._currentUser = {
          id: user.id,
          username: user.username,
          nickname: user.nickname,
          email: user.email
        }
        this._isLoggedIn = true
        
        // 持久化登录状态
        await prefUtil.put(this.KEY_LOGIN_STATE, true)
        await prefUtil.put(this.KEY_CURRENT_USER, JSON.stringify(this._currentUser))
        
        console.info('[UserStore] 登录成功')
        return true
      }
      
      console.warn('[UserStore] 用户名或密码错误')
      return false
    } catch (error) {
      console.error('[UserStore] 登录失败:', error)
      return false
    }
  }
  
  /**
   * 用户登出
   */
  async logout(): Promise<void> {
    this._currentUser = null
    this._isLoggedIn = false
    
    // 清除持久化登录状态
    await prefUtil.put(this.KEY_LOGIN_STATE, false)
    await prefUtil.delete(this.KEY_CURRENT_USER)
    
    console.info('[UserStore] 登出成功')
  }
  
  /**
   * 更新用户信息
   * @param userInfo 新的用户信息
   */
  updateUserInfo(userInfo: Partial<UserInfo>): void {
    if (this._currentUser) {
      // 手动更新每个字段（ArkTS不支持对象展开运算符）
      if (userInfo.id !== undefined) {
        this._currentUser.id = userInfo.id
      }
      if (userInfo.username !== undefined) {
        this._currentUser.username = userInfo.username
      }
      if (userInfo.nickname !== undefined) {
        this._currentUser.nickname = userInfo.nickname
      }
      if (userInfo.avatar !== undefined) {
        this._currentUser.avatar = userInfo.avatar
      }
      if (userInfo.email !== undefined) {
        this._currentUser.email = userInfo.email
      }
      if (userInfo.phone !== undefined) {
        this._currentUser.phone = userInfo.phone
      }
    }
  }
  
  /**
   * 获取已注册用户列表
   */
  private async getRegisteredUsers(): Promise<UserRegisterData[]> {
    try {
      const usersJson = await prefUtil.get(this.KEY_USERS, '[]') as string
      return JSON.parse(usersJson) as UserRegisterData[]
    } catch (error) {
      console.error('[UserStore] 获取用户列表失败:', error)
      return []
    }
  }
}

/** 导出单例实例，方便使用 */
export const userStore = UserStore.getInstance()
