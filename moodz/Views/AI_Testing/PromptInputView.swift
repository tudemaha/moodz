import SwiftUI

struct PromptInputView: View {
    // Fixed prompt text that cannot be changed
    let promptText = "Give me 5 Songs about love, return it only in json format"
    let onSend: () -> Void
    let isLoading: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            // Display the fixed prompt text in a read-only field
            Text(promptText)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(8)
            
            Button(action: onSend) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "paperplane.fill")
                    }
                    Text(isLoading ? "Sending..." : "Send")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading)
        }
    }
}
