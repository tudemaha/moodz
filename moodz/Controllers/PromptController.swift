
import Foundation
import Combine

@MainActor
class PromptController: ObservableObject {
    @Published var prompt: String = "Give me 5 Songs about love, return it only in json format"
    @Published var response: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var songs: [Song] = []
 
    private let aiManager: AIManager
    private var cancellables = Set<AnyCancellable>()
    
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
            
        } catch {
            errorMessage = handleError(error)
        }
        
        isLoading = false
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
}
