import Foundation
class JSONResponseParser {
    static func extractAndParseSongs(from aiResponse: String) -> [Song] {
        guard let jsonString = extractJSONFromResponse(aiResponse) else {
            print("No JSON found in response")
            return []
        }
        
        return parseSongsFromJSON(jsonString)
    }
    
    private static func extractJSONFromResponse(_ response: String) -> String? {
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
        
        return nil
    }
    
    private static func parseSongsFromJSON(_ jsonString: String) -> [Song] {
        guard let data = jsonString.data(using: .utf8) else {
            print("Failed to convert JSON string to data")
            return []
        }
        
        do {
            let songs = try JSONDecoder().decode([Song].self, from: data)
            return songs
        } catch {
            print("JSON parsing error: \(error)")
            
            let fixedJSON = fixCommonJSONIssues(jsonString)
            if let fixedData = fixedJSON.data(using: .utf8) {
                do {
                    let songs = try JSONDecoder().decode([Song].self, from: fixedData)
                    return songs
                } catch {
                    print("Even fixed JSON failed: \(error)")
                }
            }
            
            return []
        }
    }
    
    private static func fixCommonJSONIssues(_ jsonString: String) -> String {
        var fixed = jsonString
        
        fixed = fixed.replacingOccurrences(of: ",\\s*}", with: "}", options: .regularExpression)
        fixed = fixed.replacingOccurrences(of: ",\\s*]", with: "]", options: .regularExpression)
        
        if !fixed.hasSuffix("]") {
            let lastBraceIndex = fixed.lastIndex(of: "}")
            if let index = lastBraceIndex {
                fixed = String(fixed[...index]) + "]"
            }
        }
        
        return fixed
    }
}
