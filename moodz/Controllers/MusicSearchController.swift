import Foundation
import MusicKit

@MainActor
class MusicSearchController: ObservableObject {
    @Published var searchTerm = ""
    @Published var results: [SongItem] = []

    func search() {
        Task {
            do {
                let status = await MusicAuthorization.request()
                guard status == .authorized else {
                    print("Apple Music access not authorized.")
                    return
                }
                
                var request = MusicCatalogSearchRequest(term: searchTerm, types: [Song.self])
                request.limit = 5
                
                let response = try await request.response()
                
                let songs = response.songs.map {
                    SongItem(
                        id: $0.id,
                        title: $0.title,
                        artist: $0.artistName,
                        artworkURL: $0.artwork?.url(width: 200, height: 200),
                        previewURL: $0.previewAssets?.first?.url
                    )
                }
                
                results = songs
            } catch {
                print("Search failed: \(error)")
            }
        }
        
    }

}

