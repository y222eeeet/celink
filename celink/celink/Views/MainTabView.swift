import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
                    .toolbar(.hidden, for: .navigationBar)
            }
            .tabItem {
                Label("홈", systemImage: "house.fill")
            }

            NavigationStack {
                PlaceholderTabView(title: "이벤트 만들기", subtitle: "다음 단계에서 구현됩니다")
                    .toolbar(.hidden, for: .navigationBar)
            }
            .tabItem {
                Label("만들기", systemImage: "plus.circle")
            }

            NavigationStack {
                PlaceholderTabView(title: "프로필", subtitle: "다음 단계에서 구현됩니다")
                    .toolbar(.hidden, for: .navigationBar)
            }
            .tabItem {
                Label("프로필", systemImage: "person.fill")
            }
        }
        .tint(CelinkTheme.primaryDeep)
    }
}

struct PlaceholderTabView: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.title2.weight(.medium))
                .fontDesign(.serif)
                .foregroundStyle(CelinkTheme.ink)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(CelinkTheme.inkMuted)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CelinkTheme.background)
    }
}

#Preview {
    MainTabView()
}
