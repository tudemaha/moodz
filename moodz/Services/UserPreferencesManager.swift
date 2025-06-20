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
        static let appInstallationDate = "appInstallationDate"
        static let onboardingVersion = "onboardingVersion"
    }
    
    private let currentOnboardingVersion = 1
    
    // MARK: - OnBoarding Management
    var hasCompletedOnboarding: Bool {
        get {
            let completed = UserDefaults.standard.bool(forKey: Keys.hasCompletedOnboarding)
            let savedVersion = UserDefaults.standard.integer(forKey: Keys.onboardingVersion)
            
            return completed && savedVersion == currentOnboardingVersion
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.hasCompletedOnboarding)
            if newValue {
                UserDefaults.standard.set(currentOnboardingVersion, forKey: Keys.onboardingVersion)
            }
        }
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        
        if UserDefaults.standard.object(forKey: Keys.appInstallationDate) == nil {
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: Keys.appInstallationDate)
        }
    }
    
    var isFreshInstall: Bool {
        return UserDefaults.standard.object(forKey: Keys.appInstallationDate) == nil
    }
    
    var daysSinceInstallation: Int {
        guard let installTimestamp = UserDefaults.standard.object(forKey: Keys.appInstallationDate) as? TimeInterval else {
            return 0
        }
        
        let installDate = Date(timeIntervalSince1970: installTimestamp)
        let daysSince = Calendar.current.dateComponents([.day], from: installDate, to: Date()).day ?? 0
        return daysSince
    }
    
    func resetOnboardingForUser() {
        UserDefaults.standard.removeObject(forKey: Keys.hasCompletedOnboarding)
        UserDefaults.standard.removeObject(forKey: Keys.onboardingVersion)
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
            return false
        }
        
        let currentCount = todaysGenerationCount
        UserDefaults.standard.set(currentCount + 1, forKey: Keys.songGenerationCount)
        lastGenerationDate = Date()
        
        return true
    }
    
    private func resetDailyCount() {
        UserDefaults.standard.set(0, forKey: Keys.songGenerationCount)
    }
    
    private func isToday(_ date: Date?) -> Bool {
        guard let date = date else { return false }
        return Calendar.current.isDate(date, inSameDayAs: Date())
    }
    
    // MARK: - Debug/Developer Methods (Only for development)
    #if DEBUG
    func resetAllData() {
        UserDefaults.standard.removeObject(forKey: Keys.hasCompletedOnboarding)
        UserDefaults.standard.removeObject(forKey: Keys.songGenerationCount)
        UserDefaults.standard.removeObject(forKey: Keys.lastGenerationDate)
        UserDefaults.standard.removeObject(forKey: Keys.appInstallationDate)
        UserDefaults.standard.removeObject(forKey: Keys.onboardingVersion)
    }
    
    func resetOnboarding() {
        UserDefaults.standard.removeObject(forKey: Keys.hasCompletedOnboarding)
        UserDefaults.standard.removeObject(forKey: Keys.onboardingVersion)
    }
    #endif
    
    func getDebugInfo() -> String {
        return """
        📊 User Preferences Debug:
        - Onboarding completed: \(hasCompletedOnboarding)
        - Fresh install: \(isFreshInstall)
        - Days since install: \(daysSinceInstallation)
        - Today's generations: \(todaysGenerationCount)/\(dailyGenerationLimit)
        - Remaining generations: \(remainingGenerations)
        - Last generation: \(lastGenerationDate?.formatted() ?? "Never")
        """
    }
} 
 