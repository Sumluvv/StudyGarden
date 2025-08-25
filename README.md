# StudyGarden

一个创新的学习时间管理iOS应用，将学习时间转化为虚拟货币，让用户在虚拟花园中种植植物。

## 功能特性

- 🕐 **沉浸式学习计时器** - 专注学习，记录时间
- 💰 **虚拟货币系统** - 学习时间自动转换为金币
- 🌱 **虚拟花园** - 购买种子包，种植各种植物
- 🎲 **抽卡系统** - 随机获得不同稀有度的种子
- 👥 **社交功能** - 通过房间码添加好友，访问花园
- 🏆 **排行榜系统** - 基于植物稀有度的好友排行

## 技术架构

- **前端**: SwiftUI + Combine
- **后端**: Firebase (Authentication, Firestore, Functions, Storage)
- **依赖管理**: CocoaPods + Swift Package Manager
- **最低支持**: iOS 17.0+

## 项目结构

```
StudyGarden/
├── StudyGarden/           # 主应用代码
│   ├── StudyGardenApp.swift
│   ├── ContentView.swift
│   ├── Views/             # 视图组件
│   ├── Models/            # 数据模型
│   ├── Managers/          # 业务逻辑管理器
│   └── Assets.xcassets/   # 应用资源
├── Podfile                # CocoaPods配置
├── Package.swift          # Swift Package Manager配置
└── README.md              # 项目说明
```

## 安装说明

1. 克隆项目
```bash
git clone https://github.com/yourusername/StudyGarden.git
cd StudyGarden
```

2. 安装依赖
```bash
pod install
```

3. 打开项目
```bash
open StudyGarden.xcworkspace
```

## 环境配置

1. 确保已安装Xcode 15.0+
2. 安装CocoaPods: `sudo gem install cocoapods`
3. 配置Firebase项目并下载`GoogleService-Info.plist`

## 开发状态

🚧 **开发中** - 基础架构已完成，核心功能正在开发

## 贡献指南

欢迎提交Issue和Pull Request！

## 许可证

MIT License

## 联系方式

如有问题，请通过GitHub Issues联系我们。
