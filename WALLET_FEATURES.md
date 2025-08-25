# StudyGarden 钱包系统功能说明

## 🎯 核心功能

### 1. 币产出机制
- **基础产出**: 每10分钟学习时间产出1个金币
- **日上限**: 每日最多产出80个金币
- **连续打卡加成**: 连续学习第7天起，获得10%金币加成
- **断签清零**: 中断学习后，连续天数重置为0

### 2. 学习计时器
- **实时计时**: 显示学习时长，支持暂停/继续
- **金币预估**: 实时显示本次学习预计获得的金币数
- **进度显示**: 圆形进度条显示学习进度
- **状态管理**: 开始、暂停、继续、结束学习

### 3. 钱包管理
- **余额显示**: 实时显示当前金币余额
- **统计信息**: 总获得金币数、今日已获得、剩余可获得
- **连续打卡**: 显示当前连续学习天数
- **加成状态**: 显示是否激活连续打卡加成

## 🔧 技术实现

### 数据模型
```swift
struct Wallet {
    let id: String
    let userId: String
    var balance: Int              // 当前余额
    var totalEarned: Int         // 总获得金币数
    var lastStudyDate: Date      // 最后学习日期
    var consecutiveDays: Int     // 连续学习天数
    var dailyEarned: Int         // 今日已获得金币数
    var lastResetDate: Date      // 上次重置日期
}

struct StudyRecord {
    let id: String
    let userId: String
    let startTime: Date
    let endTime: Date
    let duration: TimeInterval   // 学习时长（秒）
    let coinsEarned: Int         // 本次获得金币数
    let timestamp: Date
}

struct StreakRecord {
    let id: String
    let userId: String
    let currentStreak: Int       // 当前连续天数
    let longestStreak: Int       // 最长连续天数
    let lastStudyDate: Date      // 最后学习日期
    let bonusMultiplier: Double  // 加成倍数
}
```

### 核心算法
```swift
// 金币计算
let baseCoins = Int(duration / 600) // 每10分钟1币
let remainingDailyLimit = dailyCoinLimit - wallet.dailyEarned
let actualCoins = min(baseCoins, remainingDailyLimit)

// 连续打卡加成
if streak.currentStreak >= 7 {
    let bonusCoins = Int(Double(actualCoins) * 0.1)
    finalCoins = actualCoins + bonusCoins
}
```

## 📱 用户界面

### 学习计时器 (StudyTimerView)
- **圆形计时器**: 大尺寸圆形进度条显示学习时长
- **金币预估**: 实时显示本次学习预计获得的金币
- **控制按钮**: 开始、暂停、继续、结束学习
- **学习状态**: 显示今日进度和连续打卡信息

### 钱包界面 (WalletView)
- **余额卡片**: 显示当前金币余额和总获得数
- **连续打卡**: 显示连续学习天数和加成状态
- **今日进度**: 进度条显示今日金币获得情况
- **学习记录**: 显示学习历史记录

## 🗄️ 数据存储

### Firestore 集合结构
```
wallets/
  {walletId}/
    - userId: String
    - balance: Int
    - totalEarned: Int
    - lastStudyDate: Timestamp
    - consecutiveDays: Int
    - dailyEarned: Int
    - lastResetDate: Timestamp

studyRecords/
  {recordId}/
    - userId: String
    - startTime: Timestamp
    - endTime: Timestamp
    - duration: Number
    - coinsEarned: Int
    - timestamp: Timestamp

streaks/
  {streakId}/
    - userId: String
    - currentStreak: Int
    - longestStreak: Int
    - lastStudyDate: Timestamp
    - bonusMultiplier: Number
```

## ⚡ 性能优化

### 实时更新
- 使用 `@Published` 属性包装器实现响应式UI
- 学习过程中实时更新计时器和金币预估
- 学习结束后立即更新钱包余额和统计信息

### 数据同步
- 学习记录实时保存到Firestore
- 钱包状态变化立即同步到云端
- 支持离线学习，网络恢复后自动同步

## 🚀 扩展功能

### 未来计划
- **学习目标**: 设置每日学习目标，达成后获得额外奖励
- **成就系统**: 连续学习里程碑，解锁特殊奖励
- **社交功能**: 好友间金币转账和赠送
- **消费记录**: 详细的金币消费历史
- **数据分析**: 学习时间统计和金币获得趋势

### 自定义配置
- 可调整金币产出比例
- 可设置不同的连续打卡加成规则
- 可自定义每日金币上限
- 可配置学习时间计算规则

## 📋 使用流程

1. **开始学习**: 点击"开始学习"按钮，计时器开始计时
2. **学习过程**: 可随时暂停/继续，金币预估实时更新
3. **结束学习**: 点击"结束学习"，系统计算金币并更新钱包
4. **查看状态**: 在钱包界面查看余额、连续打卡等信息
5. **连续加成**: 连续学习7天后自动激活10%金币加成

## 🔒 安全特性

- 用户数据隔离，只能访问自己的钱包信息
- 学习记录防篡改，时间戳和服务器验证
- 金币计算在服务器端进行，防止客户端作弊
- 支持学习行为异常检测和报告
