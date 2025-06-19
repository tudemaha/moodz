//
//  moodzApp.swift
//  moodz
//
//  Created by Tude Maha on 21/05/2025.
//

import SwiftUI

@main
struct moodzApp: App {
    @StateObject private var promptController = PromptController()
    
    var body: some Scene {
        WindowGroup {
            // ✅ ADD THIS LINE TO RESET DAILY GENERATIONS
//            let _ = UserPreferencesManager.shared.resetAllData()
            
            // Check if onboarding is needed
            if UserPreferencesManager.shared.hasCompletedOnboarding {
                // Skip onboarding, go directly to HomePage
                NavigationView {
                    HomePage()
                        .environmentObject(promptController)
                }
            } else {
                // Show onboarding
                OnBoardingView()
                    .environmentObject(promptController)
            }
        }
    }
}
