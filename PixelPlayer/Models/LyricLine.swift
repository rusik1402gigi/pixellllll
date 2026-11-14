import Foundation

public struct LyricLine: Identifiable, Equatable {
    public let id: UUID
    public let timestamp: TimeInterval
    public let text: String
    
    public init(id: UUID = UUID(), timestamp: TimeInterval, text: String) {
        self.id = id
        self.timestamp = timestamp
        self.text = text
    }
}
