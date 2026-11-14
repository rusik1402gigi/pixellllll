import Foundation
import AVFoundation
import MediaPlayer
import UIKit
import SwiftUI
import Combine

public enum RepeatMode: Int {
    case off = 0
    case all = 1
    case one = 2
}

public class AudioPlayerManager: NSObject, ObservableObject {
    public static let shared = AudioPlayerManager()
    
    // Playback state
    @Published public var currentTrack: Track?
    @Published public var isPlaying: Bool = false
    @Published public var currentTime: TimeInterval = 0
    @Published public var duration: TimeInterval = 0
    @Published public var currentPalette: ColorExtractor.Palette = .fallback
    @Published public var activeLyricIndex: Int = 0
    
    // Queue state
    @Published public var queue: [Track] = []
    @Published public var originalQueue: [Track] = []
    @Published public var currentIndex: Int = 0
    @Published public var isShuffleEnabled: Bool = false
    @Published public var repeatMode: RepeatMode = .off
    
    private var player: AVPlayer?
    private var timeObserverToken: Any?
    private var cancellables = Set<AnyCancellable>()
    
    public override init() {
        super.init()
        setupAudioSession()
        setupRemoteCommandCenter()
        observeLyricsSync()
    }
    
    deinit {
        removeTimeObserver()
    }
    
    // MARK: - Audio Session & Remote Control
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, policy: .longFormAudio)
            try session.setActive(true)
        } catch {
            print("Failed to activate AVAudioSession: \(error.localizedDescription)")
        }
    }
    
    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.play()
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.pause()
            return .success
        }
        
        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            self?.togglePlayPause()
            return .success
        }
        
        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            self?.nextTrack()
            return .success
        }
        
        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            self?.previousTrack()
            return .success
        }
        
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            if let positionEvent = event as? MPChangePlaybackPositionCommandEvent {
                self?.seek(to: positionEvent.positionTime)
                return .success
            }
            return .commandFailed
        }
    }
    
    private func updateNowPlayingInfo() {
        guard let track = currentTrack else {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
            return
        }
        
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = track.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = track.artist
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = track.album
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        
        if let artwork = track.artwork {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: artwork.size) { _ in artwork }
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    // MARK: - Queue Management
    public func setQueue(_ tracks: [Track], startAtIndex index: Int = 0) {
        guard !tracks.isEmpty else { return }
        self.originalQueue = tracks
        self.queue = tracks
        self.currentIndex = max(0, min(index, tracks.count - 1))
        
        if isShuffleEnabled {
            applyShuffle()
        }
        
        playTrack(at: self.currentIndex)
    }
    
    public func playTrack(at index: Int) {
        guard index >= 0 && index < queue.count else { return }
        self.currentIndex = index
        let track = queue[index]
        self.currentTrack = track
        
        // Extract palette dynamically
        self.currentPalette = ColorExtractor.shared.extractPalette(from: track.artwork)
        
        // Fetch lyrics via LRCLIB
        LrcLyricsService.shared.fetchLyrics(for: track)
        
        // Load and play audio
        if let url = track.fileURL {
            setupPlayer(with: url)
        } else {
            // Simulated playback for demo tracks
            self.duration = track.duration > 0 ? track.duration : 210
            self.currentTime = 0
            self.play()
        }
        
        updateNowPlayingInfo()
    }
    
    private func setupPlayer(with url: URL) {
        removeTimeObserver()
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        
        let playerItem = AVPlayerItem(url: url)
        if player == nil {
            player = AVPlayer(playerItem: playerItem)
        } else {
            player?.replaceCurrentItem(with: playerItem)
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerItemDidReachEnd),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )
        
        // Add periodic observer for smooth 20Hz UI updates (for Wavy Slider & Lyrics)
        let interval = CMTime(seconds: 0.05, preferredTimescale: 600)
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            self.currentTime = time.seconds
            if let currentItem = self.player?.currentItem {
                let itemDuration = currentItem.duration.seconds
                if itemDuration.isFinite && itemDuration > 0 {
                    self.duration = itemDuration
                }
            }
            self.updateNowPlayingInfo()
        }
        
        play()
    }
    
    private func removeTimeObserver() {
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
            timeObserverToken = nil
        }
    }
    
    @objc private func playerItemDidReachEnd() {
        switch repeatMode {
        case .one:
            seek(to: 0)
            play()
        case .all:
            nextTrack()
        case .off:
            if currentIndex < queue.count - 1 {
                nextTrack()
            } else {
                pause()
                seek(to: 0)
            }
        }
    }
    
    // MARK: - Playback Controls
    public func play() {
        if let player = player {
            player.play()
        }
        isPlaying = true
        updateNowPlayingInfo()
    }
    
    public func pause() {
        if let player = player {
            player.pause()
        }
        isPlaying = false
        updateNowPlayingInfo()
    }
    
    public func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    public func nextTrack() {
        guard !queue.isEmpty else { return }
        if currentIndex + 1 < queue.count {
            playTrack(at: currentIndex + 1)
        } else if repeatMode == .all {
            playTrack(at: 0)
        }
    }
    
    public func previousTrack() {
        if currentTime > 3.0 {
            seek(to: 0)
            return
        }
        
        guard !queue.isEmpty else { return }
        if currentIndex > 0 {
            playTrack(at: currentIndex - 1)
        } else if repeatMode == .all {
            playTrack(at: queue.count - 1)
        } else {
            seek(to: 0)
        }
    }
    
    public func seek(to time: TimeInterval) {
        currentTime = time
        if let player = player {
            let targetTime = CMTime(seconds: time, preferredTimescale: 600)
            player.seek(to: targetTime, toleranceBefore: .zero, toleranceAfter: .zero)
        }
        updateNowPlayingInfo()
    }
    
    public func toggleShuffle() {
        isShuffleEnabled.toggle()
        guard let current = currentTrack else { return }
        
        if isShuffleEnabled {
            applyShuffle()
        } else {
            queue = originalQueue
            if let index = queue.firstIndex(of: current) {
                currentIndex = index
            }
        }
    }
    
    private func applyShuffle() {
        guard let current = currentTrack else { return }
        var remaining = originalQueue.filter { $0 != current }
        remaining.shuffle()
        queue = [current] + remaining
        currentIndex = 0
    }
    
    public func cycleRepeatMode() {
        switch repeatMode {
        case .off: repeatMode = .all
        case .all: repeatMode = .one
        case .one: repeatMode = .off
        }
    }
    
    public func toggleFavorite(for track: Track) {
        if let idx = queue.firstIndex(where: { $0.id == track.id }) {
            queue[idx].isFavorite.toggle()
        }
        if let idx = originalQueue.firstIndex(where: { $0.id == track.id }) {
            originalQueue[idx].isFavorite.toggle()
        }
        if currentTrack?.id == track.id {
            currentTrack?.isFavorite.toggle()
        }
    }
    
    // MARK: - Synchronized Lyrics Observer
    private func observeLyricsSync() {
        $currentTime
            .combineLatest(LrcLyricsService.shared.$currentLyrics)
            .sink { [weak self] (time, lyrics) in
                guard let self = self, !lyrics.isEmpty else { return }
                
                var activeIdx = 0
                for (i, line) in lyrics.enumerated() {
                    if time >= line.timestamp {
                        activeIdx = i
                    } else {
                        break
                    }
                }
                if self.activeLyricIndex != activeIdx {
                    self.activeLyricIndex = activeIdx
                }
            }
            .store(in: &cancellables)
    }
}
