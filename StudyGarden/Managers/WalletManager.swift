import Foundation
import Combine
import FirebaseFirestore

class WalletManager: ObservableObject {
    @Published var wallet: Wallet?
    @Published var streakRecord: StreakRecord?
    @Published var isProcessing = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - 币产出配置
    private let coinsPerMinute: Double = 1.0 / 10.0 // 每10分钟1币
    private let dailyCoinLimit = 80 // 日上限80币
    private let streakBonusThreshold = 7 // 连续7天起有加成
    private let streakBonusMultiplier: Double = 1.1 // 10%加成
    
    init() {
        // 初始化时检查并重置每日计数
        checkAndResetDailyCount()
    }
    
    // MARK: - 钱包初始化
    func initializeWallet(for userId: String) {
        isProcessing = true
        
        // 检查是否已存在钱包
        db.collection("wallets").whereField("userId", isEqualTo: userId).getDocuments { [weak self] snapshot, error in
            DispatchQueue.main.async {
                self?.isProcessing = false
                
                if let error = error {
                    self?.errorMessage = "初始化钱包失败: \(error.localizedDescription)"
                    return
                }
                
                if let document = snapshot?.documents.first {
                    // 已存在钱包，解码数据
                    do {
                        let wallet = try document.data(as: Wallet.self)
                        self?.wallet = wallet
                        self?.loadStreakRecord(for: userId)
                    } catch {
                        self?.errorMessage = "解析钱包数据失败: \(error.localizedDescription)"
                    }
                } else {
                    // 创建新钱包
                    self?.createNewWallet(for: userId)
                }
            }
        }
    }
    
    // MARK: - 创建新钱包
    private func createNewWallet(for userId: String) {
        let newWallet = Wallet(userId: userId)
        let newStreak = StreakRecord(userId: userId)
        
        do {
            try db.collection("wallets").document(newWallet.id).setData(from: newWallet)
            try db.collection("streaks").document(newStreak.id).setData(from: newStreak)
            
            self.wallet = newWallet
            self.streakRecord = newStreak
        } catch {
            self.errorMessage = "创建钱包失败: \(error.localizedDescription)"
        }
    }
    
