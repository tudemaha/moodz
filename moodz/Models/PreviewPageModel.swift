import Foundation
import UIKit

// MARK: - Mood Selection Model
struct MoodSelection {
    let availableMoods: [String] = ["Chill", "Melancholy", "Sad", "Romantic", "Happy", "Dreamy"]
    let selectedMood: String
    
    init(selectedMood: String = "Melancholy") {
        self.selectedMood = selectedMood
    }
}

// MARK: - Image Display Model
struct ImageDisplayInfo {
    let image: UIImage
    let rotationAngle: Double
    let size: CGSize
    
    init(image: UIImage) {
        self.image = image
        
        // Detect orientation logic (moved from view)
        if image.size.width > image.size.height {
            // Landscape orientation
            self.rotationAngle = 0
            self.size = CGSize(width: 350, height: 250)
        } else {
            // Portrait orientation  
            self.rotationAngle = 0
            self.size = CGSize(width: 250, height: 350)
        }
    }
}

// MARK: - Preview Page State Model
struct PreviewPageState {
    let imageDisplayInfo: ImageDisplayInfo?
    let moodSelection: MoodSelection
    let isHuman: String
    let place: String
    var isNavigatingToResults: Bool = false
    
    init(selectedImage: UIImage?, isHuman: String, place: String) {
        self.imageDisplayInfo = selectedImage != nil ? ImageDisplayInfo(image: selectedImage!) : nil
        self.moodSelection = MoodSelection()
        self.isHuman = isHuman
        self.place = place
    }
} 