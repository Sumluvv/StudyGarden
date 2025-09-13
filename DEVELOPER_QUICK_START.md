# StudyGarden 开发者快速入门

## 🚀 项目简介

**StudyGarden** 是一个学习时间管理iOS应用，将学习时间转化为虚拟货币，用于在虚拟花园中种植植物。

## 📱 当前功能状态

### ✅ 已完成
- **学习计时器**: 25/45/60分钟预设时长，实时金币预估
- **钱包系统**: 10分钟1币，日上限80币，连续7天+10%加成
- **基础UI**: 绿色主题，响应式布局，Tab导航

### 🚧 开发中
- 虚拟花园系统
- 抽卡系统
- 社交功能
- 排行榜系统

## 🛠️ 技术栈

- **前端**: SwiftUI + Combine
- **后端**: Firebase (Auth, Firestore, Functions)
- **最低支持**: iOS 17.0+

## ⚡ 快速开始

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
# 在Xcode中选择iOS模拟器并运行
```

## 📁 项目结构

```
StudyGarden/
├── StudyGarden/
│   ├── Views/           # 界面组件
│   │   ├── StudyTimerView.swift    # 学习计时器
│   │   └── WalletView.swift        # 钱包界面
│   ├── Models/          # 数据模型
│   │   └── Wallet.swift            # 钱包相关模型
│   ├── Managers/        # 业务逻辑
│   │   └── WalletManager.swift     # 钱包管理器
│   └── ContentView.swift           # 主界面
├── Podfile              # 依赖配置
└── Package.swift        # SPM配置
```

## 💰 核心业务逻辑

### 金币计算
```swift
// 每10分钟 = 1金币
let baseCoins = Int(duration / 600)

// 日上限80金币
let actualCoins = min(baseCoins, 80 - dailyEarned)

// 连续7天+10%加成
if consecutiveDays >= 7 {
    finalCoins = actualCoins + Int(actualCoins * 0.1)
}
```

## 🎨 设计规范

- **主色调**: 低饱和度绿色
- **卡片**: 白色背景 + 绿色边框
- **按钮**: 圆角矩形 + 绿色填充
- **进度条**: 圆形进度条

## 🐛 已知问题

1. 需要配置真实的Firebase项目
2. 错误处理待完善
3. 离线数据同步待实现

## 📋 开发任务

### 高优先级
- [ ] 完善钱包系统的错误处理
- [ ] 实现虚拟花园基础界面
- [ ] 开发抽卡系统框架

### 中优先级
- [ ] 用户认证系统
- [ ] 好友功能
- [ ] 植物生长动画

### 低优先级
- [ ] 排行榜系统
- [ ] 数据分析
- [ ] 成就系统

## 🔧 开发环境

- macOS 13.0+
- Xcode 15.0+
- CocoaPods 1.12.0+

## 📞 联系方式

- **仓库**: https://github.com/Sumluvv/StudyGarden.git
- **问题**: GitHub Issues
- **讨论**: GitHub Discussions

---

*快速入门指南 v1.0*
