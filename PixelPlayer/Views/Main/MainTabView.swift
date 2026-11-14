import SwiftUI

public struct MainTabView: View {
    @ObservedObject var playerManager = AudioPlayerManager.shared
    @State private var selectedTab: Int = 0
    @State private var isFullPlayerPresented: Bool = false
    
    public init() {}
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            // Main Tab View
            TabView(selection: $selectedTab) {
                LibraryView()
                    .tabItem {
                        Label("Library", systemImage: "music.note.list")
                    }
                    .tag(0)
                
                QueueSheetView()
                    .tabItem {
                        Label("Queue", systemImage: "list.bullet")
                    }
                    .tag(1)
                
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                    .tag(2)
            }
            .tint(playerManager.currentPalette.accent)
            
            // Floating Mini Player (docked above the TabBar)
            if playerManager.currentTrack != nil {
                MiniPlayerView {
                    isFullPlayerPresented = true
                }
                .padding(.bottom, 54)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.spring(response: 0.35, dampingFraction: 0.8), value: playerManager.currentTrack)
            }
        }
        .fullScreenCover(isPresented: $isFullPlayerPresented) {
            FullPlayerView()
        }
    }
}
