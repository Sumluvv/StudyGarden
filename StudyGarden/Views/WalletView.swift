import SwiftUI

struct WalletView: View {
    @StateObject private var walletManager = WalletManager()
    @State private var showingStudySession = false
    @State private var studyStartTime: Date?
    @State private var isStudying = false
    
    var body: some View {
        NavigationView {
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
                .padding()
            }
            .navigationTitle("我的钱包")
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
    }
    
    // MARK: - 钱包余额卡片
    private var walletBalanceCard: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: "creditcard.fill")
                    .foregroundColor(.yellow)
                    .font(.title2)
                
                Text("钱包余额")
                    .font(.headline)
                
                Spacer()
            }
            
            HStack {
                Text("\(walletManager.walletStats.balance)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("金币")
                    .font(.title3)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            
            HStack {
                Text("总获得: \(walletManager.walletStats.totalEarned) 金币")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
    
    // MARK: - 连续打卡卡片
    private var streakCard: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                    .font(.title2)
                
                Text("连续打卡")
                    .font(.headline)
                
                Spacer()
                
                if walletManager.walletStats.bonusActive {
                    HStack(spacing: 5) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        
                        Text("+10%加成")
                            .font(.caption)
                            .foregroundColor(.orange)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
            }
            
            HStack {
                Text("\(walletManager.walletStats.streak)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.orange)
                
                Text("天")
                    .font(.title3)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            
            HStack {
                Text("连续学习可获得金币加成")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
    
    // MARK: - 今日进度卡片
    private var dailyProgressCard: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.blue)
                    .font(.title2)
                
                Text("今日进度")
                    .font(.headline)
                
                Spacer()
            }
            
            VStack(spacing: 10) {
                HStack {
                    Text("已获得: \(walletManager.walletStats.dailyEarned) 金币")
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text("剩余: \(walletManager.walletStats.dailyRemaining) 金币")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                ProgressView(value: Double(walletManager.walletStats.dailyEarned), total: Double(80))
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
            }
            
            HStack {
                Text("每日上限: 80 金币")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
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
            .background(isStudying ? Color.red : Color.green)
            .cornerRadius(15)
        }
        .disabled(walletManager.isProcessing)
    }
    
    // MARK: - 学习记录部分
    private var studyRecordsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.purple)
                    .font(.title2)
                
                Text("学习记录")
                    .font(.headline)
                
                Spacer()
            }
            
            if walletManager.isProcessing {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("处理中...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
            } else {
                Text("点击开始学习按钮开始记录学习时间")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
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
