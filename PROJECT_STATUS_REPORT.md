# StudyGarden 项目进度报告

## 📋 项目概述

**StudyGarden** 是一个创新的学习时间管理iOS应用，将学习时间转化为虚拟货币，让用户在虚拟花园中种植植物。项目采用游戏化学习理念，通过奖励机制激励用户持续学习。

### 🎯 核心价值主张
- **学习即收益**: 将学习时间直接转化为可消费的虚拟货币
- **游戏化体验**: 通过种植、抽卡、社交等元素增加学习趣味性
- **社交激励**: 好友互动和排行榜系统促进学习动力
- **数据驱动**: 详细的学习统计和进度跟踪

---

## 🚀 当前开发状态

### ✅ 已完成功能

#### 1. 项目基础架构 (100%)
- [x] iOS项目结构搭建
- [x] SwiftUI + Combine 技术栈
- [x] Firebase 集成配置
- [x] CocoaPods + SPM 依赖管理
- [x] Xcode 项目配置和构建系统

#### 2. 学习计时器系统 (95%)
- [x] 预设时长选择 (25/45/60分钟)
- [x] 圆形进度条显示
- [x] 实时金币预估计算
- [x] 开始/暂停/继续/结束控制
- [x] 学习状态管理
- [x] 界面布局优化 (避免摄像头遮挡)

#### 3. 钱包系统 (90%)
- [x] 金币生成逻辑 (10分钟1币)
- [x] 日上限控制 (80币/天)
- [x] 连续打卡加成 (第7天起10%加成)
- [x] 断签清零机制
- [x] 钱包余额管理
- [x] 学习记录存储
- [x] 统计信息显示

#### 4. 用户界面设计 (85%)
- [x] 统一的绿色主题设计
- [x] 低饱和度配色方案
- [x] 响应式布局适配
- [x] Tab导航结构
- [x] 卡片式信息展示
- [x] 进度条和状态指示器

### 🚧 开发中功能

#### 1. 虚拟花园系统 (0%)
- [ ] 花园场景设计
- [ ] 植物种植逻辑
- [ ] 植物生长动画
- [ ] 花园装饰系统
- [ ] 植物状态管理

#### 2. 抽卡系统 (0%)
- [ ] 种子包设计
- [ ] 稀有度系统 (N/R/SR/SSR)
- [ ] 抽卡动画效果
- [ ] 概率算法实现
- [ ] 抽卡历史记录

#### 3. 社交功能 (0%)
- [ ] 用户注册/登录
- [ ] 好友系统
- [ ] 房间码分享
- [ ] 花园访问功能
- [ ] 好友互动

#### 4. 排行榜系统 (0%)
- [ ] 植物稀有度评分
- [ ] 好友排行算法
- [ ] 排行榜界面
- [ ] 实时更新机制

---

## 🏗️ 技术架构

### 前端技术栈
- **UI框架**: SwiftUI + Combine
- **最低支持**: iOS 17.0+
- **架构模式**: MVVM
- **状态管理**: @Published + ObservableObject

### 后端技术栈
- **云服务**: Firebase
- **数据库**: Firestore
- **认证**: Firebase Auth
- **云函数**: Firebase Functions
- **存储**: Firebase Storage

### 开发工具
- **IDE**: Xcode 15.0+
- **依赖管理**: CocoaPods + Swift Package Manager
- **版本控制**: Git + GitHub
- **构建系统**: XcodeGen

---

## 📊 项目结构

```
StudyGarden/
├── StudyGarden/                    # 主应用代码
│   ├── StudyGardenApp.swift       # 应用入口
│   ├── ContentView.swift          # 主界面导航
│   ├── Views/                     # 视图组件
│   │   ├── StudyTimerView.swift   # 学习计时器
│   │   └── WalletView.swift       # 钱包界面
│   ├── Models/                    # 数据模型
│   │   └── Wallet.swift           # 钱包相关模型
│   ├── Managers/                  # 业务逻辑
│   │   └── WalletManager.swift    # 钱包管理器
│   └── Assets.xcassets/           # 应用资源
├── Podfile                        # CocoaPods配置
├── Package.swift                  # SPM配置
└── README.md                      # 项目说明
```

---

## 💰 核心业务逻辑

### 金币生成规则
```swift
// 基础产出: 每10分钟 = 1金币
let baseCoins = Int(duration / 600)

// 日上限: 80金币/天
let dailyLimit = 80
let remainingLimit = dailyLimit - wallet.dailyEarned
let actualCoins = min(baseCoins, remainingLimit)

// 连续打卡加成: 第7天起 +10%
if streak.currentStreak >= 7 {
    let bonusCoins = Int(Double(actualCoins) * 0.1)
    finalCoins = actualCoins + bonusCoins
}
```

