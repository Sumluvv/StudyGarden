import SwiftUI

struct ContentView: View {
    // 统一的绿色主题
    private let primaryGreen = Color(red: 0.4, green: 0.6, blue: 0.4, opacity: 0.9)
    private let lightGreen = Color(red: 0.6, green: 0.8, blue: 0.6, opacity: 0.3)
    
    var body: some View {
        TabView {
            StudyTimerView()
                .tabItem {
                    Image(systemName: "timer")
                    Text("学习计时")
                }
            
            WalletView()
                .tabItem {
                    Image(systemName: "creditcard.fill")
                    Text("我的钱包")
                }
            
            Text("虚拟花园")
                .tabItem {
                    Image(systemName: "leaf.fill")
                    Text("花园")
                }
            
            Text("抽卡系统")
                .tabItem {
                    Image(systemName: "gift.fill")
                    Text("抽卡")
                }
            
            Text("排行榜")
                .tabItem {
                    Image(systemName: "trophy.fill")
                    Text("排行")
                }
        }
        .accentColor(primaryGreen)
        .onAppear {
            // 设置TabBar背景色
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(lightGreen)
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

#Preview {
    ContentView()
}
