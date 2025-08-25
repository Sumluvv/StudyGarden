import Foundation
import FirebaseFirestore

// MARK: - 钱包数据模型
struct Wallet: Codable, Identifiable {
    let id: String
    let userId: String
    var balance: Int // 当前余额
    var totalEarned: Int // 总获得金币数
    var lastStudyDate: Date // 最后学习日期
    var consecutiveDays: Int // 连续学习天数
    var dailyEarned: Int // 今日已获得金币数
    var lastResetDate: Date // 上次重置日期（用于重置每日计数）
    
    init(userId: String) {
        self.id = UUID().uuidString
        self.userId = userId
        self.balance = 0
        self.totalEarned = 0
        self.lastStudyDate = Date()
        self.consecutiveDays = 0
        self.dailyEarned = 0
        self.lastResetDate = Date()
    }
}

// MARK: - 学习记录模型
struct StudyRecord: Codable, Identifiable {
    let id: String
    let userId: String
    let startTime: Date
    let endTime: Date
    let duration: TimeInterval // 学习时长（秒）
    let coinsEarned: Int // 本次获得金币数
    let timestamp: Date
    
    init(userId: String, startTime: Date, endTime: Date) {
        self.id = UUID().uuidString
        self.userId = userId
        self.startTime = startTime
        self.endTime = endTime
        self.duration = endTime.timeIntervalSince(startTime)
        self.coinsEarned = Int(self.duration / 600) // 每10分钟1币
        self.timestamp = Date()
    }
}

// MARK: - 连续打卡记录
struct StreakRecord: Codable, Identifiable {
    let id: String
    let userId: String
    let currentStreak: Int // 当前连续天数
    let longestStreak: Int // 最长连续天数
    let lastStudyDate: Date // 最后学习日期
    let bonusMultiplier: Double // 加成倍数（连续7天起1.1倍）
    
    init(userId: String) {
        self.id = UUID().uuidString
        self.userId = userId
        self.currentStreak = 0
        self.longestStreak = 0
        self.lastStudyDate = Date()
        self.bonusMultiplier = 1.0
    }
}
