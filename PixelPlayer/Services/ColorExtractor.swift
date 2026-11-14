import SwiftUI
import UIKit
import CoreImage

public class ColorExtractor {
    public static let shared = ColorExtractor()
    
    public struct Palette {
        public let background: Color
        public let surface: Color
        public let accent: Color
        public let primaryText: Color
        public let secondaryText: Color
        public let rawAverage: UIColor
        
        public static let fallback = Palette(
            background: Color(red: 0.08, green: 0.09, blue: 0.12),
            surface: Color(red: 0.14, green: 0.16, blue: 0.22),
            accent: Color(red: 0.40, green: 0.70, blue: 1.00),
            primaryText: .white,
            secondaryText: Color.white.opacity(0.7),
            rawAverage: UIColor(red: 0.08, green: 0.09, blue: 0.12, alpha: 1.0)
        )
    }
    
    public func extractPalette(from image: UIImage?) -> Palette {
        guard let image = image, let cgImage = image.cgImage else {
            return .fallback
        }
        
        let width = 32
        let height = 32
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var rawData = [UInt8](repeating: 0, count: width * height * 4)
        
        guard let context = CGContext(
            data: &rawData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        ) else {
            return .fallback
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        var totalR: Double = 0
        var totalG: Double = 0
        var totalB: Double = 0
        var count: Double = 0
        
        for i in stride(from: 0, to: rawData.count, by: 4) {
            let r = Double(rawData[i]) / 255.0
            let g = Double(rawData[i + 1]) / 255.0
            let b = Double(rawData[i + 2]) / 255.0
            let a = Double(rawData[i + 3]) / 255.0
            
            if a > 0.5 {
                totalR += r
                totalG += g
                totalB += b
                count += 1
            }
        }
        
        if count == 0 { return .fallback }
        
        let avgR = totalR / count
        let avgG = totalG / count
        let avgB = totalB / count
        
        // Deep background color (dark expressive Material 3 tone)
        let bgR = avgR * 0.25
        let bgG = avgG * 0.25
        let bgB = avgB * 0.25
        
        // Surface color (slightly lifted card color)
        let sfR = min(avgR * 0.45 + 0.05, 0.95)
        let sfG = min(avgG * 0.45 + 0.05, 0.95)
        let sfB = min(avgB * 0.45 + 0.05, 0.95)
        
        // Accent color (boosted vibrancy)
        let maxComponent = max(avgR, max(avgG, avgB))
        let boost = maxComponent > 0 ? (1.0 / maxComponent) * 0.85 : 1.0
        let acR = min(avgR * boost, 1.0)
        let acG = min(avgG * boost, 1.0)
        let acB = min(avgB * boost, 1.0)
        
        let background = Color(red: bgR, green: bgG, blue: bgB)
        let surface = Color(red: sfR, green: sfG, blue: sfB)
        let accent = Color(red: max(acR, 0.4), green: max(acG, 0.4), blue: max(acB, 0.4))
        
        return Palette(
            background: background,
            surface: surface,
            accent: accent,
            primaryText: .white,
            secondaryText: Color.white.opacity(0.72),
            rawAverage: UIColor(red: avgR, green: avgG, blue: avgB, alpha: 1.0)
        )
    }
}
