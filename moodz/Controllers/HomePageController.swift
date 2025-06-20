import Foundation
import SwiftUI
import PhotosUI

// MARK: - Photo Picker State (UI State - belongs in Controller)
struct PhotoPickerState {
    var pickerItem: PhotosPickerItem?
    var selectedUIImage: UIImage?
    var selectedImage: Image?
    var isPickerPresented: Bool = false
}

@MainActor
class HomePageController: ObservableObject {
    
    // MARK: - Published Properties (View observes these)
    @Published var isAnalyzing = false
    @Published var isNavigating = false
    @Published var analysisResult: ImageAnalysisResult?
    @Published var errorMessage: String?
    @Published var photoState = PhotoPickerState()
    
    // MARK: - Dependencies (injected for testability)
    private let mlAnalysisService: MLAnalysisService
    
    // MARK: - Computed Properties (for backward compatibility)
    var isHuman: String {
        analysisResult?.isHuman ?? ""
    }
    
    var place: String {
        analysisResult?.place ?? ""
    }
    
    var selectedUIImage: UIImage? {
        analysisResult?.image
    }
    
    // MARK: - Initialization
    init(mlAnalysisService: MLAnalysisService = MLAnalysisService()) {
        self.mlAnalysisService = mlAnalysisService
    }
    
    // MARK: - Business Logic Methods
    
    /// Handles the entire image selection and analysis workflow
    func handleImageSelection(_ pickerItem: PhotosPickerItem?) async {
        guard let pickerItem = pickerItem else { return }
        
        do {
            // Load image data
            guard let data = try await pickerItem.loadTransferable(type: Data.self),
                  let uiImage = UIImage(data: data) else {
                await setError("Failed to load image")
                return
            }
            
            // Update photo state
            await updatePhotoState(with: uiImage)
            
            // Analyze image
            await analyzeImage(uiImage)
            
            // Navigate if analysis successful
            if analysisResult != nil {
                isNavigating = true
            }
            
        } catch {
            await setError("Error processing image: \(error.localizedDescription)")
        }
    }
    
    /// Shows the photo picker
    func showPhotoPicker() {
        guard !isAnalyzing else { return }
        photoState.isPickerPresented = true
    }
    
    /// Resets all state to initial values
    func resetState() {
        isAnalyzing = false
        isNavigating = false
        analysisResult = nil
        errorMessage = nil
        photoState = PhotoPickerState()
    }
    
    // MARK: - Private Helper Methods
    
    /// Updates photo state with selected image
    private func updatePhotoState(with uiImage: UIImage) async {
        photoState.selectedUIImage = uiImage
        photoState.selectedImage = Image(uiImage: uiImage)
    }
    
    /// Performs ML analysis on the image
    private func analyzeImage(_ uiImage: UIImage) async {
        isAnalyzing = true
        errorMessage = nil
        
        do {
            let result = try await mlAnalysisService.analyzeImage(uiImage)
            
            // Create analysis result model
            analysisResult = ImageAnalysisResult(
                isHuman: result.isHuman,
                place: result.place,
                image: uiImage
            )
            
        } catch {
            await setError(error.localizedDescription)
            
            // Set default values in case of error
            analysisResult = ImageAnalysisResult(
                isHuman: "Unknown",
                place: "Unknown location",
                image: uiImage
            )
        }
        
        isAnalyzing = false
    }
    
    /// Sets error message safely on main actor
    private func setError(_ message: String) async {
        errorMessage = message
    }
} 