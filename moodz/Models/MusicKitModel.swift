import Foundation
import MusicKit

// This is your existing model that will be used throughout the app
struct SongItem: Identifiable {
    let id: MusicItemID
    let title: String
    let artist: String
    let artworkURL: URL?
    let previewURL: URL?
    var isPlaying: Bool = false
}

// This is a new model specifically for parsing the AI response
struct AISongResponse: Codable, Identifiable {
    // Add an id property to conform to Identifiable
    var id: UUID = UUID()
    
    let title: String
    let artist: String
    var isPlaying: Bool = false
    
    // Optional fields that might be in some AI responses
    let artworkURL: URL?
    let previewURL: URL?
    
    // CodingKeys to handle potential variations in JSON field names
    enum CodingKeys: String, CodingKey {
        case title
        case artist
        case artworkURL = "artwork_url"
        case previewURL = "preview_url"
    }
}
