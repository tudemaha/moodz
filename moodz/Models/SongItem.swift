import Foundation
import MusicKit

struct SongItem: Identifiable, Equatable {
    let id: MusicItemID
    let title: String
    let artist: String
    let artworkURL: URL?
    let previewURL: URL?
    
    static func == (lhs: SongItem, rhs: SongItem) -> Bool {
        lhs.id == rhs.id
    }
} 