# StudyGarden 技术架构文档

## 🏗️ 整体架构

```
┌─────────────────────────────────────────────────────────────┐
│                        iOS 客户端 (SwiftUI)                    │
├─────────────────────────────────────────────────────────────┤
│  Presentation Layer (Views)                                │
│  ├── StudyTimerView    ├── WalletView    ├── GardenView    │
│  └── ContentView (Tab Navigation)                          │
├─────────────────────────────────────────────────────────────┤
│  Business Logic Layer (Managers)                           │
│  ├── WalletManager     ├── GardenManager  ├── GachaManager │
│  └── TimerManager                                            │
├─────────────────────────────────────────────────────────────┤
│  Data Layer (Models)                                       │
│  ├── Wallet           ├── StudyRecord    ├── Plant         │
│  └── StreakRecord     ├── GachaDraw      └── User          │
├─────────────────────────────────────────────────────────────┤
│  Service Layer (Firebase)                                  │
│  ├── Authentication   ├── Firestore      ├── Functions     │
│  └── Storage                                                │
└─────────────────────────────────────────────────────────────┘
```

## 📱 iOS 客户端架构

### 1. 视图层 (Presentation Layer)
- **SwiftUI**: 声明式UI框架
- **Combine**: 响应式编程框架
- **状态管理**: @Published + ObservableObject

### 2. 业务逻辑层 (Business Logic Layer)
- **WalletManager**: 钱包业务逻辑
- **TimerManager**: 计时器管理
- **GardenManager**: 花园管理 (待开发)
- **GachaManager**: 抽卡管理 (待开发)

### 3. 数据层 (Data Layer)
- **本地存储**: UserDefaults + Core Data (可选)
- **云端同步**: Firebase Firestore
- **数据模型**: Swift Structs

## 🔥 Firebase 后端架构

### 1. 认证服务 (Authentication)
```swift
// 用户认证
FirebaseAuth.shared.signIn(withEmail: email, password: password)
FirebaseAuth.shared.createUser(withEmail: email, password: password)
```

### 2. 数据库服务 (Firestore)
```javascript
// 集合结构
wallets/
  {walletId}/
    - userId: String
    - balance: Number
    - totalEarned: Number
    - dailyEarned: Number
    - consecutiveDays: Number
    - lastStudyDate: Timestamp

studyRecords/
  {recordId}/
    - userId: String
    - startTime: Timestamp
    - endTime: Timestamp
    - duration: Number
    - coinsEarned: Number

plants/
  {plantId}/
    - userId: String
    - plantType: String
    - rarity: String
    - growthStage: Number
    - plantedAt: Timestamp
```

### 3. 云函数 (Cloud Functions)
```javascript
// 主要函数
exports.studyStart = functions.https.onCall(studyStartHandler);
exports.studyStop = functions.https.onCall(studyStopHandler);
exports.gardenPlant = functions.https.onCall(gardenPlantHandler);
exports.gachaDraw = functions.https.onCall(gachaDrawHandler);
```

## 🔄 数据流架构

### 1. 学习计时流程
```
用户点击开始学习
    ↓
TimerManager.startStudy()
    ↓
WalletManager.calculateCoins()
    ↓
Firestore.saveStudyRecord()
    ↓
UI更新 (@Published)
```

### 2. 金币计算流程
```
学习时长输入
    ↓
基础金币计算 (duration / 600)
    ↓
日上限检查 (80 - dailyEarned)
    ↓
连续打卡加成 (consecutiveDays >= 7)
    ↓
最终金币数量
    ↓
更新钱包余额
```

## 🎨 UI 架构模式

### 1. MVVM 模式
```swift
// View
struct StudyTimerView: View {
    @StateObject private var viewModel = StudyTimerViewModel()
    
    var body: some View {
        // UI 实现
    }
}

// ViewModel
class StudyTimerViewModel: ObservableObject {
    @Published var isStudying = false
    @Published var remainingTime = 0
    @Published var estimatedCoins = 0
    
    private let walletManager = WalletManager()
    
    func startStudy() {
        // 业务逻辑
    }
}
```

### 2. 状态管理
```swift
// 使用 @Published 实现响应式更新
class WalletManager: ObservableObject {
    @Published var wallet: Wallet?
    @Published var studyRecords: [StudyRecord] = []
    @Published var isLoading = false
    
    func updateWallet() {
        // 更新逻辑
        objectWillChange.send()
    }
}
```

## 🔧 依赖管理

### 1. CocoaPods
```ruby
# Podfile
platform :ios, '17.0'
use_frameworks!

target 'StudyGarden' do
  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
end
```

### 2. Swift Package Manager
```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "10.0.0")
]
```

## 🚀 性能优化策略

### 1. 数据加载优化
- 使用分页加载大量数据
- 实现数据缓存机制
- 优化Firestore查询索引

### 2. UI 性能优化
- 使用 LazyVStack 处理长列表
- 避免在 body 中进行复杂计算
- 合理使用 @State 和 @ObservedObject

### 3. 网络优化
- 实现离线数据同步
- 使用批量操作减少网络请求
- 添加网络状态检测

## 🔒 安全架构

### 1. 数据安全
- 使用Firebase安全规则
- 客户端数据验证
- 服务器端业务逻辑验证

### 2. 用户隐私
- 最小化数据收集
- 数据加密存储
- 用户数据删除机制

## 📊 监控和分析

### 1. 错误监控
- Firebase Crashlytics
- 自定义错误日志
- 性能监控

### 2. 用户行为分析
- Firebase Analytics
- 学习行为统计
- 功能使用率分析

## 🔄 版本控制策略

### 1. Git 工作流
- 主分支: main
- 功能分支: feature/功能名
- 发布分支: release/版本号
- 热修复分支: hotfix/问题描述

### 2. 代码审查
- 所有代码必须经过审查
- 使用 Pull Request 流程
- 自动化测试检查

## 📱 平台兼容性

### 1. iOS 版本支持
- 最低支持: iOS 17.0
- 目标支持: iOS 18.0+
- 向后兼容策略

### 2. 设备适配
- iPhone 全系列支持
- iPad 适配 (未来计划)
- 不同屏幕尺寸适配

## 🧪 测试策略

### 1. 单元测试
- 业务逻辑测试
- 数据模型测试
- 工具函数测试

### 2. 集成测试
- Firebase 集成测试
- UI 交互测试
- 端到端测试

### 3. 性能测试
- 内存使用测试
- 网络性能测试
- UI 响应性测试

---

*技术架构文档 v1.0*
*最后更新: 2024年12月*
