import Foundation

struct PromptRequest {
    let text: String
    
    var isValid: Bool {
        return !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

struct PromptResponse {
    let text: String
    let timestamp: Date
    
    init(text: String) {
        self.text = text
        self.timestamp = Date()
    }
}

struct SongResponse: Codable, Identifiable {
    let id = UUID()
    let title: String
    let artist: String
    let album: String?
    let year: Int?
    let genre: String?
    
    enum CodingKeys: String, CodingKey {
        case title, artist, album, year, genre
    }
}
