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
            LandingPage()
        }
    }
}
