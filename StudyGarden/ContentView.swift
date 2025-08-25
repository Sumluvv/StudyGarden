import SwiftUI

struct ContentView: View {
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
        .accentColor(.green)
    }
}

#Preview {
    ContentView()
}
