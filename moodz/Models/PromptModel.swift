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


