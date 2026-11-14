import Foundation
import UIKit
import AVFoundation

public class MusicLibraryManager: ObservableObject {
    public static let shared = MusicLibraryManager()
    
    @Published public var tracks: [Track] = []
    @Published public var albums: [String: [Track]] = [:]
    @Published public var artists: [String: [Track]] = [:]
    @Published public var isScanning: Bool = false
    
    public init() {
        loadDefaultDemoTracks()
        scanDocumentsDirectory()
    }
    
    public func scanDocumentsDirectory() {
        isScanning = true
        DispatchQueue.global(qos: .userInitiated).async {
            let fileManager = FileManager.default
            guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
                DispatchQueue.main.async { self.isScanning = false }
                return
            }
            
            let supportedExtensions = ["mp3", "flac", "m4a", "wav", "aac", "alac"]
            var scannedTracks: [Track] = []
            
            if let enumerator = fileManager.enumerator(at: documentsURL, includingPropertiesForKeys: [.isRegularFileKey]) {
                for case let fileURL as URL in enumerator {
                    if supportedExtensions.contains(fileURL.pathExtension.lowercased()) {
                        let track = self.extractMetadata(from: fileURL)
                        scannedTracks.append(track)
                    }
                }
            }
            
            DispatchQueue.main.async {
                if !scannedTracks.isEmpty {
                    self.tracks = scannedTracks
                }
                self.rebuildLibraryIndex()
                self.isScanning = false
            }
        }
    }
    
    public func importFiles(from urls: [URL]) {
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        for url in urls {
            let shouldStopAccessing = url.startAccessingSecurityScopedResource()
            defer {
                if shouldStopAccessing {
                    url.stopAccessingSecurityScopedResource()
                }
            }
            
            let destinationURL = documentsURL.appendingPathComponent(url.lastPathComponent)
            do {
                if fileManager.fileExists(atPath: destinationURL.path) {
                    try fileManager.removeItem(at: destinationURL)
                }
                try fileManager.copyItem(at: url, to: destinationURL)
            } catch {
                print("Error copying file: \(error.localizedDescription)")
            }
        }
        
        scanDocumentsDirectory()
    }
    
    private func extractMetadata(from url: URL) -> Track {
        let asset = AVAsset(url: url)
        var title = url.deletingPathExtension().lastPathComponent
        var artist = "Unknown Artist"
        var album = "Unknown Album"
        var artwork: UIImage? = nil
        let duration = asset.duration.seconds.isFinite ? asset.duration.seconds : 0
        
        let metadata = asset.commonMetadata
        for item in metadata {
            guard let commonKey = item.commonKey else { continue }
            switch commonKey {
            case .commonKeyTitle:
                if let str = item.stringValue, !str.isEmpty { title = str }
            case .commonKeyArtist:
                if let str = item.stringValue, !str.isEmpty { artist = str }
            case .commonKeyAlbumName:
                if let str = item.stringValue, !str.isEmpty { album = str }
            case .commonKeyArtwork:
                if let data = item.dataValue, let img = UIImage(data: data) { artwork = img }
            default:
                break
            }
        }
        
        return Track(
            title: title,
            artist: artist,
            album: album,
            duration: duration,
            fileURL: url,
            artwork: artwork
        )
    }
    
    private func rebuildLibraryIndex() {
        var albMap: [String: [Track]] = [:]
        var artMap: [String: [Track]] = [:]
        
        for track in tracks {
            albMap[track.album, default: []].append(track)
            artMap[track.artist, default: []].append(track)
        }
        
        self.albums = albMap
        self.artists = artMap
    }
    
    private func loadDefaultDemoTracks() {
        let demo1 = Track(
            title: "Midnight City",
            artist: "M83",
            album: "Hurry Up, We're Dreaming",
            duration: 243,
            artwork: createPlaceholderArtwork(text: "M83", hue: 0.6)
        )
        let demo2 = Track(
            title: "Starboy",
            artist: "The Weeknd ft. Daft Punk",
            album: "Starboy",
            duration: 230,
            artwork: createPlaceholderArtwork(text: "XO", hue: 0.95)
        )
        let demo3 = Track(
            title: "Blinding Lights",
            artist: "The Weeknd",
            album: "After Hours",
            duration: 200,
            artwork: createPlaceholderArtwork(text: "AH", hue: 0.05)
        )
        let demo4 = Track(
            title: "Get Lucky",
            artist: "Daft Punk ft. Pharrell Williams",
            album: "Random Access Memories",
            duration: 248,
            artwork: createPlaceholderArtwork(text: "DP", hue: 0.12)
        )
        
        self.tracks = [demo1, demo2, demo3, demo4]
        rebuildLibraryIndex()
    }
    
    private func createPlaceholderArtwork(text: String, hue: CGFloat) -> UIImage? {
        let size = CGSize(width: 300, height: 300)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let color = UIColor(hue: hue, saturation: 0.75, brightness: 0.85, alpha: 1.0)
            color.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 72, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            let string = NSAttributedString(string: text, attributes: attributes)
            let stringSize = string.size()
            let rect = CGRect(
                x: (size.width - stringSize.width) / 2,
                y: (size.height - stringSize.height) / 2,
                width: stringSize.width,
                height: stringSize.height
            )
            string.draw(in: rect)
        }
    }
}
