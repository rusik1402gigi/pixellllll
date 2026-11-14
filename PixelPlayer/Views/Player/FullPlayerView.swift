import SwiftUI
import AVKit

public struct FullPlayerView: View {
    @ObservedObject var playerManager = AudioPlayerManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var showLyricsSheet: Bool = false
    @State private var showQueueSheet: Bool = false
    
    public init() {}
    
    private func formatTime(_ time: TimeInterval) -> String {
        guard time.isFinite && !time.isNaN else { return "0:00" }
        let totalSeconds = Int(time)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    public var body: some View {
        ZStack {
            // Dynamic Expressive Background Gradient
            LinearGradient(
                colors: [
                    playerManager.currentPalette.background,
                    playerManager.currentPalette.surface.opacity(0.85),
                    playerManager.currentPalette.background
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Subtle ambient glow behind album artwork
            RadialGradient(
                colors: [
                    playerManager.currentPalette.accent.opacity(0.25),
                    Color.clear
                ],
                center: .center,
                startRadius: 50,
                endRadius: 280
            )
            .offset(y: -50)
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Bar
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(playerManager.currentPalette.primaryText)
                            .frame(width: 44, height: 44)
                            .background(playerManager.currentPalette.surface.opacity(0.6))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 2) {
                        Text("PLAYING FROM LIBRARY")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .tracking(1.2)
                            .foregroundColor(playerManager.currentPalette.secondaryText)
                        
                        Text(playerManager.currentTrack?.album ?? "PixelPlayer")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(playerManager.currentPalette.primaryText)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    Button(action: { showQueueSheet = true }) {
                        Image(systemName: "list.bullet")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(playerManager.currentPalette.primaryText)
                            .frame(width: 44, height: 44)
                            .background(playerManager.currentPalette.surface.opacity(0.6))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                Spacer(minLength: 20)
                
                // Big Rounded Album Artwork
                ZStack {
                    if let artwork = playerManager.currentTrack?.artwork {
                        Image(uiImage: artwork)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: 320, maxHeight: 320)
                            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                            .shadow(color: playerManager.currentPalette.accent.opacity(0.35), radius: 24, x: 0, y: 12)
                    } else {
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .fill(playerManager.currentPalette.surface)
                            .frame(maxWidth: 320, maxHeight: 320)
                            .overlay(
                                Image(systemName: "music.note")
                                    .font(.system(size: 80))
                                    .foregroundColor(playerManager.currentPalette.accent)
                            )
                            .shadow(color: Color.black.opacity(0.4), radius: 20, x: 0, y: 10)
                    }
                }
                .scaleEffect(playerManager.isPlaying ? 1.0 : 0.94)
                .animation(.spring(response: 0.45, dampingFraction: 0.7), value: playerManager.isPlaying)
                .padding(.horizontal, 32)
                
                Spacer(minLength: 24)
                
                // Track Info & Favorite Heart
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(playerManager.currentTrack?.title ?? "No Track Selected")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(playerManager.currentPalette.primaryText)
                            .lineLimit(1)
                        
                        Text(playerManager.currentTrack?.artist ?? "Select a song from library")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(playerManager.currentPalette.secondaryText)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    if let track = playerManager.currentTrack {
                        Button(action: {
                            playerManager.toggleFavorite(for: track)
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                        }) {
                            Image(systemName: track.isFavorite ? "heart.fill" : "heart")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(track.isFavorite ? .red : playerManager.currentPalette.secondaryText)
                                .scaleEffect(track.isFavorite ? 1.15 : 1.0)
                                .animation(.spring(response: 0.25, dampingFraction: 0.6), value: track.isFavorite)
                        }
                    }
                }
                .padding(.horizontal, 28)
                
                Spacer(minLength: 16)
                
                // Wavy Progress Slider
                VStack(spacing: 4) {
                    WavyProgressSlider(
                        value: $playerManager.currentTime,
                        range: 0 ... max(1.0, playerManager.duration),
                        isPlaying: playerManager.isPlaying,
                        activeColor: playerManager.currentPalette.accent,
                        inactiveColor: playerManager.currentPalette.primaryText.opacity(0.2),
                        onSeek: { target in
                            playerManager.seek(to: target)
                        }
                    )
                    
                    HStack {
                        Text(formatTime(playerManager.currentTime))
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(playerManager.currentPalette.secondaryText)
                        
                        Spacer()
                        
                        Text(formatTime(playerManager.duration))
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(playerManager.currentPalette.secondaryText)
                    }
                }
                .padding(.horizontal, 28)
                
                Spacer(minLength: 16)
                
                // Playback Controls (Shuffle, Prev, Play/Pause FAB, Next, Repeat)
                HStack(spacing: 0) {
                    // Shuffle Button
                    Button(action: {
                        playerManager.toggleShuffle()
                        let gen = UIImpactFeedbackGenerator(style: .light)
                        gen.impactOccurred()
                    }) {
                        Image(systemName: "shuffle")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(
                                playerManager.isShuffleEnabled
                                ? playerManager.currentPalette.accent
                                : playerManager.currentPalette.secondaryText
                            )
                            .frame(maxWidth: .infinity)
                    }
                    
                    // Previous Track
                    Button(action: {
                        playerManager.previousTrack()
                        let gen = UIImpactFeedbackGenerator(style: .medium)
                        gen.impactOccurred()
                    }) {
                        Image(systemName: "backward.fill")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(playerManager.currentPalette.primaryText)
                            .frame(maxWidth: .infinity)
                    }
                    
                    // Main Play/Pause FAB
                    Button(action: {
                        playerManager.togglePlayPause()
                        let gen = UIImpactFeedbackGenerator(style: .heavy)
                        gen.impactOccurred()
                    }) {
                        ZStack {
                            Circle()
                                .fill(playerManager.currentPalette.accent)
                                .frame(width: 76, height: 76)
                                .shadow(color: playerManager.currentPalette.accent.opacity(0.4), radius: 12, x: 0, y: 6)
                            
                            Image(systemName: playerManager.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(playerManager.currentPalette.background)
                                .offset(x: playerManager.isPlaying ? 0 : 2)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Next Track
                    Button(action: {
                        playerManager.nextTrack()
                        let gen = UIImpactFeedbackGenerator(style: .medium)
                        gen.impactOccurred()
                    }) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(playerManager.currentPalette.primaryText)
                            .frame(maxWidth: .infinity)
                    }
                    
                    // Repeat Mode
                    Button(action: {
                        playerManager.cycleRepeatMode()
                        let gen = UIImpactFeedbackGenerator(style: .light)
                        gen.impactOccurred()
                    }) {
                        Image(systemName: playerManager.repeatMode == .one ? "repeat.1" : "repeat")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(
                                playerManager.repeatMode != .off
                                ? playerManager.currentPalette.accent
                                : playerManager.currentPalette.secondaryText
                            )
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 16)
                
                Spacer(minLength: 24)
                
                // Bottom Action Bar: Lyrics & AirPlay
                HStack(spacing: 24) {
                    // Synced Lyrics Button
                    Button(action: { showLyricsSheet = true }) {
                        HStack(spacing: 8) {
                            Image(systemName: "quote.bubble.fill")
                                .font(.system(size: 15, weight: .bold))
                            Text("Lyrics")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(playerManager.currentPalette.primaryText)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(playerManager.currentPalette.surface.opacity(0.8))
                        .clipShape(Capsule())
                    }
                    
                    // AirPlay / Route Picker
                    AirPlayRoutePicker(tintColor: playerManager.currentPalette.primaryText)
                        .frame(width: 44, height: 44)
                        .background(playerManager.currentPalette.surface.opacity(0.8))
                        .clipShape(Circle())
                }
                .padding(.bottom, 24)
            }
        }
        .sheet(isPresented: $showLyricsSheet) {
            LyricsSheetView()
        }
        .sheet(isPresented: $showQueueSheet) {
            QueueSheetView()
        }
    }
}

// UIKit wrapper for AVRoutePickerView (AirPlay)
struct AirPlayRoutePicker: UIViewRepresentable {
    let tintColor: Color
    
    func makeUIView(context: Context) -> AVRoutePickerView {
        let picker = AVRoutePickerView()
        picker.tintColor = UIColor(tintColor)
        picker.activeTintColor = .systemBlue
        picker.prioritizesVideoDevices = false
        return picker
    }
    
    func updateUIView(_ uiView: AVRoutePickerView, context: Context) {
        uiView.tintColor = UIColor(tintColor)
    }
}
