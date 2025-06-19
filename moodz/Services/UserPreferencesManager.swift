import Foundation

class UserPreferencesManager {
    static let shared = UserPreferencesManager()
    
    private init() {}
    
    // MARK: - Keys
    private enum Keys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let songGenerationCount = "songGenerationCount"
        static let lastGenerationDate = "lastGenerationDate"
        static let dailyGenerationLimit = 5
    }
    
    // MARK: - OnBoarding Management
    var hasCompletedOnboarding: Bool {
        get {
            UserDefaults.standard.bool(forKey: Keys.hasCompletedOnboarding)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.hasCompletedOnboarding)
        }
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        print("✅ Onboarding completed and saved")
    }
    
    // MARK: - Song Generation Limit Management
    var dailyGenerationLimit: Int {
        return Keys.dailyGenerationLimit
    }
    
    var remainingGenerations: Int {
        let used = todaysGenerationCount
        return max(0, dailyGenerationLimit - used)
    }
    
    var todaysGenerationCount: Int {
        // Check if it's a new day
        if !isToday(lastGenerationDate) {
            resetDailyCount()
            return 0
        }
        return UserDefaults.standard.integer(forKey: Keys.songGenerationCount)
    }
    
    private var lastGenerationDate: Date? {
        get {
            let timestamp = UserDefaults.standard.double(forKey: Keys.lastGenerationDate)
            guard timestamp > 0 else { return nil }
            return Date(timeIntervalSince1970: timestamp)
        }
        set {
            let timestamp = newValue?.timeIntervalSince1970 ?? 0
            UserDefaults.standard.set(timestamp, forKey: Keys.lastGenerationDate)
        }
    }
    
    func canGenerateToday() -> Bool {
        return remainingGenerations > 0
    }
    
    func incrementGenerationCount() -> Bool {
        guard canGenerateToday() else {
            print("❌ Daily generation limit reached")
            return false
        }
        
        let currentCount = todaysGenerationCount
        UserDefaults.standard.set(currentCount + 1, forKey: Keys.songGenerationCount)
        lastGenerationDate = Date()
        
        print("✅ Generation count incremented. Remaining: \(remainingGenerations)")
        return true
    }
    
    private func resetDailyCount() {
        UserDefaults.standard.set(0, forKey: Keys.songGenerationCount)
        print("🔄 Daily generation count reset")
    }
    
    private func isToday(_ date: Date?) -> Bool {
        guard let date = date else { return false }
        return Calendar.current.isDate(date, inSameDayAs: Date())
    }
    
    // MARK: - Debug/Developer Methods
    func resetAllData() {
        UserDefaults.standard.removeObject(forKey: Keys.hasCompletedOnboarding)
        UserDefaults.standard.removeObject(forKey: Keys.songGenerationCount)
        UserDefaults.standard.removeObject(forKey: Keys.lastGenerationDate)
        print("🔄 All user preferences reset")
    }
    
    /// Reset only the daily generation count (for testing)
    func resetDailyGenerations() {
        UserDefaults.standard.set(0, forKey: Keys.songGenerationCount)
        lastGenerationDate = nil
        print("🔄 Daily generation count reset to 0. You now have \(remainingGenerations)/\(dailyGenerationLimit) attempts")
    }
    
    /// Set generation count to maximum (for testing limit scenario)
    func setGenerationsToMax() {
        UserDefaults.standard.set(dailyGenerationLimit, forKey: Keys.songGenerationCount)
        lastGenerationDate = Date()
        print("🔄 Generation count set to maximum. You now have \(remainingGenerations)/\(dailyGenerationLimit) attempts")
    }
    
    /// Set a specific generation count (for testing)
    func setGenerationCount(_ count: Int) {
        let clampedCount = max(0, min(count, dailyGenerationLimit))
        UserDefaults.standard.set(clampedCount, forKey: Keys.songGenerationCount)
        lastGenerationDate = Date()
        print("🔄 Generation count set to \(clampedCount). You now have \(remainingGenerations)/\(dailyGenerationLimit) attempts")
    }
    
    /// Reset onboarding only (for testing onboarding flow)
    func resetOnboarding() {
        UserDefaults.standard.removeObject(forKey: Keys.hasCompletedOnboarding)
        print("🔄 Onboarding reset. Will show onboarding on next app launch")
    }
    
    func getDebugInfo() -> String {
        return """
        📊 User Preferences Debug:
        - Onboarding completed: \(hasCompletedOnboarding)
        - Today's generations: \(todaysGenerationCount)/\(dailyGenerationLimit)
        - Remaining generations: \(remainingGenerations)
        - Last generation: \(lastGenerationDate?.formatted() ?? "Never")
        """
    }
} 