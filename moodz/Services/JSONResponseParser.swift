import Foundation
import MusicKit

class JSONResponseParser {
    static func extractAndParseSongs(from aiResponse: String) -> [AISongResponse] {
        guard let jsonString = extractJSONFromResponse(aiResponse) else {
            print("No JSON found in response")
            return []
        }
        
        return parseSongsFromJSON(jsonString)
    }
    
    private static func extractJSONFromResponse(_ response: String) -> String? {
        // Try to find JSON array pattern
        let pattern = #"\[[\s\S]*?\]"#
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(location: 0, length: response.utf16.count)
            
            if let match = regex.firstMatch(in: response, options: [], range: range) {
                let jsonRange = Range(match.range, in: response)!
                return String(response[jsonRange])
            }
        } catch {
            print("Regex error: \(error)")
        }
        
        // If array pattern not found, try to find JSON object pattern
        let objectPattern = #"\{[\s\S]*?\}"#
        do {
            let regex = try NSRegularExpression(pattern: objectPattern, options: [])
            let range = NSRange(location: 0, length: response.utf16.count)
            
            if let match = regex.firstMatch(in: response, options: [], range: range) {
                let jsonRange = Range(match.range, in: response)!
                let objectJson = String(response[jsonRange])
                // Wrap single object in an array
                return "[\(objectJson)]"
            }
        } catch {
            print("Regex error for object pattern: \(error)")
        }
        
        return nil
    }
    
    private static func parseSongsFromJSON(_ jsonString: String) -> [AISongResponse] {
        guard let data = jsonString.data(using: .utf8) else {
            print("Failed to convert JSON string to data")
            return []
        }
        
        do {
            let songs = try JSONDecoder().decode([AISongResponse].self, from: data)
            return songs
        } catch {
            print("JSON parsing error: \(error)")
            
            // Try to fix common JSON issues
            let fixedJSON = fixCommonJSONIssues(jsonString)
            if let fixedData = fixedJSON.data(using: .utf8) {
                do {
                    let songs = try JSONDecoder().decode([AISongResponse].self, from: fixedData)
                    return songs
                } catch {
                    print("Even fixed JSON failed: \(error)")
                    
                    // Print the JSON for debugging
                    print("JSON content: \(fixedJSON)")
                }
            }
            
            return []
        }
    }
    
    private static func fixCommonJSONIssues(_ jsonString: String) -> String {
        var fixed = jsonString
        
        // Fix trailing commas
        fixed = fixed.replacingOccurrences(of: ",\\s*}", with: "}", options: .regularExpression)
        fixed = fixed.replacingOccurrences(of: ",\\s*]", with: "]", options: .regularExpression)
        
        // Ensure proper array closing
        if !fixed.hasSuffix("]") {
            let lastBraceIndex = fixed.lastIndex(of: "}")
            if let index = lastBraceIndex {
                fixed = String(fixed[...index]) + "]"
            }
        }
        
        // Ensure proper quotes around keys
        fixed = fixed.replacingOccurrences(of: "([{,])\\s*([a-zA-Z0-9_]+)\\s*:", with: "$1\"$2\":", options: .regularExpression)
        
        return fixed
    }
}
