import Foundation
import MusicKit

class MusicKitService {
    static let shared = MusicKitService()
    
    private init() {}
    
    func configureMusicKit() async throws {
        // Check authorization status first
        let authStatus = MusicAuthorization.currentStatus
        print("📱 Current Music Authorization Status: \(authStatus)")
        
        if authStatus == .notDetermined {
            let newStatus = await MusicAuthorization.request()
            print("🎵 New Music Authorization Status: \(newStatus)")
            
            guard newStatus == .authorized else {
                throw MusicKitError.unauthorized
            }
        } else if authStatus != .authorized {
            throw MusicKitError.unauthorized
        }
        
        // If we get here, we're authorized
        print("✅ MusicKit is authorized and ready to use")
    }
    
    func requestMusicAuthorization() async -> MusicAuthorization.Status {
        return await MusicAuthorization.request()
    }
    
    func getCurrentAuthorizationStatus() -> MusicAuthorization.Status {
        return MusicAuthorization.currentStatus
    }
}

enum MusicKitError: Error {
    case tokenFileNotFound
    case tokenExpired
    case tokenDecodingFailed(Error)
    case unauthorized
    
    var localizedDescription: String {
        switch self {
        case .unauthorized:
            return "Apple Music access not authorized. Please enable it in Settings."
        case .tokenFileNotFound:
            return "Developer token file not found."
        case .tokenExpired:
            return "Developer token has expired."
        case .tokenDecodingFailed(let error):
            return "Failed to decode token: \(error.localizedDescription)"
        }
    }
}
