import SwiftUI

struct WalletView: View {
    @StateObject private var walletManager = WalletManager()
    @State private var showingStudySession = false
    @State private var studyStartTime: Date?
    @State private var isStudying = false
    
    // 统一的绿色主题
    private let primaryGreen = Color(red: 0.4, green: 0.6, blue: 0.4, opacity: 0.9)
    private let secondaryGreen = Color(red: 0.5, green: 0.7, blue: 0.5, opacity: 0.7)
    private let lightGreen = Color(red: 0.6, green: 0.8, blue: 0.6, opacity: 0.3)
    private let darkGreen = Color(red: 0.3, green: 0.5, blue: 0.3, opacity: 0.8)
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题居中显示
            Text("我的钱包")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(darkGreen)
                .padding(.top, 60) // 增加顶部间距避免摄像头遮挡
                .padding(.bottom, 20)
            
            ScrollView {
                VStack(spacing: 20) {
                    // 钱包余额卡片
                    walletBalanceCard
                    
                    // 连续打卡卡片
                    streakCard
                    
                    // 今日进度卡片
                    dailyProgressCard
                    
                    // 学习按钮
                    studyButton
                    
                    // 学习记录
                    studyRecordsSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100) // 增加底部间距避免底边栏遮挡
            }
        }
        .onAppear {
            // 模拟用户ID，实际应用中应该从认证系统获取
            walletManager.initializeWallet(for: "demo_user_123")
        }
        .alert("错误", isPresented: .constant(walletManager.errorMessage != nil)) {
            Button("确定") {
                walletManager.errorMessage = nil
            }
        } message: {
            Text(walletManager.errorMessage ?? "")
        }
    }
    
    // MARK: - 钱包余额卡片
    private var walletBalanceCard: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: "creditcard.fill")
                    .foregroundColor(darkGreen)
                    .font(.title2)
                
                Text("钱包余额")
                    .font(.headline)
                    .foregroundColor(darkGreen)
                
                Spacer()
            }
            
            HStack {
                Text("\(walletManager.walletStats.balance)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(darkGreen)
                
                Text("金币")
                    .font(.title3)
                    .foregroundColor(secondaryGreen)
                
                Spacer()
            }
            
            HStack {
                Text("总获得: \(walletManager.walletStats.totalEarned) 金币")
                    .font(.caption)
                    .foregroundColor(secondaryGreen)
                
                Spacer()
            }
        }
        .padding()
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(primaryGreen, lineWidth: 2)
        )
    }
    
    // MARK: - 连续打卡卡片
    private var streakCard: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(primaryGreen)
                    .font(.title2)
                
                Text("连续打卡")
                    .font(.headline)
                    .foregroundColor(darkGreen)
                
                Spacer()
                
                if walletManager.walletStats.bonusActive {
                    HStack(spacing: 5) {
                        Image(systemName: "star.fill")
                            .foregroundColor(primaryGreen)
                            .font(.caption)
                        
                        Text("+10%加成")
                            .font(.caption)
                            .foregroundColor(primaryGreen)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(lightGreen)
                            .cornerRadius(8)
                    }
                }
            }
            
            HStack {
                Text("\(walletManager.walletStats.streak)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(primaryGreen)
                
                Text("天")
                    .font(.title3)
                    .foregroundColor(secondaryGreen)
                
                Spacer()
            }
            
            HStack {
                Text("连续学习可获得金币加成")
                    .font(.caption)
                    .foregroundColor(secondaryGreen)
                
                Spacer()
            }
        }
        .padding()
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(primaryGreen, lineWidth: 2)
        )
    }
    
    // MARK: - 今日进度卡片
    private var dailyProgressCard: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(primaryGreen)
                    .font(.title2)
                
                Text("今日进度")
                    .font(.headline)
                    .foregroundColor(darkGreen)
                
                Spacer()
            }
            
            VStack(spacing: 10) {
                HStack {
                    Text("已获得: \(walletManager.walletStats.dailyEarned) 金币")
                        .font(.subheadline)
                        .foregroundColor(darkGreen)
                    
                    Spacer()
                    
                    Text("剩余: \(walletManager.walletStats.dailyRemaining) 金币")
                        .font(.subheadline)
                        .foregroundColor(secondaryGreen)
                }
                
                ProgressView(value: Double(walletManager.walletStats.dailyEarned), total: Double(80))
                    .progressViewStyle(LinearProgressViewStyle(tint: primaryGreen))
                    .scaleEffect(x: 1, y: 1.5, anchor: .center)
            }
            
            HStack {
                Text("每日上限: 80 金币")
                    .font(.caption)
                    .foregroundColor(secondaryGreen)
                
                Spacer()
            }
        }
        .padding()
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(primaryGreen, lineWidth: 2)
        )
    }
    
    // MARK: - 学习按钮
    private var studyButton: some View {
        Button(action: {
            if isStudying {
                stopStudySession()
            } else {
                startStudySession()
            }
        }) {
            HStack {
                Image(systemName: isStudying ? "stop.fill" : "play.fill")
                    .font(.title2)
                
                Text(isStudying ? "停止学习" : "开始学习")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(isStudying ? darkGreen : primaryGreen)
            .cornerRadius(15)
        }
        .disabled(walletManager.isProcessing)
    }
    
    // MARK: - 学习记录部分
    private var studyRecordsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(primaryGreen)
                    .font(.title2)
                
                Text("学习记录")
                    .font(.headline)
                    .foregroundColor(darkGreen)
                
                Spacer()
            }
            
            if walletManager.isProcessing {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                        .progressViewStyle(CircularProgressViewStyle(tint: primaryGreen))
                    Text("处理中...")
                        .font(.subheadline)
                        .foregroundColor(secondaryGreen)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
            } else {
                Text("点击开始学习按钮开始记录学习时间")
                    .font(.subheadline)
                    .foregroundColor(secondaryGreen)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
        .padding()
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(primaryGreen, lineWidth: 2)
        )
    }
    
    // MARK: - 开始学习
    private func startStudySession() {
        studyStartTime = Date()
        isStudying = true
    }
    
    // MARK: - 停止学习
    private func stopStudySession() {
        guard let startTime = studyStartTime else { return }
        
        let endTime = Date()
        walletManager.processStudySession(startTime: startTime, endTime: endTime)
        
        studyStartTime = nil
        isStudying = false
    }
}

#Preview {
    WalletView()
}
