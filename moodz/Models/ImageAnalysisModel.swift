import Foundation
import UIKit

// MARK: - Analysis Result Model (Pure Data)
struct ImageAnalysisResult {
    let isHuman: String
    let place: String
    let image: UIImage
    let timestamp: Date = Date()
    
    init(isHuman: String, place: String, image: UIImage) {
        self.isHuman = isHuman
        self.place = place
        self.image = image
    }
} 
