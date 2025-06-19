import Foundation
import UIKit
import MusicKit

// MARK: - Result Page State Model
struct ResultPageState {
    let customPrompt: String?
    let selectedImage: UIImage?
    let imageDisplayInfo: ImageDisplayInfo?
    
    init(customPrompt: String?, selectedImage: UIImage?) {
        self.customPrompt = customPrompt
        self.selectedImage = selectedImage
        self.imageDisplayInfo = selectedImage != nil ? ImageDisplayInfo(image: selectedImage!) : nil
    }
}

// MARK: - Copy Button State Model
struct CopyButtonState {
    let text: String
    let isTemporary: Bool
    
    static let `default` = CopyButtonState(text: "Copy to clipboard", isTemporary: false)
    static let copied = CopyButtonState(text: "Copied!", isTemporary: true)
}

// MARK: - Audio Session State Model
struct AudioSessionState {
    let isAnyPlaying: Bool
    let currentlyPlayingSongId: MusicItemID?
    
    init(songItems: [SongItem]) {
        let playingSong = songItems.first { $0.isPlaying }
        self.isAnyPlaying = playingSong != nil
        self.currentlyPlayingSongId = playingSong?.id
    }
} 