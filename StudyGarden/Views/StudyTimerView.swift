import SwiftUI

struct StudyTimerView: View {
    @StateObject private var walletManager = WalletManager()
    @State private var studyStartTime: Date?
    @State private var isStudying = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var remainingTime: TimeInterval = 0
    @State private var selectedDuration: TimeInterval = 1500 // 默认25分钟
    @State private var timer: Timer?
    @State private var showIncompleteAlert = false
    
    // 低饱和度绿色调色方案
    private let primaryGreen = Color(red: 0.4, green: 0.6, blue: 0.4, opacity: 0.9)
    private let secondaryGreen = Color(red: 0.5, green: 0.7, blue: 0.5, opacity: 0.7)
    private let lightGreen = Color(red: 0.6, green: 0.8, blue: 0.6, opacity: 0.3)
    private let darkGreen = Color(red: 0.3, green: 0.5, blue: 0.3, opacity: 0.8)
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题居中显示
            Text("学习计时器")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(darkGreen)
                .padding(.top, 60) // 增加顶部间距避免摄像头遮挡
                .padding(.bottom, 20)
            
            VStack(spacing: 20) { // 减少间距
                // 计时器显示
                timerDisplay
                
                // 预设倒计时选项
                durationPresets

                // 金币预估
                coinsEstimate
                
                // 控制按钮
                controlButtons
                
                // 学习状态
                studyStatus
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100) // 增加底部间距避免底边栏遮挡
        }
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
        .alert("未完成学习目标", isPresented: $showIncompleteAlert) {
            Button("确定") { }
        } message: {
            Text("提前结束学习，本次不获得金币。请完成设定的学习时长以获得奖励。")
        }
    }
    
    // MARK: - 计时器显示（倒计时）
    private var timerDisplay: some View {
        VStack(spacing: 15) { // 减少间距
            ZStack {
                Circle()
                    .stroke(lightGreen, lineWidth: 15) // 减少线条宽度
                    .frame(width: 220, height: 220) // 稍微减小圆圈大小
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(primaryGreen, style: StrokeStyle(lineWidth: 15, lineCap: .round))
                    .frame(width: 220, height: 220)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: progress)
                
                VStack(spacing: 8) { // 减少间距
                    Text(timeString(from: max(remainingTime, 0)))
                        .font(.system(size: 42, weight: .bold, design: .monospaced)) // 稍微减小字体
                        .foregroundColor(darkGreen)
                    
                    Text(isStudying ? "倒计时" : "选择学习时长")
                        .font(.title3)
                        .foregroundColor(secondaryGreen)
                }
            }
        }
    }

    // MARK: - 预设时长选项
    private var durationPresets: some View {
        VStack(alignment: .leading, spacing: 10) { // 减少间距
            Text("预设时长")
                .font(.headline)
                .foregroundColor(darkGreen)
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack(spacing: 10) { // 减少间距
                presetButton(title: "25 分钟", seconds: 25 * 60)
                presetButton(title: "45 分钟", seconds: 45 * 60)
                presetButton(title: "60 分钟", seconds: 60 * 60)
            }
        }
        .padding(15) // 减少内边距
        .background(Color.white) // 改为白色背景
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(primaryGreen, lineWidth: 2) // 绿色边框
        )
    }

    private func presetButton(title: String, seconds: TimeInterval) -> some View {
        Button(action: {
            guard !isStudying else { return }
            selectedDuration = seconds
            remainingTime = seconds
            elapsedTime = 0
        }) {
            Text(title)
                .font(.subheadline)
                .padding(.vertical, 8) // 减少内边距
                .padding(.horizontal, 12)
                .background(selectedDuration == seconds ? primaryGreen : Color.clear)
                .foregroundColor(selectedDuration == seconds ? .white : darkGreen)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(selectedDuration == seconds ? primaryGreen : secondaryGreen, lineWidth: 1.5)
                )
        }
    }
    
    // MARK: - 金币预估
    private var coinsEstimate: some View {
        VStack(spacing: 12) { // 减少间距
            HStack {
                Image(systemName: "creditcard.fill")
                    .foregroundColor(darkGreen)
                    .font(.title2)
                
                Text("本次预估")
                    .font(.headline)
                    .foregroundColor(darkGreen)
                
                Spacer()
            }
            
            HStack {
                Text("\(estimatedCoins)")
                    .font(.system(size: 32, weight: .bold, design: .rounded)) // 稍微减小字体
                    .foregroundColor(darkGreen)
                
                Text("金币")
                    .font(.title3)
                    .foregroundColor(secondaryGreen)
                
                Spacer()
            }
            
            if walletManager.walletStats.bonusActive {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(primaryGreen)
                        .font(.caption)
                    
                    Text("连续打卡加成 +10%")
                        .font(.caption)
                        .foregroundColor(primaryGreen)
                    
                    Spacer()
                }
            }
        }
        .padding(15) // 减少内边距
        .background(Color.white) // 改为白色背景
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(primaryGreen, lineWidth: 2) // 绿色边框
        )
    }
    
    // MARK: - 控制按钮
    private var controlButtons: some View {
        HStack(spacing: 25) { // 减少间距
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
                .frame(width: 110, height: 45) // 稍微减小按钮大小
                .background(isStudying ? secondaryGreen : primaryGreen)
                .cornerRadius(22)
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
                .frame(width: 110, height: 45) // 稍微减小按钮大小
                .background(darkGreen)
                .cornerRadius(22)
            }
            .disabled(studyStartTime == nil)
        }
    }
    
    // MARK: - 学习状态
    private var studyStatus: some View {
        VStack(spacing: 12) { // 减少间距
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(primaryGreen)
                    .font(.title2)
                
                Text("学习状态")
                    .font(.headline)
                    .foregroundColor(darkGreen)
                
                Spacer()
            }
            
            VStack(spacing: 8) { // 减少间距
                HStack {
                    Text("今日已获得:")
                        .font(.subheadline)
                        .foregroundColor(darkGreen)
                    
                    Spacer()
                    
                    Text("\(walletManager.walletStats.dailyEarned) / 80")
                        .font(.subheadline)
                        .foregroundColor(secondaryGreen)
                }
                
                ProgressView(value: Double(walletManager.walletStats.dailyEarned), total: 80)
                    .progressViewStyle(LinearProgressViewStyle(tint: primaryGreen))
                    .scaleEffect(x: 1, y: 1.5, anchor: .center) // 减少进度条高度
                
                HStack {
                    Text("连续打卡:")
                        .font(.subheadline)
                        .foregroundColor(darkGreen)
                    
                    Spacer()
                    
                    Text("\(walletManager.walletStats.streak) 天")
                        .font(.subheadline)
                        .foregroundColor(primaryGreen)
                }
            }
        }
        .padding(15) // 减少内边距
        .background(Color.white) // 改为白色背景
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(primaryGreen, lineWidth: 2) // 绿色边框
        )
    }
    
    // MARK: - 计算预估金币（基于选择的总时长）
    private var estimatedCoins: Int {
        let baseCoins = Int(selectedDuration / 600) // 每10分钟1币
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
        remainingTime = selectedDuration
        elapsedTime = 0
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
        
        // 检查是否完成学习目标
        if remainingTime > 0 {
            // 提前结束，不增加金币
            showIncompleteAlert = true
        } else {
            // 完成学习目标，处理学习记录
            let endTime = Date()
            walletManager.processStudySession(startTime: startTime, endTime: endTime)
        }
        
        // 重置状态
        studyStartTime = nil
        isStudying = false
        elapsedTime = 0
        remainingTime = 0
        stopTimer()
    }
    
    // MARK: - 启动计时器
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            guard isStudying else { return }
            if remainingTime > 0 {
                remainingTime -= 1
                elapsedTime = min(selectedDuration, selectedDuration - remainingTime)
            } else {
                // 倒计时完成
                stopStudy()
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

    // 进度 (0~1)
    private var progress: CGFloat {
        guard selectedDuration > 0 else { return 0 }
        return CGFloat((selectedDuration - max(remainingTime, 0)) / selectedDuration)
    }
}

#Preview {
    StudyTimerView()
}
