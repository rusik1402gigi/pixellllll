import Foundation

public struct LrcLibResponseDTO: Codable {
    public let id: Int?
    public let name: String?
    public let artistName: String?
    public let albumName: String?
    public let duration: Double?
    public let plainLyrics: String?
    public let syncedLyrics: String?
}

public class LrcLyricsService: ObservableObject {
    public static let shared = LrcLyricsService()
    
    @Published public var currentLyrics: [LyricLine] = []
    @Published public var plainTextLyrics: String? = nil
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil
    
    private let urlSession = URLSession.shared
    
    public init() {}
    
    public func fetchLyrics(for track: Track) {
        isLoading = true
        errorMessage = nil
        currentLyrics = []
        plainTextLyrics = nil
        
        guard !track.title.isEmpty else {
            isLoading = false
            return
        }
        
        var components = URLComponents(string: "https://lrclib.net/api/get")
        var queryItems = [
            URLQueryItem(name: "track_name", value: track.title),
            URLQueryItem(name: "artist_name", value: track.artist)
        ]
        if !track.album.isEmpty && track.album != "Unknown Album" {
            queryItems.append(URLQueryItem(name: "album_name", value: track.album))
        }
        if track.duration > 0 {
            queryItems.append(URLQueryItem(name: "duration", value: String(Int(track.duration))))
        }
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            fallbackSearch(query: "\(track.title) \(track.artist)")
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("PixelPlayer-iOS/1.0 (https://github.com/PixelPlayerHQ/PixelPlayer)", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 10
        
        urlSession.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data {
                if let dto = try? JSONDecoder().decode(LrcLibResponseDTO.self, from: data) {
                    self.handleLrcResponse(dto)
                    return
                }
            }
            
            // If direct get fails, perform fallback search query
            self.fallbackSearch(query: "\(track.title) \(track.artist)")
        }.resume()
    }
    
    private func fallbackSearch(query: String) {
        guard var components = URLComponents(string: "https://lrclib.net/api/search") else {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Unable to create search URL"
            }
            return
        }
        
        components.queryItems = [URLQueryItem(name: "q", value: query)]
        guard let url = components.url else { return }
        
        var request = URLRequest(url: url)
        request.setValue("PixelPlayer-iOS/1.0", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 10
        
        urlSession.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
            }
            
            guard let data = data,
                  let results = try? JSONDecoder().decode([LrcLibResponseDTO].self, from: data),
                  let first = results.first else {
                DispatchQueue.main.async {
                    self.errorMessage = "No lyrics found"
                }
                return
            }
            
            self.handleLrcResponse(first)
        }.resume()
    }
    
    private func handleLrcResponse(_ dto: LrcLibResponseDTO) {
        DispatchQueue.main.async {
            self.isLoading = false
            if let synced = dto.syncedLyrics, !synced.isEmpty {
                self.currentLyrics = self.parseLrcString(synced)
            } else if let plain = dto.plainLyrics, !plain.isEmpty {
                self.plainTextLyrics = plain
                self.currentLyrics = self.parsePlainString(plain)
            } else {
                self.errorMessage = "No lyrics available for this track"
            }
        }
    }
    
    public func parseLrcString(_ lrc: String) -> [LyricLine] {
        var lines: [LyricLine] = []
        let rawLines = lrc.components(separatedBy: .newlines)
        
        let pattern = "\\[(\\d{2}):(\\d{2})(?:[\\.:](\\d{2,3}))?\\](.*)"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return []
        }
        
        for rawLine in rawLines {
            let trimmed = rawLine.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }
            
            let range = NSRange(location: 0, length: trimmed.utf16.count)
            if let match = regex.firstMatch(in: trimmed, options: [], range: range) {
                guard let minRange = Range(match.range(at: 1), in: trimmed),
                      let secRange = Range(match.range(at: 2), in: trimmed) else {
                    continue
                }
                
                let min = Double(trimmed[minRange]) ?? 0
                let sec = Double(trimmed[secRange]) ?? 0
                var ms = 0.0
                
                if match.range(at: 3).location != NSNotFound,
                   let msRange = Range(match.range(at: 3), in: trimmed) {
                    let msStr = String(trimmed[msRange])
                    if msStr.count == 2 {
                        ms = (Double(msStr) ?? 0) / 100.0
                    } else {
                        ms = (Double(msStr) ?? 0) / 1000.0
                    }
                }
                
                let text: String
                if match.range(at: 4).location != NSNotFound,
                   let textRange = Range(match.range(at: 4), in: trimmed) {
                    text = String(trimmed[textRange]).trimmingCharacters(in: .whitespaces)
                } else {
                    text = ""
                }
                
                let timestamp = min * 60.0 + sec + ms
                lines.append(LyricLine(timestamp: timestamp, text: text))
            }
        }
        
        return lines.sorted { $0.timestamp < $1.timestamp }
    }
    
    private func parsePlainString(_ plain: String) -> [LyricLine] {
        let rawLines = plain.components(separatedBy: .newlines)
        var result: [LyricLine] = []
        var dummyTime: TimeInterval = 0
        for line in rawLines {
            let t = line.trimmingCharacters(in: .whitespaces)
            if !t.isEmpty {
                result.append(LyricLine(timestamp: dummyTime, text: t))
                dummyTime += 3.0
            }
        }
        return result
    }
}
