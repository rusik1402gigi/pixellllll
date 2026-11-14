import SwiftUI

public struct MiniPlayerView: View {
    @ObservedObject var playerManager = AudioPlayerManager.shared
    public let onExpand: () -> Void
    
    public init(onExpand: @escaping () -> Void) {
        self.onExpand = onExpand
    }
    
    public var body: some View {
        if let track = playerManager.currentTrack {
            HStack(spacing: 12) {
                // Thumbnail
                if let artwork = track.artwork {
                    Image(uiImage: artwork)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 44, height: 44)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                } else {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(playerManager.currentPalette.surface)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: "music.note")
                                .font(.system(size: 18))
                                .foregroundColor(playerManager.currentPalette.accent)
                        )
                }
                
                // Track Info
                VStack(alignment: .leading, spacing: 2) {
                    Text(track.title)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(playerManager.currentPalette.primaryText)
                        .lineLimit(1)
                    
                    Text(track.artist)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(playerManager.currentPalette.secondaryText)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Controls
                HStack(spacing: 8) {
                    Button(action: {
                        playerManager.togglePlayPause()
                        let gen = UIImpactFeedbackGenerator(style: .medium)
                        gen.impactOccurred()
                    }) {
                        Image(systemName: playerManager.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(playerManager.currentPalette.primaryText)
                            .frame(width: 36, height: 36)
                    }
                    
                    Button(action: {
                        playerManager.nextTrack()
                        let gen = UIImpactFeedbackGenerator(style: .light)
                        gen.impactOccurred()
                    }) {
                        Image(systemName: "forward.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(playerManager.currentPalette.secondaryText)
                            .frame(width: 36, height: 36)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(playerManager.currentPalette.surface.opacity(0.95))
                    .shadow(color: Color.black.opacity(0.35), radius: 14, x: 0, y: 6)
            )
            .overlay(
                // Expressive thin progress border at bottom
                GeometryReader { geo in
                    let progress = playerManager.duration > 0
                        ? CGFloat(playerManager.currentTime / playerManager.duration)
                        : 0
                    
                    Capsule()
                        .fill(playerManager.currentPalette.accent)
                        .frame(width: max(0, min(geo.size.width * progress, geo.size.width)), height: 2.5)
                        .position(x: (geo.size.width * progress) / 2, y: geo.size.height - 1.25)
                }
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            )
            .padding(.horizontal, 16)
            .contentShape(Rectangle())
            .onTapGesture {
                onExpand()
            }
        }
    }
}