    // MARK: - 加载连续打卡记录
    private func loadStreakRecord(for userId: String) {
        db.collection("streaks").whereField("userId", isEqualTo: userId).getDocuments { [weak self] snapshot, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "加载连续打卡记录失败: \(error.localizedDescription)"
                    return
                }
                
                if let document = snapshot?.documents.first {
                    do {
                        let streak = try document.data(as: StreakRecord.self)
                        self?.streakRecord = streak
                    } catch {
                        self?.errorMessage = "解析连续打卡数据失败: \(error.localizedDescription)"
                    }
                }
            }
        }
    }
    
    // MARK: - 处理学习时间并产出金币
    func processStudySession(startTime: Date, endTime: Date) {
        guard let wallet = wallet else {
            errorMessage = "钱包未初始化"
            return
        }
        
        isProcessing = true
        
        // 计算学习时长和基础金币
        let duration = endTime.timeIntervalSince(startTime)
        let baseCoins = Int(duration * coinsPerMinute)
        
        // 检查日上限
        let remainingDailyLimit = dailyCoinLimit - wallet.dailyEarned
        let actualCoins = min(baseCoins, remainingDailyLimit)
        
        guard actualCoins > 0 else {
            isProcessing = false
            errorMessage = "今日金币已达上限"
            return
        }
        
        // 应用连续打卡加成
        let finalCoins = applyStreakBonus(to: actualCoins)
        
        // 创建学习记录
        let studyRecord = StudyRecord(userId: wallet.userId, startTime: startTime, endTime: endTime)
        
        // 更新钱包
        updateWallet(with: finalCoins, studyDate: endTime)
        
        // 更新连续打卡记录
        updateStreakRecord(studyDate: endTime)
        
        // 保存学习记录
        saveStudyRecord(studyRecord)
        
        isProcessing = false
    }
    
    // MARK: - 应用连续打卡加成
    private func applyStreakBonus(to coins: Int) -> Int {
        guard let streak = streakRecord, streak.currentStreak >= streakBonusThreshold else {
            return coins
        }
        
        let bonusCoins = Int(Double(coins) * (streak.bonusMultiplier - 1.0))
        return coins + bonusCoins
    }
    
    // MARK: - 更新钱包
    private func updateWallet(with coins: Int, studyDate: Date) {
        guard var wallet = wallet else { return }
        
        wallet.balance += coins
        wallet.totalEarned += coins
        wallet.dailyEarned += coins
        wallet.lastStudyDate = studyDate
        
        // 保存到Firestore
        do {
            try db.collection("wallets").document(wallet.id).setData(from: wallet)
            self.wallet = wallet
        } catch {
            errorMessage = "更新钱包失败: \(error.localizedDescription)"
        }
    }
    
    // MARK: - 更新连续打卡记录
    private func updateStreakRecord(studyDate: Date) {
        guard var streak = streakRecord else { return }
        
        let calendar = Calendar.current
        let lastDate = streak.lastStudyDate
        
        // 检查是否是连续的一天
        if calendar.isDate(studyDate, inSameDayAs: lastDate) {
            // 同一天，不更新连续天数
            return
        }
        
        if calendar.isDate(studyDate, equalTo: calendar.date(byAdding: .day, value: 1, to: lastDate) ?? Date(), toGranularity: .day) {
            // 连续的一天
            streak.currentStreak += 1
        } else {
            // 断签，重置连续天数
            streak.currentStreak = 1
        }
        
        // 更新最长连续天数
        streak.longestStreak = max(streak.longestStreak, streak.currentStreak)
        streak.lastStudyDate = studyDate
        
        // 更新加成倍数
        streak.bonusMultiplier = streak.currentStreak >= streakBonusThreshold ? streakBonusMultiplier : 1.0
        
        // 保存到Firestore
        do {
            try db.collection("streaks").document(streak.id).setData(from: streak)
            self.streakRecord = streak
        } catch {
            errorMessage = "更新连续打卡记录失败: \(error.localizedDescription)"
        }
    }
    
    // MARK: - 保存学习记录
    private func saveStudyRecord(_ record: StudyRecord) {
        do {
            try db.collection("studyRecords").document(record.id).setData(from: record)
        } catch {
            errorMessage = "保存学习记录失败: \(error.localizedDescription)"
        }
    }
    
    // MARK: - 检查并重置每日计数
    private func checkAndResetDailyCount() {
        guard var wallet = wallet else { return }
        
        let calendar = Calendar.current
        let today = Date()
        
        // 检查是否需要重置每日计数
        if !calendar.isDate(wallet.lastResetDate, inSameDayAs: today) {
            wallet.dailyEarned = 0
            wallet.lastResetDate = today
            
            // 保存更新
            do {
                try db.collection("wallets").document(wallet.id).setData(from: wallet)
                self.wallet = wallet
            } catch {
                errorMessage = "重置每日计数失败: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - 消费金币
    func spendCoins(_ amount: Int) -> Bool {
        guard var wallet = wallet, wallet.balance >= amount else {
            errorMessage = "金币余额不足"
            return false
        }
        
        wallet.balance -= amount
        
        do {
            try db.collection("wallets").document(wallet.id).setData(from: wallet)
            self.wallet = wallet
            return true
        } catch {
            errorMessage = "消费金币失败: \(error.localizedDescription)"
            return false
        }
    }
    
    // MARK: - 获取钱包统计信息
    var walletStats: (balance: Int, dailyEarned: Int, dailyRemaining: Int, streak: Int, bonusActive: Bool, totalEarned: Int) {
        let balance = wallet?.balance ?? 0
        let dailyEarned = wallet?.dailyEarned ?? 0
        let dailyRemaining = dailyCoinLimit - dailyEarned
        let streak = streakRecord?.currentStreak ?? 0
        let bonusActive = (streakRecord?.bonusMultiplier ?? 1.0) > 1.0
        let totalEarned = wallet?.totalEarned ?? 0
        
        return (balance, dailyEarned, dailyRemaining, streak, bonusActive, totalEarned)
    }
}
