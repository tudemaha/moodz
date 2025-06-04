import Foundation
import Combine
import MusicKit
import AVFoundation

@MainActor
class PromptController: ObservableObject {
    @Published var prompt: String = ""
    @Published var response: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var songs: [AISongResponse] = []
    @Published var songItems: [SongItem] = []
 
    private let aiManager: AIManager
    private var cancellables = Set<AnyCancellable>()
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    
    init(aiManager: AIManager = AIManager(apiKey: Config.deepSeekAPIKey)) {
        self.aiManager = aiManager
    }
    
    // MARK: - Public Methods
    func sendPrompt() {
        let promptRequest = PromptRequest(text: prompt)
        
        guard promptRequest.isValid else {
            errorMessage = "Please enter a valid prompt"
            return
        }
        
        Task {
            await performPromptRequest(promptRequest)
        }
    }
    
    func clearResponse() {
        response = ""
        errorMessage = nil
    }
    
    func clearAll() {
        prompt = ""
        response = ""
        errorMessage = nil
    }
    
    func togglePlayback(for song: SongItem) {
        // Find the song in the array
        if let index = songItems.firstIndex(where: { $0.id == song.id }) {
            // If this song is already playing, stop it
            if songItems[index].isPlaying {
                stopPlayback()
            } else {
                // Stop any currently playing song
                stopPlayback()
                
                // Start playing this song
                playPreview(for: index)
            }
        }
    }
    
    // MARK: - Private Methods
    private func performPromptRequest(_ request: PromptRequest) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await aiManager.sendPrompt(request.text)
            let promptResponse = PromptResponse(text: result)
            response = promptResponse.text
            
            // Parse songs from the response
            songs = JSONResponseParser.extractAndParseSongs(from: result)
            
            // Search for these songs in Apple Music
            await searchSongsInAppleMusic()
            
        } catch {
            errorMessage = handleError(error)
        }
        
        isLoading = false
    }
    
    private func searchSongsInAppleMusic() async {
        var items: [SongItem] = []
        
        print("Searching for \(songs.count) songs in Apple Music")
        
        for song in songs {
            do {
                print("Searching for: \(song.title) by \(song.artist)")
                
                // Check authorization status
                let status = await MusicAuthorization.request()
                guard status == .authorized else {
                    print("MusicKit not authorized")
                    continue
                }
                
                // Search for the song in Apple Music
                let searchTerm = "\(song.title) \(song.artist)"
                var request = MusicCatalogSearchRequest(term: searchTerm, types: [MusicKit.Song.self])
                request.limit = 1
                
                let response = try await request.response()
                
                if let firstSong = response.songs.first {
                    print("Found match: \(firstSong.title) by \(firstSong.artistName)")
                    
                    let songItem = SongItem(
                        id: firstSong.id,
                        title: firstSong.title,
                        artist: firstSong.artistName,
                        artworkURL: firstSong.artwork?.url(width: 200, height: 200),
                        previewURL: firstSong.previewAssets?.first?.url,
                        isPlaying: false
                    )
                    
                    // Print debug info about artwork and preview
                    print("Artwork URL: \(String(describing: songItem.artworkURL))")
                    print("Preview URL: \(String(describing: songItem.previewURL))")
                    
                    items.append(songItem)
                } else {
                    print("No matches found in Apple Music")
                }
            } catch {
                print("Failed to search for song: \(song.title) - \(error)")
            }
        }
        
        // Update the songItems property
        print("Found \(items.count) matches in Apple Music")
        songItems = items
    }
    
    private func handleError(_ error: Error) -> String {
        // Add specific error handling logic here
        let errorDescription = error.localizedDescription
        
        if errorDescription.contains("Invalid URL") {
            return "Configuration error. Please check the API settings."
        } else if errorDescription.contains("API Request Failed") {
            return "API request failed. Please check your API key and try again."
        } else if errorDescription.contains("Invalid Response Format") {
            return "Received invalid response from the server."
        } else if errorDescription.contains("network") || errorDescription.contains("Internet") {
            return "Network error. Please check your connection."
        } else {
            return "An error occurred: \(errorDescription)"
        }
    }
    
    private func playPreview(for index: Int) {
        guard index < songItems.count, let url = songItems[index].previewURL else {
            return
        }
        
        // Update isPlaying state
        for i in 0..<songItems.count {
            songItems[i].isPlaying = (i == index)
        }
        
        // Create and play audio
        playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        // Add observer for playback end
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )
        
        player?.play()
    }
    
    private func stopPlayback() {
        // Reset isPlaying state for all songs
        for i in 0..<songItems.count {
            songItems[i].isPlaying = false
        }
        
        // Stop playback
        player?.pause()
        if let playerItem = playerItem {
            NotificationCenter.default.removeObserver(
                self,
                name: .AVPlayerItemDidPlayToEndTime,
                object: playerItem
            )
        }
        player?.replaceCurrentItem(with: nil)
        playerItem = nil
    }
    
    @objc private func playerDidFinishPlaying() {
        Task { @MainActor in
            stopPlayback()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        
        // Fix: Use Task to call stopPlayback() on the main actor
        Task { @MainActor [weak self] in
            // Use weak self to avoid retain cycles
            self?.stopPlayback()
        }
        
        // We can still clean up cancellables synchronously
        cancellables.removeAll()
    }
}
