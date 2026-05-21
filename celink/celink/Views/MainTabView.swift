import SwiftUI

struct MainTabView: View {
    private enum Tab: Hashable {
        case home, create, profile
    }

    @State private var selectedTab: Tab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView()
                    .toolbar(.hidden, for: .navigationBar)
            }
            .tag(Tab.home)
            .tabItem {
                Label("홈", systemImage: "house.fill")
            }

            NavigationStack {
                CreateEventView()
                    .toolbar(.hidden, for: .navigationBar)
            }
            .tag(Tab.create)
            .tabItem {
                Label("만들기", systemImage: "plus.circle")
            }

            NavigationStack {
                ProfileView()
                    .toolbar(.hidden, for: .navigationBar)
            }
            .tag(Tab.profile)
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
