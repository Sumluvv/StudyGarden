import SwiftUI

struct StudyTimerView: View {
    @StateObject private var walletManager = WalletManager()
    @State private var studyStartTime: Date?
    @State private var isStudying = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // 计时器显示
                timerDisplay
                
                // 金币预估
                coinsEstimate
                
                // 控制按钮
                controlButtons
                
                // 学习状态
                studyStatus
                
                Spacer()
            }
            .padding()
            .navigationTitle("学习计时器")
            .onAppear {
                walletManager.initializeWallet(for: "demo_user_123")
            }
            .onDisappear {
                stopTimer()
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
    
    // MARK: - 计时器显示
    private var timerDisplay: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.2), lineWidth: 20)
                    .frame(width: 250, height: 250)
                
                Circle()
                    .trim(from: 0, to: min(elapsedTime / 3600, 1.0)) // 1小时为满圆
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .frame(width: 250, height: 250)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1), value: elapsedTime)
                
                VStack(spacing: 10) {
                    Text(timeString(from: elapsedTime))
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .foregroundColor(.primary)
                    
                    Text("学习时长")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    // MARK: - 金币预估
    private var coinsEstimate: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: "creditcard.fill")
                    .foregroundColor(.yellow)
                    .font(.title2)
                
                Text("本次预估")
                    .font(.headline)
                
                Spacer()
            }
            
            HStack {
                Text("\(estimatedCoins)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.yellow)
                
                Text("金币")
                    .font(.title3)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            
            if walletManager.walletStats.bonusActive {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                    
                    Text("连续打卡加成 +10%")
                        .font(.caption)
                        .foregroundColor(.orange)
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
    
    // MARK: - 控制按钮
    private var controlButtons: some View {
        HStack(spacing: 30) {
            // 开始/暂停按钮
            Button(action: {
                if isStudying {
                    pauseStudy()
                } else {
                    if studyStartTime == nil {
                        startStudy()
                    } else {
                        resumeStudy()
                    }
                }
            }) {
                HStack {
                    Image(systemName: isStudying ? "pause.fill" : "play.fill")
                        .font(.title2)
                    
                    Text(isStudying ? "暂停" : (studyStartTime == nil ? "开始" : "继续"))
                        .font(.headline)
                }
                .foregroundColor(.white)
                .frame(width: 120, height: 50)
                .background(isStudying ? Color.orange : Color.green)
                .cornerRadius(25)
            }
            
            // 停止按钮
            Button(action: stopStudy) {
                HStack {
                    Image(systemName: "stop.fill")
                        .font(.title2)
                    
                    Text("结束")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .frame(width: 120, height: 50)
                .background(Color.red)
                .cornerRadius(25)
            }
            .disabled(studyStartTime == nil)
        }
    }
    
    // MARK: - 学习状态
    private var studyStatus: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
                
                Text("学习状态")
                    .font(.headline)
                
                Spacer()
            }
            
            VStack(spacing: 10) {
                HStack {
                    Text("今日已获得:")
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text("\(walletManager.walletStats.dailyEarned) / 80")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                ProgressView(value: Double(walletManager.walletStats.dailyEarned), total: 80)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                
                HStack {
                    Text("连续打卡:")
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text("\(walletManager.walletStats.streak) 天")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
    
    // MARK: - 计算预估金币
    private var estimatedCoins: Int {
        let baseCoins = Int(elapsedTime / 600) // 每10分钟1币
        let remainingDailyLimit = 80 - walletManager.walletStats.dailyEarned
        let limitedCoins = min(baseCoins, remainingDailyLimit)
        
        if walletManager.walletStats.bonusActive {
            return Int(Double(limitedCoins) * 1.1)
        }
        
        return limitedCoins
    }
    
    // MARK: - 开始学习
    private func startStudy() {
        studyStartTime = Date()
        isStudying = true
        startTimer()
    }
    
    // MARK: - 暂停学习
    private func pauseStudy() {
        isStudying = false
        stopTimer()
    }
    
    // MARK: - 继续学习
    private func resumeStudy() {
        isStudying = true
        startTimer()
    }
    
    // MARK: - 停止学习
    private func stopStudy() {
        guard let startTime = studyStartTime else { return }
        
        let endTime = Date()
        let totalTime = startTime.timeIntervalSinceNow.magnitude
        
        // 处理学习记录
        walletManager.processStudySession(startTime: startTime, endTime: endTime)
        
        // 重置状态
        studyStartTime = nil
        isStudying = false
        elapsedTime = 0
        stopTimer()
    }
    
    // MARK: - 启动计时器
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if let startTime = studyStartTime {
                elapsedTime = Date().timeIntervalSince(startTime)
            }
        }
    }
    
    // MARK: - 停止计时器
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - 时间格式化
    private func timeString(from timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        let seconds = Int(timeInterval) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

#Preview {
    StudyTimerView()
}
