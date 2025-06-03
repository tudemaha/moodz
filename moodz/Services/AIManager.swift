import Foundation

class AIManager {
    private let apiKey : String
    private let baseURL = "https://openrouter.ai/api/v1" // Replace with actual API endpoint
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func sendPrompt(_ prompt: String) async throws -> String {
        let endpoint = "/chat/completions" // Adjust based on DeepSeek's API
        
        guard let url = URL(string: baseURL + endpoint) else {
            throw NSError(domain: "Invalid URL", code: 0)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let requestBody: [String: Any] = [
            "model": "google/gemma-3n-e4b-it:free", // Adjust model as needed
            "messages": [
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NSError(domain: "API Request Failed", code: 0)
        }
        
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let choices = json["choices"] as? [[String: Any]],
           let firstChoice = choices.first,
           let message = firstChoice["message"] as? [String: Any],
           let content = message["content"] as? String {
            return content
        }
        
        throw NSError(domain: "Invalid Response Format", code: 0)
    }
}
struct Config {
    static var deepSeekAPIKey: String {
        guard let path = Bundle.main.path(forResource: "AI_API_Key", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let key = dict["api_key"] as? String else {
            fatalError("API Key not found in Key.plist or invalid format")
        }
        return key
    }
}
