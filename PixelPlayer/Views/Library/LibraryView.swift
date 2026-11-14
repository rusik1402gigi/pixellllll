import SwiftUI

public struct LibraryView: View {
    @ObservedObject var libraryManager = MusicLibraryManager.shared
    @ObservedObject var playerManager = AudioPlayerManager.shared
    
    @State private var selectedTab: Int = 0
    @State private var searchQuery: String = ""
    @State private var showDocumentPicker: Bool = false
    
    public init() {}
    
    private var filteredTracks: [Track] {
        if searchQuery.isEmpty {
            return libraryManager.tracks
        }
        return libraryManager.tracks.filter {
            $0.title.localizedCaseInsensitiveContains(searchQuery) ||
            $0.artist.localizedCaseInsensitiveContains(searchQuery) ||
            $0.album.localizedCaseInsensitiveContains(searchQuery)
        }
    }
    
    public var body: some View {
        ZStack {
            Color(red: 0.07, green: 0.08, blue: 0.11)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // App Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("PixelPlayer")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(red: 0.4, green: 0.7, blue: 1.0), Color(red: 0.7, green: 0.4, blue: 0.9)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("\(libraryManager.tracks.count) songs • Local & Offline")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    // Import Music Button
                    Button(action: { showDocumentPicker = true }) {
                        HStack(spacing: 6) {
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .bold))
                            Text("Import")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 14)
                        .background(Color(red: 0.20, green: 0.22, blue: 0.30))
                        .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)
                
                // Search Field
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white.opacity(0.5))
                        .font(.system(size: 16))
                    
                    TextField("Search songs, artists, albums...", text: $searchQuery)
                        .foregroundColor(.white)
                        .font(.system(size: 15))
                    
                    if !searchQuery.isEmpty {
                        Button(action: { searchQuery = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .padding(.horizontal, 20)
                .padding(.bottom, 14)
                
                // Segmented Tabs
                HStack(spacing: 8) {
                    TabButton(title: "Songs", isSelected: selectedTab == 0) { selectedTab = 0 }
                    TabButton(title: "Albums", isSelected: selectedTab == 1) { selectedTab = 1 }
                    TabButton(title: "Artists", isSelected: selectedTab == 2) { selectedTab = 2 }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
                
                // Tab Content
                if selectedTab == 0 {
                    // Songs List
                    ScrollView {
                        LazyVStack(spacing: 6) {
                            ForEach(Array(filteredTracks.enumerated()), id: \.element.id) { index, track in
                                let isCurrent = playerManager.currentTrack?.id == track.id
                                
                                TrackRow(track: track, isCurrent: isCurrent)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        playerManager.setQueue(filteredTracks, startAtIndex: index)
                                        let gen = UIImpactFeedbackGenerator(style: .light)
                                        gen.impactOccurred()
                                    }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 120) // space for mini player
                    }
                } else if selectedTab == 1 {
                    // Albums Grid
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 16) {
                            ForEach(Array(libraryManager.albums.keys.sorted()), id: \.self) { albumName in
                                let tracksInAlbum = libraryManager.albums[albumName] ?? []
                                let firstTrack = tracksInAlbum.first
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    if let artwork = firstTrack?.artwork {
                                        Image(uiImage: artwork)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(height: 160)
                                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                    } else {
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .fill(Color.white.opacity(0.08))
                                            .frame(height: 160)
                                            .overlay(
                                                Image(systemName: "opticaldisc")
                                                    .font(.system(size: 40))
                                                    .foregroundColor(.white.opacity(0.4))
                                            )
                                    }
                                    
                                    Text(albumName)
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                    
                                    Text("\(tracksInAlbum.count) tracks")
                                        .font(.system(size: 12))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                .onTapGesture {
                                    if !tracksInAlbum.isEmpty {
                                        playerManager.setQueue(tracksInAlbum, startAtIndex: 0)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 120)
                    }
                } else {
                    // Artists List
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(Array(libraryManager.artists.keys.sorted()), id: \.self) { artistName in
                                let tracksByArtist = libraryManager.artists[artistName] ?? []
                                
                                HStack(spacing: 14) {
                                    Circle()
                                        .fill(Color(red: 0.22, green: 0.24, blue: 0.32))
                                        .frame(width: 50, height: 50)
                                        .overlay(
                                            Image(systemName: "person.fill")
                                                .foregroundColor(.white.opacity(0.7))
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(artistName)
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                        
                                        Text("\(tracksByArtist.count) tracks")
                                            .font(.system(size: 13))
                                            .foregroundColor(.white.opacity(0.6))
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.white.opacity(0.3))
                                        .font(.system(size: 14))
                                }
                                .padding(12)
                                .background(Color.white.opacity(0.04))
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .onTapGesture {
                                    if !tracksByArtist.isEmpty {
                                        playerManager.setQueue(tracksByArtist, startAtIndex: 0)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 120)
                    }
                }
            }
        }
        .sheet(isPresented: $showDocumentPicker) {
            DocumentPicker { urls in
                libraryManager.importFiles(from: urls)
            }
        }
    }
}

private struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .bold : .medium, design: .rounded))
                .foregroundColor(isSelected ? .black : .white.opacity(0.7))
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(isSelected ? Color.white : Color.white.opacity(0.07))
                .clipShape(Capsule())
        }
    }
}

private struct TrackRow: View {
    let track: Track
    let isCurrent: Bool
    
    var body: some View {
        HStack(spacing: 14) {
            if let art = track.artwork {
                Image(uiImage: art)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 48, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            } else {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: "music.note")
                            .foregroundColor(.white.opacity(0.6))
                    )
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(track.title)
                    .font(.system(size: 15, weight: isCurrent ? .bold : .medium, design: .rounded))
                    .foregroundColor(isCurrent ? Color(red: 0.4, green: 0.7, blue: 1.0) : .white)
                    .lineLimit(1)
                
                Text("\(track.artist) • \(track.album)")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(1)
            }
            
            Spacer()
            
            if isCurrent {
                Image(systemName: "waveform")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(red: 0.4, green: 0.7, blue: 1.0))
            } else {
                Text(track.formattedDuration)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white.opacity(0.4))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isCurrent ? Color.white.opacity(0.08) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
