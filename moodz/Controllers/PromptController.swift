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
    
    // MARK: - Generation Limit Properties
    @Published var remainingGenerations: Int = UserPreferencesManager.shared.remainingGenerations
    @Published var showLimitAlert: Bool = false
    @Published var limitAlertMessage: String = ""
 
    private let aiManager: AIManager
    private var cancellables = Set<AnyCancellable>()
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    
    init(aiManager: AIManager = AIManager(apiKey: Config.openAIAPIKey)) {
        self.aiManager = aiManager
        updateRemainingGenerations()
    }
    
    // MARK: - Developer Methods (only in DEBUG)
    #if DEBUG
    /// Developer-only method to send prompts without consuming daily limit
    func sendPromptDeveloperMode() {
        let promptRequest = PromptRequest(text: prompt)
        
        guard promptRequest.isValid else {
            Task { @MainActor in
                errorMessage = "Please enter a valid prompt"
            }
            return
        }
        
        Task {
            await performPromptRequestWithoutLimitCheck(promptRequest)
        }
    }
    
    private func performPromptRequestWithoutLimitCheck(_ request: PromptRequest) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let result = try await aiManager.sendPrompt(request.text)
            let promptResponse = PromptResponse(text: result)
            
            await MainActor.run {
                response = promptResponse.text
            }
            
            // Parse songs from the response
            let parsedSongs = JSONResponseParser.extractAndParseSongs(from: result)
            
            await MainActor.run {
                songs = parsedSongs
            }
            
            // Search for these songs in Apple Music
            await searchSongsInAppleMusic()
            
            // ✅ Skip incrementing generation count for developer mode
            
        } catch {
            await MainActor.run {
                errorMessage = handleError(error)
            }
        }
        
        await MainActor.run {
            isLoading = false
        }
    }
    #endif
    
    // MARK: - Public Methods
    func sendPrompt() {
        let promptRequest = PromptRequest(text: prompt)
        
        guard promptRequest.isValid else {
            Task { @MainActor in
                errorMessage = "Please enter a valid prompt"
            }
            return
        }
        
        // Check generation limit
        guard UserPreferencesManager.shared.canGenerateToday() else {
            Task { @MainActor in
                showLimitReachedAlert()
            }
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
    private func showLimitReachedAlert() {
        limitAlertMessage = "Daily limit reached! You can generate \(UserPreferencesManager.shared.dailyGenerationLimit) songs per day. Try again tomorrow!"
        showLimitAlert = true
    }
    
    private func updateRemainingGenerations() {
        remainingGenerations = UserPreferencesManager.shared.remainingGenerations
    }
    
    private func performPromptRequest(_ request: PromptRequest) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let result = try await aiManager.sendPrompt(request.text)
            let promptResponse = PromptResponse(text: result)
            
            await MainActor.run {
                response = promptResponse.text
            }
            
            // Parse songs from the response
            let parsedSongs = JSONResponseParser.extractAndParseSongs(from: result)
            
            await MainActor.run {
                songs = parsedSongs
            }
            
            // Search for these songs in Apple Music
            await searchSongsInAppleMusic()
            
            // Increment generation count only on successful generation
            if !songs.isEmpty {
                let success = UserPreferencesManager.shared.incrementGenerationCount()
                if success {
                    await MainActor.run {
                        updateRemainingGenerations()
                    }
                }
            }
            
        } catch {
            await MainActor.run {
                errorMessage = handleError(error)
            }
        }
        
        await MainActor.run {
            isLoading = false
        }
    }
    
    private func searchSongsInAppleMusic() async {
        var items: [SongItem] = []
        
        for song in songs {
            do {
                // Search for the song in Apple Music
                let searchTerm = "\(song.title) \(song.artist)"
                var request = MusicCatalogSearchRequest(term: searchTerm, types: [MusicKit.Song.self])
                request.limit = 1
                
                let response = try await request.response()
                
                if let firstSong = response.songs.first {
                    let songItem = SongItem(
                        id: firstSong.id,
                        title: firstSong.title,
                        artist: firstSong.artistName,
                        artworkURL: firstSong.artwork?.url(width: 200, height: 200),
                        previewURL: firstSong.previewAssets?.first?.url,
                        isPlaying: false
                    )
                    
                    items.append(songItem)
                }
            } catch {
                // Handle error silently
            }
        }
        
        // Update the songItems property on main actor
        await MainActor.run {
            songItems = items
        }
    }
    
    private func handleError(_ error: Error) -> String {
        let errorDescription = error.localizedDescription
        
        if errorDescription.contains("Invalid URL") {
            return "Configuration error. Please check the API settings."
        } else if errorDescription.contains("API Request Failed") {
            return "API request failed. Please check your OpenAI API key and try again."
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
    
    func stopPlayback() {
        // Reset isPlaying state for all songs
        for i in 0..<songItems.count {
            songItems[i].isPlaying = false
        }
        
        // Stop playback immediately
        player?.pause()
        
        // Clean up observers
        if let playerItem = playerItem {
            NotificationCenter.default.removeObserver(
                self,
                name: .AVPlayerItemDidPlayToEndTime,
                object: playerItem
            )
        }
        
        // ✅ IMPROVED: More thorough cleanup
        player?.replaceCurrentItem(with: nil)
        player = nil
        playerItem = nil
    }
    
    @objc private func playerDidFinishPlaying() {
        Task { @MainActor in
            stopPlayback()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        
        Task { @MainActor [weak self] in
            self?.stopPlayback()
        }
        
        cancellables.removeAll()
    }
}
