import SwiftUI

public struct LyricsSheetView: View {
    @ObservedObject var lyricsService = LrcLyricsService.shared
    @ObservedObject var playerManager = AudioPlayerManager.shared
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Expressive background matching current palette
            playerManager.currentPalette.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Lyrics")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(playerManager.currentPalette.primaryText)
                        
                        if let track = playerManager.currentTrack {
                            Text("\(track.title) • \(track.artist)")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(playerManager.currentPalette.secondaryText)
                                .lineLimit(1)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if let track = playerManager.currentTrack {
                            lyricsService.fetchLyrics(for: track)
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(playerManager.currentPalette.primaryText)
                            .padding(8)
                            .background(playerManager.currentPalette.surface)
                            .clipShape(Circle())
                    }
                    
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(playerManager.currentPalette.primaryText)
                            .padding(8)
                            .background(playerManager.currentPalette.surface)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 12)
                
                Divider()
                    .background(Color.white.opacity(0.1))
                
                // Content
                if lyricsService.isLoading {
                    Spacer()
                    VStack(spacing: 16) {
                        ProgressView()
                            .tint(playerManager.currentPalette.accent)
                            .scaleEffect(1.3)
                        Text("Fetching lyrics from LRCLIB...")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(playerManager.currentPalette.secondaryText)
                    }
                    Spacer()
                } else if !lyricsService.currentLyrics.isEmpty {
                    ScrollViewReader { proxy in
                        ScrollView(showsIndicators: false) {
                            LazyVStack(alignment: .leading, spacing: 22) {
                                ForEach(Array(lyricsService.currentLyrics.enumerated()), id: \.element.id) { index, line in
                                    let isActive = index == playerManager.activeLyricIndex
                                    
                                    Button(action: {
                                        playerManager.seek(to: line.timestamp)
                                        let generator = UIImpactFeedbackGenerator(style: .medium)
                                        generator.impactOccurred()
                                    }) {
                                        Text(line.text.isEmpty ? "•••" : line.text)
                                            .font(.system(
                                                size: isActive ? 26 : 20,
                                                weight: isActive ? .bold : .medium,
                                                design: .rounded
                                            ))
                                            .foregroundColor(
                                                isActive
                                                ? playerManager.currentPalette.accent
                                                : playerManager.currentPalette.secondaryText.opacity(0.4)
                                            )
                                            .multilineTextAlignment(.leading)
                                            .scaleEffect(isActive ? 1.03 : 1.0, anchor: .leading)
                                            .animation(.spring(response: 0.35, dampingFraction: 0.75), value: isActive)
                                    }
                                    .id(index)
                                }
                            }
                            .padding(.horizontal, 28)
                            .padding(.vertical, 40)
                        }
                        .onChange(of: playerManager.activeLyricIndex) { newIndex in
                            withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                                proxy.scrollTo(newIndex, anchor: .center)
                            }
                        }
                    }
                } else {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "quote.bubble")
                            .font(.system(size: 48))
                            .foregroundColor(playerManager.currentPalette.secondaryText.opacity(0.5))
                        Text(lyricsService.errorMessage ?? "No lyrics found")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(playerManager.currentPalette.secondaryText)
                    }
                    Spacer()
                }
            }
        }
    }
}
