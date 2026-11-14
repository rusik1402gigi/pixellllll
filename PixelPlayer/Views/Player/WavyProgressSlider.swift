import SwiftUI

public struct WavyProgressSlider: View {
    @Binding public var value: Double // Current position (seconds)
    public let range: ClosedRange<Double> // 0 ... duration
    public let isPlaying: Bool
    public let activeColor: Color
    public let inactiveColor: Color
    public let onSeek: (Double) -> Void
    
    @State private var isDragging: Bool = false
    @State private var dragProgress: Double = 0
    @State private var wavePhase: Double = 0
    
    // Wave parameters matching PixelPlayer Expressive design
    private let waveAmplitude: CGFloat = 3.5
    private let waveLength: CGFloat = 60.0
    private let trackHeight: CGFloat = 5.0
    
    public init(
        value: Binding<Double>,
        range: ClosedRange<Double>,
        isPlaying: Bool,
        activeColor: Color = .white,
        inactiveColor: Color = Color.white.opacity(0.25),
        onSeek: @escaping (Double) -> Void
    ) {
        self._value = value
        self.range = range
        self.isPlaying = isPlaying
        self.activeColor = activeColor
        self.inactiveColor = inactiveColor
        self.onSeek = onSeek
    }
    
    private var totalDuration: Double {
        max(1.0, range.upperBound - range.lowerBound)
    }
    
    private var normalizedProgress: Double {
        if isDragging {
            return dragProgress
        }
        let val = (value - range.lowerBound) / totalDuration
        return min(max(val, 0.0), 1.0)
    }
    
    public var body: some View {
        TimelineView(.animation(paused: !isPlaying || isDragging)) { timeline in
            GeometryReader { geometry in
                let width = geometry.size.width
                let height = geometry.size.height
                let centerY = height / 2
                let progressX = width * CGFloat(normalizedProgress)
                
                ZStack(alignment: .leading) {
                    // 1. Inactive Track (flat bar behind/ahead)
                    Capsule()
                        .fill(inactiveColor)
                        .frame(width: width, height: trackHeight)
                        .position(x: width / 2, y: centerY)
                    
                    // 2. Active Track (Sine Wave or Flat when scrubbing/paused)
                    Canvas { context, size in
                        var path = Path()
                        path.move(to: CGPoint(x: 0, y: centerY))
                        
                        let currentAmp = (isPlaying && !isDragging) ? waveAmplitude : 0
                        let phase = wavePhase
                        
                        let step: CGFloat = 2.0
                        var x: CGFloat = 0
                        while x <= progressX {
                            let y = centerY + sin((x / waveLength) * 2 * .pi + phase) * currentAmp
                            path.addLine(to: CGPoint(x: x, y: y))
                            x += step
                        }
                        
                        context.stroke(
                            path,
                            with: .color(activeColor),
                            style: StrokeStyle(lineWidth: trackHeight, lineCap: .round, lineJoin: .round)
                        )
                    }
                    .onChange(of: timeline.date) { _ in
                        if isPlaying && !isDragging {
                            wavePhase += 0.08
                            if wavePhase > 2 * .pi {
                                wavePhase -= 2 * .pi
                            }
                        }
                    }
                    
                    // 3. Thumb (Morphing from circle to rounded pill when scrubbing)
                    RoundedRectangle(cornerRadius: isDragging ? 4 : 8, style: .continuous)
                        .fill(activeColor)
                        .frame(
                            width: isDragging ? 5 : 12,
                            height: isDragging ? 26 : 12
                        )
                        .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
                        .position(x: min(max(progressX, 6), width - 6), y: centerY)
                        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isDragging)
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { gesture in
                            if !isDragging {
                                isDragging = true
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                            }
                            let locationX = gesture.location.x
                            let newProg = min(max(locationX / width, 0.0), 1.0)
                            dragProgress = Double(newProg)
                        }
                        .onEnded { gesture in
                            isDragging = false
                            let finalTarget = range.lowerBound + dragProgress * totalDuration
                            onSeek(finalTarget)
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                        }
                )
            }
        }
        .frame(height: 36)
    }
}
