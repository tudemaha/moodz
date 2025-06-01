import Foundation
import AVKit

class MusicPlayerController {
    private var player: AVPlayer?
    
    //    used to play audio even in silent mode
    init() {
        configureAudioSession()
    }
    
    func playPreview(for song: SongItem) {
        guard let url = song.previewURL else {
            print("No preview URL available.")
            return
        }
        player = AVPlayer(url: url)
        player?.play()
    }
    
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error: \(error)")
        }
    }
}
