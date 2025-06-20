import Foundation
import UIKit
import CoreML
import Vision

class MLAnalysisService {
    
    // MARK: - ML Analysis
    func analyzeImage(_ uiImage: UIImage) async throws -> (isHuman: String, place: String) {
        let config = MLModelConfiguration()
        let modelHuman = try HumanDetection(configuration: config)
        let modelPlace = try PlaceClassification(configuration: config)
        
        guard let pixelBuffer = uiImage.toCVPixelBuffer() else {
            throw MLAnalysisError.pixelBufferConversionFailed
        }
        
        let prediction1 = try modelHuman.prediction(image: pixelBuffer)
        let prediction2 = try modelPlace.prediction(image: pixelBuffer)
        
        return (prediction1.target, prediction2.target)
    }
}

// MARK: - ML Analysis Errors
enum MLAnalysisError: Error, LocalizedError {
    case pixelBufferConversionFailed
    case modelLoadingFailed
    case predictionFailed
    
    var errorDescription: String? {
        switch self {
        case .pixelBufferConversionFailed:
            return "Error converting UIImage to CVPixelBuffer"
        case .modelLoadingFailed:
            return "Failed to load ML models"
        case .predictionFailed:
            return "ML prediction failed"
        }
    }
}

// MARK: - UIImage Extension (part of service layer)
extension UIImage {
    func toCVPixelBuffer() -> CVPixelBuffer? {
        let width = Int(size.width)
        let height = Int(size.height)
        
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
             kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        
        var pixelBuffer: CVPixelBuffer?
        
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         width,
                                         height,
                                         kCVPixelFormatType_32ARGB,
                                         attrs,
                                         &pixelBuffer)
        
        guard status == kCVReturnSuccess, let pb = pixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pb, [])
        let pxdata = CVPixelBufferGetBaseAddress(pb)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pxdata,
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: CVPixelBufferGetBytesPerRow(pb),
                                space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        guard let cgContext = context else {
            CVPixelBufferUnlockBaseAddress(pb, [])
            return nil
        }
        
        cgContext.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: width, height: height))
        CVPixelBufferUnlockBaseAddress(pb, [])
        
        return pb
    }
} 