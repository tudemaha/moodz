import SwiftUI

struct ContentView: View {
    @StateObject private var controller = PromptController()
    @StateObject private var viewModel = MusicSearchViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                PromptInputView(
                    onSend: controller.sendPrompt,
                    isLoading: controller.isLoading
                )
                
                ScrollView {
                    ResponseDisplayView(
                        response: controller.response,
                        songs: controller.songs,
                        errorMessage: controller.errorMessage
                    )
//                    List(controller.songs){song in 
//                        if viewModel.isSearching {
//                            ProgressView()
//                        } else {
//                            SongRowView(
//                                song: song,
//                                isPlaying: viewModel.currentlyPlayingSong == song
//                            ) {
//                                viewModel.togglePlayback(for: song)
//                            }
//                        }
//                    }
//                    
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("AI Music Chat")
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
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
