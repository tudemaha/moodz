import Foundation
import UIKit

@MainActor
class PreviewPageController: ObservableObject {
    
    // MARK: - Published Properties
    @Published var selectedMood: String = "Happy"
    @Published var navigateToResults = false
    @Published var imageDisplayInfo: ImageDisplayInfo?
    
    // MARK: - Properties
    private let isHuman: String
    private let place: String
    
    // MARK: - Computed Properties
    var availableMoods: [String] {
        return [
    "Nostalgic",
    "Happy",
    "Sad",
    "Adventurous",
    "Dreamy",
    "Energetic",
    "Calm",
    "Romantic",
    "Urban"
]
    }
    
    var generatedPrompt: String {
        // Business logic moved from view (exact same logic)
        var prompt = "Given the detected vibes of the photo "
        
        // Add mood
        prompt += selectedMood.lowercased()
        
        if !isHuman.isEmpty {
            prompt += " and \(isHuman.lowercased())"
        }
        
        // Add place if provided
        if !place.isEmpty {
            prompt += " and location at \(place.lowercased())"
        }
        
        // Complete the prompt
        prompt += ", generate a list of 5 most suitable viral song recommendations. Your response MUST be ONLY a valid JSON array containing exactly 5 objects. Each object in the array must have two string properties: 'title' and 'artist'. Do not include any explanations, introductory text, or any characters outside of this JSON array."
        
        return prompt
    }
    
    // MARK: - Initialization
    init(selectedImage: UIImage?, isHuman: String, place: String) {
        self.isHuman = isHuman
        self.place = place
        
        // Process image if available (logic moved from view)
        if let image = selectedImage {
            self.imageDisplayInfo = ImageDisplayInfo(image: image)
        }
    }
    
    // MARK: - Business Logic Methods
    func selectMood(_ mood: String) {
        selectedMood = mood
    }
    
    func generateSongs() {
        navigateToResults = true
    }
    
    func resetNavigation() {
        navigateToResults = false
    }
} 
