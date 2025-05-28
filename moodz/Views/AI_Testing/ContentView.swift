import SwiftUI

struct ContentView: View {
    @StateObject private var controller = PromptController()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                PromptInputView(
                    prompt: $controller.prompt,
                    onSend: controller.sendPrompt,
                    isLoading: controller.isLoading
                )
                
                ResponseDisplayView(
                    response: controller.response,
                    errorMessage: controller.errorMessage
                )
                
                Spacer()
            }
            .padding()
            .navigationTitle("AI Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear") {
                        controller.clearAll()
                    }
                    .disabled(controller.isLoading)
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}
