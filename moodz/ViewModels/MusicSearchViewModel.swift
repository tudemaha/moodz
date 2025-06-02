import Foundation
import MusicKit
import AVFoundation
import Combine

enum MusicSearchError: LocalizedError {
    case unauthorized
    case noPreviewAvailable
    case playbackFailed
    case searchFailed(Error)
    
    var errorDescription: String {
        switch self {
        case .unauthorized:
            return "Apple Music access not authorized. Please enable it in Settings."
        case .noPreviewAvailable:
            return "No preview available for this song."
        case .playbackFailed:
            return "Failed to play preview."
        case .searchFailed(let error):
            return "Search failed: \(error.localizedDescription)"
        }
    }
}

@MainActor
class MusicSearchViewModel: ObservableObject {
    @Published var searchTerm = ""
    @Published var results: [SongItem] = []
    @Published var isSearching = false
    @Published var error: MusicSearchError?
    @Published var currentlyPlayingSong: SongItem?
    @Published var promptResults: [Song] = []
    
    private var player: AVPlayer?
    private var cancellables = Set<AnyCancellable>()
    private var searchDebouncer: AnyCancellable?
    private var playerItem: AVPlayerItem?
    
    init() {
        configureAudioSession()
        setupSearchDebouncing()
        setupMusicKit()
    }
    
    private func setupSearchDebouncing() {
        searchDebouncer = $searchTerm
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] term in
                guard !term.isEmpty else {
                    self?.results = []
                    return
                }
                self?.search()
            }
    }
    
    private func setupMusicKit() {
        Task {
            do {
                try await MusicKitService.shared.configureMusicKit()
            } catch {
                print("MusicKit setup failed: \(error)")
                if let musicKitError = error as? MusicKitError {
                    switch musicKitError {
                    case .tokenFileNotFound:
                        self.error = .unauthorized
                    case .tokenExpired:
                        self.error = .unauthorized
                    case .tokenDecodingFailed:
                        self.error = .unauthorized
                    case .unauthorized:
                        self.error = .unauthorized
                    }
                }
            }
        }
    }
    
    func search() {
        Task {
            do {
                isSearching = true
                error = nil
                
                // First ensure we have authorization
                try await MusicKitService.shared.configureMusicKit()
                
                var request = MusicCatalogSearchRequest(
                    term: searchTerm,
                    types: [MusicKit.Song.self]
                )
                request.limit = 1
                
                let response = try await request.response()
                
                self.results = response.songs.map { song in
                    SongItem(
                        id: song.id,
                        title: song.title,
                        artist: song.artistName,
                        artworkURL: song.artwork?.url(width: 200, height: 200),
                        previewURL: song.previewAssets?.first?.url
                    )
                }
            } catch {
                print("Search failed: \(error)")
                if let musicError = error as? MusicKitError {
                    self.error = .unauthorized
                }
                self.results = []
            }
            isSearching = false
        }
    }
    
    func togglePlayback(for song: SongItem) {
        if currentlyPlayingSong == song {
            stopPlayback()
        } else {
            playPreview(for: song)
        }
    }
    
    func playPreview(for song: SongItem) {
        guard let url = song.previewURL else {
            error = .noPreviewAvailable
            return
        }
        
        // Stop current playback if any
        stopPlayback()
        
        // Create player item
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
        currentlyPlayingSong = song
    }
    
    func stopPlayback() {
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
        currentlyPlayingSong = nil
    }
    
    @objc private func playerDidFinishPlaying() {
        Task { @MainActor [weak self] in
            await self?.handlePlaybackFinished()
        }
    }
    
    private func handlePlaybackFinished() async {
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
        currentlyPlayingSong = nil
    }
    
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio Session Error: \(error)")
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        Task { @MainActor [weak self] in
            await self?.handlePlaybackFinished()
        }
        searchDebouncer?.cancel()
        cancellables.removeAll()
    }
} 
