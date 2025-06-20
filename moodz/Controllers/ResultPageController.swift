import Foundation
import SwiftUI
import MusicKit
import Combine

@MainActor
class ResultPageController: ObservableObject {
    
    // MARK: - Published Properties
    @Published var selectedIndex: MusicItemID?
    @Published var copyButtonState = CopyButtonState.default
    @Published var resultPageState: ResultPageState
    
    // MARK: - Injected PromptController (No longer creating new instance)
    private let promptController: PromptController
    
    // MARK: - Reactive Published Properties (Forwarded from PromptController)
    @Published var songItems: [SongItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private var copyButtonTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    var imageDisplayInfo: ImageDisplayInfo? {
        resultPageState.imageDisplayInfo
    }
    
    var customPrompt: String? {
        resultPageState.customPrompt
    }
    
    var selectedImage: UIImage? {
        resultPageState.selectedImage
    }
    
    var hasSongs: Bool {
        !songItems.isEmpty
    }
    
    var remainingGenerations: Int {
        promptController.remainingGenerations
    }
    
    // MARK: - Initialization (Updated with Dependency Injection)
    init(customPrompt: String?, selectedImage: UIImage?, promptController: PromptController) {
        self.promptController = promptController
        self.resultPageState = ResultPageState(
            customPrompt: customPrompt,
            selectedImage: selectedImage
        )
        
        // Set up reactive bindings to promptController
        setupBindings()
    }
    
    // MARK: - Reactive Bindings Setup
    private func setupBindings() {
        // Bind songItems from promptController to local published property
        promptController.$songItems
            .receive(on: DispatchQueue.main)
            .assign(to: \.songItems, on: self)
            .store(in: &cancellables)
        
        // Bind isLoading from promptController to local published property
        promptController.$isLoading
            .receive(on: DispatchQueue.main)
            .assign(to: \.isLoading, on: self)
            .store(in: &cancellables)
        
        // Bind errorMessage from promptController to local published property
        promptController.$errorMessage
            .receive(on: DispatchQueue.main)
            .assign(to: \.errorMessage, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Lifecycle Methods
    func viewDidAppear() {
        // Auto-start song generation if needed
        if songItems.isEmpty && !isLoading {
            if let customPrompt = customPrompt {
                promptController.prompt = customPrompt
            }
            promptController.sendPrompt()
        }
    }
    
    func viewWillDisappear() {
        stopAllPlayingSongs()
    }
    
    // MARK: - Audio Control Methods
    func stopAllPlayingSongs() {
        // Find any playing song and toggle it off
        for song in songItems {
            if song.isPlaying {
                promptController.togglePlayback(for: song)
                break
            }
        }
    }
    
    func togglePlayback(for song: SongItem) {
        promptController.togglePlayback(for: song)
    }
    
    // MARK: - Song Generation Methods
    func generateOtherSongs() {
        // Check limit before generating
        guard UserPreferencesManager.shared.canGenerateToday() else {
            Task { @MainActor in
                // Show alert through the promptController
                promptController.limitAlertMessage = "Daily limit reached! You can generate \(UserPreferencesManager.shared.dailyGenerationLimit) songs per day. Try again tomorrow!"
                promptController.showLimitAlert = true
            }
            return
        }
        
        if let customPrompt = customPrompt {
            // ✅ Create prompt with current songs excluded
            let modifiedPrompt = createPromptWithExclusions(from: customPrompt)
            promptController.prompt = modifiedPrompt
        }
        promptController.sendPrompt()
    }
    
    // ✅ NEW: Create prompt that excludes currently displayed songs
    private func createPromptWithExclusions(from originalPrompt: String) -> String {
        // Get current songs to exclude
        let currentSongs = getCurrentSongsForExclusion()
        
        var modifiedPrompt = originalPrompt
        
        // Find and replace the generation instruction
        if let range = modifiedPrompt.range(of: ", generate a list of 5 most suitable viral song recommendations") {
            // Remove the original ending
            modifiedPrompt = String(modifiedPrompt[..<range.lowerBound])
            
            // Add exclusion list if we have songs
            if !currentSongs.isEmpty {
                modifiedPrompt += ". IMPORTANT: Do NOT suggest any of these songs that were already recommended: \(currentSongs)"
            }
            
            // Add the new generation instruction
            modifiedPrompt += ", generate a list of 5 COMPLETELY DIFFERENT song recommendations while maintaining the same emotional vibe"
        }
        
        // Add the JSON format instruction
        modifiedPrompt += ". Your response MUST be ONLY a valid JSON array containing exactly 5 objects. Each object in the array must have two string properties: 'title' and 'artist'. Do not include any explanations, introductory text, or any characters outside of this JSON array."
        
        return modifiedPrompt
    }
    
    // ✅ NEW: Get current songs formatted for exclusion
    private func getCurrentSongsForExclusion() -> String {
        let songDescriptions = songItems.map { "\"\($0.title)\" by \($0.artist)" }
        return songDescriptions.joined(separator: ", ")
    }
    
    // MARK: - Clipboard Methods
    func copyToClipboard(_ id: MusicItemID) {
        if let currentSong = songItems.first(where: { $0.id == id }) {
            UIPasteboard.general.string = "\(currentSong.artist) - \(currentSong.title)"
            
            // Update button state
            copyButtonState = CopyButtonState.copied
            
            // Reset after delay
            copyButtonTimer?.invalidate()
            copyButtonTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
                Task { @MainActor in
                    self.copyButtonState = CopyButtonState.default
                }
            }
        }
    }
    
    // MARK: - Navigation Methods
    func navigateBackWithAudioStop() {
        stopAllPlayingSongs()
    }
    
    // MARK: - Cleanup
    deinit {
        copyButtonTimer?.invalidate()
        cancellables.removeAll()
    }
} 
 