### 数据模型
```swift
struct Wallet {
    let id: String
    let userId: String
    var balance: Int              // 当前余额
    var totalEarned: Int          // 总获得金币数
    var dailyEarned: Int          // 今日已获得金币数
    var lastStudyDate: Date       // 最后学习日期
    var consecutiveDays: Int      // 连续学习天数
}

struct StudyRecord {
    let id: String
    let userId: String
    let startTime: Date
    let endTime: Date
    let duration: TimeInterval    // 学习时长
    let coinsEarned: Int          // 本次获得金币数
}
```

---

## 🎨 设计规范

### 色彩方案
- **主色调**: 低饱和度绿色 (#4CAF50)
- **辅助色**: 深绿色 (#2E7D32)
- **背景色**: 浅绿色 (#E8F5E8)
- **强调色**: 白色 (#FFFFFF)

### UI组件规范
- **卡片设计**: 白色背景 + 绿色边框
- **按钮样式**: 圆角矩形 + 绿色填充
- **进度条**: 圆形进度条 + 绿色渐变
- **文字层级**: 标题/正文/说明三级文字

---

## 📈 开发里程碑

### Phase 1: 基础功能 (已完成)
- [x] 项目搭建和配置
- [x] 学习计时器实现
- [x] 钱包系统开发
- [x] 基础UI设计

### Phase 2: 核心功能 (进行中)
- [ ] 虚拟花园系统
- [ ] 抽卡系统
- [ ] 植物管理

### Phase 3: 社交功能 (计划中)
- [ ] 用户系统
- [ ] 好友功能
- [ ] 花园分享

### Phase 4: 高级功能 (计划中)
- [ ] 排行榜系统
- [ ] 数据分析
- [ ] 成就系统

---

## 🛠️ 开发环境配置

### 环境要求
- macOS 13.0+
- Xcode 15.0+
- iOS 17.0+ 模拟器
- CocoaPods 1.12.0+

### 快速开始
```bash
# 1. 克隆项目
git clone https://github.com/Sumluvv/StudyGarden.git
cd StudyGarden

# 2. 安装依赖
pod install

# 3. 打开项目
open StudyGarden.xcworkspace

# 4. 配置Firebase
# 下载 GoogleService-Info.plist 到 StudyGarden/ 目录

# 5. 运行项目
# 在Xcode中选择目标设备并运行
```

---

## 🐛 已知问题

### 技术债务
1. **Firebase配置**: 需要配置真实的Firebase项目
2. **错误处理**: 网络异常和错误状态处理待完善
3. **数据验证**: 客户端数据验证需要加强
4. **性能优化**: 大量数据时的性能优化

### 待解决问题
1. 离线学习数据同步
2. 学习记录数据清理
3. 金币计算精度问题
4. 界面适配不同屏幕尺寸

---

## 🎯 下一步计划

### 短期目标 (1-2周)
1. **完善钱包系统**
   - 添加金币消费功能
   - 实现学习记录查询
   - 优化数据同步机制

2. **开始花园系统**
   - 设计花园场景界面
   - 实现基础植物模型
   - 开发种植逻辑

### 中期目标 (1个月)
1. **抽卡系统开发**
   - 设计种子包系统
   - 实现抽卡动画
   - 开发概率算法

2. **用户系统集成**
   - Firebase Auth集成
   - 用户数据管理
   - 个人资料设置

### 长期目标 (2-3个月)
1. **社交功能实现**
   - 好友系统
   - 花园分享
   - 实时互动

2. **排行榜和成就**
   - 评分算法
   - 排行榜界面
   - 成就系统

---

## 👥 团队协作

### 开发角色建议
- **iOS开发**: SwiftUI界面开发，业务逻辑实现
- **后端开发**: Firebase Functions，数据库设计
- **UI/UX设计**: 界面设计，用户体验优化
- **游戏设计**: 抽卡系统，植物系统设计

### 代码规范
- 使用SwiftLint进行代码规范检查
- 遵循Swift API设计指南
- 编写详细的代码注释
- 使用有意义的变量和函数命名

### 版本控制
- 使用Git Flow工作流
- 每个功能使用独立分支开发
- 提交信息使用约定式提交格式
- 定期进行代码审查

---

## 📞 联系方式

- **项目仓库**: https://github.com/Sumluvv/StudyGarden.git
- **问题反馈**: 通过GitHub Issues提交
- **技术讨论**: 通过GitHub Discussions进行

---

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

---

*最后更新: 2024年12月*
*文档版本: v1.0*
