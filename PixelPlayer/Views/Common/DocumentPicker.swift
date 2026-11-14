import SwiftUI
import UIKit
import UniformTypeIdentifiers

public struct DocumentPicker: UIViewControllerRepresentable {
    public let onPick: ([URL]) -> Void
    
    public init(onPick: @escaping ([URL]) -> Void) {
        self.onPick = onPick
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(onPick: onPick)
    }
    
    public func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let contentTypes: [UTType] = [
            .audio,
            .mp3,
            UTType(filenameExtension: "flac") ?? .audio,
            UTType(filenameExtension: "m4a") ?? .audio,
            UTType(filenameExtension: "wav") ?? .audio
        ]
        
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: contentTypes, asCopy: true)
        picker.allowsMultipleSelection = true
        picker.delegate = context.coordinator
        return picker
    }
    
    public func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    public class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onPick: ([URL]) -> Void
        
        init(onPick: @escaping ([URL]) -> Void) {
            self.onPick = onPick
        }
        
        public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            onPick(urls)
        }
    }
}
