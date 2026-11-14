import Foundation
import UIKit

public struct Track: Identifiable, Equatable, Hashable {
    public let id: UUID
    public var title: String
    public var artist: String
    public var album: String
    public var duration: TimeInterval
    public var fileURL: URL?
    public var artwork: UIImage?
    public var isFavorite: Bool
    
    public init(
        id: UUID = UUID(),
        title: String,
        artist: String,
        album: String = "Unknown Album",
        duration: TimeInterval = 0,
        fileURL: URL? = nil,
        artwork: UIImage? = nil,
        isFavorite: Bool = false
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.album = album
        self.duration = duration
        self.fileURL = fileURL
        self.artwork = artwork
        self.isFavorite = isFavorite
    }
    
    public static func == (lhs: Track, rhs: Track) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
