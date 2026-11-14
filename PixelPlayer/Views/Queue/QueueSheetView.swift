import SwiftUI

public struct QueueSheetView: View {
    @ObservedObject var playerManager = AudioPlayerManager.shared
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        ZStack {
            playerManager.currentPalette.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Playing Queue")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(playerManager.currentPalette.primaryText)
                        
                        Text("\(playerManager.queue.count) tracks")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(playerManager.currentPalette.secondaryText)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        playerManager.toggleShuffle()
                    }) {
                        Image(systemName: "shuffle")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(playerManager.isShuffleEnabled ? playerManager.currentPalette.accent : playerManager.currentPalette.secondaryText)
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
                
                // Track list
                List {
                    ForEach(Array(playerManager.queue.enumerated()), id: \.element.id) { index, track in
                        let isCurrent = playerManager.currentIndex == index
                        
                        HStack(spacing: 14) {
                            if let art = track.artwork {
                                Image(uiImage: art)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 44, height: 44)
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            } else {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(playerManager.currentPalette.surface)
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Image(systemName: "music.note")
                                            .foregroundColor(playerManager.currentPalette.accent)
                                    )
                            }
                            
                            VStack(alignment: .leading, spacing: 3) {
                                Text(track.title)
                                    .font(.system(size: 15, weight: isCurrent ? .bold : .medium, design: .rounded))
                                    .foregroundColor(isCurrent ? playerManager.currentPalette.accent : playerManager.currentPalette.primaryText)
                                    .lineLimit(1)
                                
                                Text(track.artist)
                                    .font(.system(size: 13))
                                    .foregroundColor(playerManager.currentPalette.secondaryText)
                                    .lineLimit(1)
                            }
                            
                            Spacer()
                            
                            if isCurrent {
                                Image(systemName: "waveform")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(playerManager.currentPalette.accent)
                            } else {
                                Text(track.formattedDuration)
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(playerManager.currentPalette.secondaryText.opacity(0.7))
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            playerManager.playTrack(at: index)
                        }
                        .listRowBackground(
                            isCurrent
                            ? playerManager.currentPalette.surface.opacity(0.6)
                            : Color.clear
                        )
                        .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
                    }
                    .onDelete { indexSet in
                        playerManager.queue.remove(atOffsets: indexSet)
                    }
                    .onMove { indices, newOffset in
                        playerManager.queue.move(fromOffsets: indices, toOffset: newOffset)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
    }
}
