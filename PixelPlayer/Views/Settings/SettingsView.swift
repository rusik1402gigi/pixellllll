import SwiftUI

public struct SettingsView: View {
    @AppStorage("enableDynamicTheme") private var enableDynamicTheme: Bool = true
    @AppStorage("enableHaptics") private var enableHaptics: Bool = true
    @AppStorage("waveAmplitudeMultiplier") private var waveAmplitudeMultiplier: Double = 1.0
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color(red: 0.07, green: 0.08, blue: 0.11)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Settings")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        Text("PixelPlayer Expressive Configuration")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // Section: Appearance
                    VStack(alignment: .leading, spacing: 12) {
                        Text("APPEARANCE & THEME")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color(red: 0.4, green: 0.7, blue: 1.0))
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 0) {
                            Toggle(isOn: $enableDynamicTheme) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Dynamic Material Theme")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                    Text("Extract ambient colors from album artwork")
                                        .font(.system(size: 12))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                            }
                            .padding(16)
                            .tint(Color(red: 0.4, green: 0.7, blue: 1.0))
                            
                            Divider().background(Color.white.opacity(0.1))
                            
                            Toggle(isOn: $enableHaptics) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Expressive Haptics")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                    Text("Vibrate on scrubbing and button taps")
                                        .font(.system(size: 12))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                            }
                            .padding(16)
                            .tint(Color(red: 0.4, green: 0.7, blue: 1.0))
                        }
                        .background(Color.white.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .padding(.horizontal, 20)
                    }
                    
                    // Section: Lyrics & Online Services
                    VStack(alignment: .leading, spacing: 12) {
                        Text("SERVICES")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color(red: 0.4, green: 0.7, blue: 1.0))
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 0) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Lyrics Provider")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                    Text("LRCLIB (Community-driven synchronized lyrics)")
                                        .font(.system(size: 12))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                                Spacer()
                                Text("Active")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.green)
                            }
                            .padding(16)
                            
                            Divider().background(Color.white.opacity(0.1))
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Offline Cache")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                    Text("Automatic local storage of tracks and artwork")
                                        .font(.system(size: 12))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                                Spacer()
                                Text("Enabled")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .padding(16)
                        }
                        .background(Color.white.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .padding(.horizontal, 20)
                    }
                    
                    // Section: About
                    VStack(alignment: .leading, spacing: 12) {
                        Text("ABOUT")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color(red: 0.4, green: 0.7, blue: 1.0))
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 0) {
                            HStack {
                                Text("Version")
                                    .foregroundColor(.white)
                                Spacer()
                                Text("1.0.0 (Port for iOS)")
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .padding(16)
                            
                            Divider().background(Color.white.opacity(0.1))
                            
                            HStack {
                                Text("Based On")
                                    .foregroundColor(.white)
                                Spacer()
                                Text("PixelPlayerHQ / Android")
                                    .foregroundColor(Color(red: 0.4, green: 0.7, blue: 1.0))
                            }
                            .padding(16)
                        }
                        .background(Color.white.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 120)
            }
        }
    }
}
