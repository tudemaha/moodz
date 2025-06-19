import Foundation
import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

class AIManager {
    private let apiKey : String
    private let baseURL = "https://api.openai.com/v1"
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func sendPrompt(_ prompt: String) async throws -> String {
        let endpoint = "/chat/completions" // OpenAI Chat Completions API
        
        guard let url = URL(string: baseURL + endpoint) else {
            throw NSError(domain: "Invalid URL", code: 0)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini", // OpenAI model
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
    
    func analyzeImage(_ image: UIImage) async throws -> (isHuman: String, place: String) {
        let endpoint = "/chat/completions"
        
        guard let url = URL(string: baseURL + endpoint) else {
            throw NSError(domain: "Invalid URL", code: 0)
        }
        
        guard let base64Image = image.jpegData(compressionQuality: 0.5)?.base64EncodedString() else {
            throw NSError(domain: "Failed to encode image", code: 0)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        // Create the prompt for image analysis
        let imagePrompt = "Analyze this image and provide the following information in JSON format: 1) Is there a person in the photo? (yes/no) 2) What is the location/place shown in the photo? Return ONLY a valid JSON object with two keys: 'isHuman' (string with 'yes' or 'no') and 'place' (string with location name). Be specific about the place."
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o-nano",  // OpenAI GPT-4o with vision capabilities
            "messages": [
                ["role": "user", "content": [
                    ["type": "text", "text": imagePrompt],
                    ["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(base64Image)"]]
                ]]
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
            
            // Parse the JSON response
            if let jsonData = content.data(using: .utf8),
               let jsonObject = try? JSONSerialization.jsonObject(with: jsonData) as? [String: String],
               let isHuman = jsonObject["isHuman"],
               let place = jsonObject["place"] {
                
                // Format the human detection result
                let humanResult = isHuman.lowercased() == "yes" ? "There is person in the photo" : "There is no person in the photo"
                
                return (humanResult, place)
            }
            
            throw NSError(domain: "Failed to parse JSON response", code: 0)
        }
        
        throw NSError(domain: "Invalid Response Format", code: 0)
    }
}

struct Config {
    static var openAIAPIKey: String {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String,
              !apiKey.isEmpty else {
            fatalError("OpenAI API Key not found in build configuration. Make sure Config.xcconfig is properly set up.")
        }
        return apiKey
    }
}
