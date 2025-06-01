import Foundation
import MusicKit

struct SongItem: Identifiable {
    let id: MusicItemID
    let title: String
    let artist: String
    let artworkURL: URL?
    let previewURL: URL?
    var isPlaying: Bool = false
}
