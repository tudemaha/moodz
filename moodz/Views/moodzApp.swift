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
            ContentView()
                .environmentObject(promptController)
        }
    }
}

// ✅ NEW: Separate ContentView to handle orientation
struct ContentView: View {
    @EnvironmentObject var promptController: PromptController
    
    var body: some View {
        Group {
            if UserPreferencesManager.shared.hasCompletedOnboarding {
                NavigationStack {
                    HomePage()
                        .environmentObject(promptController)
                }
            } else {
            NavigationStack {
                OnBoardingView()
                    .environmentObject(promptController)
                }
            }
        }
        .onAppear {
            // ✅ Lock orientation when app appears
            lockOrientation(.portrait)
        }
    }
    
    // ✅ Function to lock orientation
    private func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: orientation))
        }
    }
}

// ✅ NEW: Add this class to handle orientation locking
class AppDelegate: NSObject, UIApplicationDelegate {
    static var orientationLock = UIInterfaceOrientationMask.portrait
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}
