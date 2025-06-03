import SwiftUI
import MusicKit

struct ResultView: View {
    @State private var selectedIndex: MusicItemID?
    @State private var copyButtonText = "Copy to clipboard"
    @StateObject private var promptController = PromptController()
    
    // Add these properties to accept parameters
    var customPrompt: String?
    var backgroundImage: UIImage?
    
    var body: some View {
        ZStack(alignment: .top) {
            // Background - use passed image if available
            if let backgroundImage = backgroundImage {
                Image(uiImage: backgroundImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .blur(radius: 20)
                    .overlay(Color.black.opacity(0.6))
                    .ignoresSafeArea()
            } else {
                Image("Background_Main")
                    .resizable()
                    .ignoresSafeArea()
            }
            
            LinearGradient(
                gradient: Gradient(colors: [.black.opacity(0.5), .black.opacity(0)]),
                startPoint: .bottom,
                endPoint: .top
            )
            .ignoresSafeArea()
            
            // Main content
            VStack(spacing: 0) {
                // Header - fixed to properly center the logo
                ZStack {
                    HStack {
                        NavigationLink(destination: PreviewPage(selectedImage: backgroundImage)) {
                            Image("back_arrow")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        // Empty space to balance the back button
                        Rectangle()
                            .opacity(0)
                            .frame(width: 40, height: 40)
                    }
                    
                    // Centered logo
                    Image("logo_W")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 80)
                }
                .padding(.horizontal)
                .padding(.top, 60)
                
                // Content area with proper spacing
                VStack(spacing: 20) {
                    // Image display
                    if let backgroundImage = backgroundImage {
                        Image(uiImage: backgroundImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: UIScreen.main.bounds.width * 0.6)
                            .clipShape(.rect(cornerRadius: 20))
                            .padding(.top, 20)
                    } else {
                        Image("Background_Black")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: UIScreen.main.bounds.width * 0.6)
                            .clipShape(.rect(cornerRadius: 20))
                            .padding(.top, 20)
                    }
                    
                    Spacer()
                        .frame(height: 20)
                    
                    // Song list or loading indicator - with fixed height and proper containment
                    if promptController.isLoading {
                        loadingView
                    } else if !promptController.songItems.isEmpty {
                        songListView
                    } else {
                        emptyStateView
                    }
                    
                    // Search button (only shown when not loading)
                    if !promptController.isLoading {
                        Button {
                            // If custom prompt is provided, use it
                            if let customPrompt = customPrompt {
                                promptController.prompt = customPrompt
                            }
                            promptController.sendPrompt()
                        } label: {
                            Text("Generate Songs")
                                .frame(width: 200)
                                .foregroundStyle(.white)
                                .fontWeight(.bold)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .background(.P)
                                .clipShape(.rect(cornerRadius: 100))
                        }
                        .padding(.vertical)
                    }
                    
                    Spacer()
                    
                    // Bottom buttons
                    VStack(spacing: 12) {
                        Button {
                            if let id = selectedIndex {
                                copyToClipboard(id)
                            }
                        } label: {
                            Text(copyButtonText)
                                .frame(width: 150)
                                .foregroundStyle(.white)
                                .fontWeight(.bold)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .background(.P)
                                .clipShape(.rect(cornerRadius: 100))
                        }
                        .disabled(selectedIndex == nil)
                        
                        NavigationLink(destination: HomePage()) {
                            Text("Back to home")
                                .frame(width: 150)
                                .foregroundStyle(.P)
                                .fontWeight(.bold)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .background(
                                    RoundedRectangle(cornerRadius: 100)
                                        .stroke(Color.P, lineWidth: 2)
                                )
                        }
                    }
                    .padding(.bottom, 30)
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            // If there are no songs yet, automatically start the search
            if promptController.songItems.isEmpty && !promptController.isLoading {
                // If custom prompt is provided, use it
                if let customPrompt = customPrompt {
                    promptController.prompt = customPrompt
                }
                promptController.sendPrompt()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    // Loading view shown when generating songs
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(2)
            
            Text("Finding the perfect songs for you...")
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding()
        }
        .frame(height: 150)
    }
    
    // Song list view when songs are available - fixed to contain cards properly
    private var songListView: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(promptController.songItems) { songItem in
                        songCard(for: songItem)
                            .frame(width: UIScreen.main.bounds.width * 0.8)
                            .padding(15)
                            .background(.black)
                            .clipShape(.rect(cornerRadius: 20))
                            .scrollTransition { content, phase in
                                content
                                    .opacity(phase.isIdentity ? 1 : 0.5)
                                    .scaleEffect(y: phase.isIdentity ? 1 : 0.75)
                            }
                    }
                }
                .scrollTargetLayout()
                .padding(.horizontal, 20)
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $selectedIndex)
            .frame(height: 150)
        }
    }
    
    // Empty state view when no songs are available yet
    private var emptyStateView: some View {
        VStack(spacing: 10) {
            Image(systemName: "music.note.list")
                .font(.system(size: 50))
                .foregroundColor(.white.opacity(0.7))
            
            Text("Tap 'Generate Songs' to get music recommendations")
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding()
        }
        .frame(height: 150)
    }
    
    // Individual song card - fixed layout to fit properly
    private func songCard(for songItem: SongItem) -> some View {
        HStack(spacing: 10) {
            // Song artwork - fixed size
            if let artworkURL = songItem.artworkURL {
                AsyncImage(url: artworkURL) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipShape(.rect(cornerRadius: 10))
                    } else if phase.error != nil {
                        defaultArtwork
                    } else {
                        ProgressView()
                    }
                }
                .frame(width: 80, height: 80)
            } else {
                defaultArtwork
            }
            
            // Song details and play button - with proper spacing
            VStack(alignment: .leading, spacing: 5) {
                Text(songItem.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                
                Text(songItem.artist)
                    .foregroundStyle(.gray)
                    .lineLimit(1)
                
                Button {
                    promptController.togglePlayback(for: songItem)
                } label: {
                    HStack {
                        Image(systemName: songItem.isPlaying ? "pause.fill" : "play.fill")
                        Text(songItem.isPlaying ? "PAUSE" : "PLAY")
                    }
                    .foregroundStyle(.white)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 12)
                    .background(Color.P)
                    .clipShape(.rect(cornerRadius: 100))
                }
                .disabled(songItem.previewURL == nil)
                .opacity(songItem.previewURL == nil ? 0.5 : 1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(10)
    }
    
    // Default artwork placeholder - fixed size
    private var defaultArtwork: some View {
        ZStack {
            Color.gray.opacity(0.3)
            Image(systemName: "music.note")
                .font(.system(size: 30))
                .foregroundColor(.white)
        }
        .frame(width: 80, height: 80)
        .clipShape(.rect(cornerRadius: 10))
    }
    
    // Copy song info to clipboard
    func copyToClipboard(_ id: MusicItemID) {
        if let currentSong = promptController.songItems.first(where: { $0.id == id }) {
            UIPasteboard.general.string = "\(currentSong.artist) - \(currentSong.title)"
            self.copyButtonText = "Copied!"
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.copyButtonText = "Copy to clipboard"
            }
        }
    }
}

// Preview
#Preview {
    ResultView()
}
