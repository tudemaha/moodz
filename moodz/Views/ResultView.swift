import SwiftUI
import MusicKit

struct ResultView: View {
    // MARK: - Controller
    @StateObject private var controller: ResultPageController
    
    // MARK: - Local State for Alerts
    @State private var showLimitAlert = false
    
    // MARK: - Environment Object (for accessing remaining generations)
    @EnvironmentObject var promptController: PromptController
    
    // MARK: - Initialization (Updated with Dependency Injection)
    init(customPrompt: String? = nil, SelectedImage: UIImage? = nil, promptController: PromptController) {
        print("🔧 ResultView INIT - customPrompt: \(customPrompt ?? "nil")")
        print("🔧 ResultView INIT - promptController with \(promptController.songItems.count) songs")
        print("🔧 PromptController instance: \(ObjectIdentifier(promptController))")
        
        self._controller = StateObject(wrappedValue: ResultPageController(
            customPrompt: customPrompt,
            selectedImage: SelectedImage,
            promptController: promptController
        ))
    }
    
    var body: some View {
        ZStack(alignment: .top){
            Image("Background_Black")
                .resizable()
                .ignoresSafeArea()
            
            VStack{
                headerSection
                
                Spacer()
                    .frame(height: 30)
                
                ScrollView {
                    VStack{
                        imageSection
                        
                        // ✅ ADD: Remaining generations display
                        remainingGenerationsSection
                        
                        contentSection
                        
                        if !controller.isLoading {
                            actionButtonsSection
                        }
                    }
                }
                .onAppear {
                    print("🔄 ResultView onAppear - controller.songItems: \(controller.songItems.count)")
                    controller.viewDidAppear()
                    
                    // Check if remaining generations is 0 and show alert
                    checkAndShowLimitAlert()
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }
    
    // MARK: - View Components
    private var headerSection: some View {
        HStack(alignment: .top){
            NavigationLink(destination: HomePage()) {
                Image("back_arrow")
                    .font(.largeTitle)
                    .foregroundColor(.white)
            }.padding()
            Spacer()
            
            Image("logo_W").resizable()
                .scaledToFit()
                .frame(width: 120, height: 80)
            
            Spacer()
            
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white)
                .frame(width : 80, height: 30)
                .opacity(0)
        }
    }
    
    private var imageSection: some View {
        Group {
            if let imageInfo = controller.imageDisplayInfo {
                Image(uiImage: imageInfo.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: imageInfo.size.width, height: imageInfo.size.height)
                    .rotationEffect(Angle(degrees: imageInfo.rotationAngle))
            } else {
                Text("No image selected")
                    .foregroundColor(.white)
            }
        }
    }
    
    // ✅ NEW: Remaining generations display section
    private var remainingGenerationsSection: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: controller.remainingGenerations > 0 ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .foregroundColor(controller.remainingGenerations > 0 ? .green : .orange)
                
                Text("Daily generations remaining: \(controller.remainingGenerations)/\(UserPreferencesManager.shared.dailyGenerationLimit)")
                    .font(.custom("HelveticaNeue", size: 14))
                    .foregroundColor(.white)
                    .fontWeight(.medium)
            }
            
            // Show warning message when generations are low
            if controller.remainingGenerations <= 1 && controller.remainingGenerations > 0 {
                Text("⚠️ Only \(controller.remainingGenerations) generation left today!")
                    .font(.custom("HelveticaNeue", size: 12))
                    .foregroundColor(.orange)
                    .italic()
            } else if controller.remainingGenerations == 0 {
                Text("❌ No more generations today. Come back tomorrow!")
                    .font(.custom("HelveticaNeue", size: 12))
                    .foregroundColor(.red)
                    .fontWeight(.semibold)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
                .stroke(controller.remainingGenerations > 0 ? Color.green.opacity(0.3) : Color.orange.opacity(0.5), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
    
    private var contentSection: some View {
        Group {
            if controller.isLoading {
                loadingView
            } else if controller.hasSongs {
                songListView
            } else {
                emptyStateView
            }
        }
    }
    
    private var actionButtonsSection: some View {
        VStack {
            Button {
                if let id = controller.selectedIndex {
                    controller.copyToClipboard(id)
                }
            } label: {
                Text(controller.copyButtonState.text)
                    .frame(width: 200)
                    .foregroundStyle(.white)
                    .fontWeight(.bold)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(.P)
                    .clipShape(.rect(cornerRadius: 100))
            }
            .padding(.vertical)
            
            VStack(spacing: 12) {
                // ✅ UPDATED: Generate Other Songs button with limit checking
                Button {
                    handleGenerateOtherSongs()
                } label: {
                    Text("Generate Other Songs")
                        .frame(width: 200)
                        .foregroundStyle(.white)
                        .fontWeight(.bold)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(controller.remainingGenerations > 0 ? .P : .gray)
                        .clipShape(.rect(cornerRadius: 100))
                }
                .disabled(controller.selectedIndex == nil)
                .simultaneousGesture(TapGesture().onEnded {
                    controller.stopAllPlayingSongs()
                })
                
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
                .simultaneousGesture(TapGesture().onEnded {
                    controller.navigateBackWithAudioStop()
                })
            }
            Spacer().frame(height: 50)
        }
        .alert("Daily Limit Reached", isPresented: $showLimitAlert) {
            Button("OK") {
                showLimitAlert = false
            }
        } message: {
            Text("You've used all \(UserPreferencesManager.shared.dailyGenerationLimit) daily generations. Your limit will reset tomorrow at midnight.")
        }
    }
    
    // MARK: - Action Handlers
    private func handleGenerateOtherSongs() {
        print("🔘 Generate Other Songs tapped. Remaining: \(controller.remainingGenerations)")
        
        if controller.remainingGenerations > 0 {
            // User has remaining generations
            controller.generateOtherSongs()
        } else {
            // User has no remaining generations, show alert
            showLimitAlert = true
        }
    }
    
    private func checkAndShowLimitAlert() {
        // Show alert if user has 0 remaining generations when view appears
        if controller.remainingGenerations == 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showLimitAlert = true
            }
        }
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
    
    // Song list view when songs are available
    private var songListView: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(controller.songItems) { songItem in
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
            .scrollPosition(id: $controller.selectedIndex)
            .frame(height: 150)
        }
    }
    
    // Empty state view when no songs are available yet
    private var emptyStateView: some View {
        VStack(spacing: 10) {
            Image(systemName: "music.note.list")
                .font(.system(size: 50))
                .foregroundColor(.white.opacity(0.7))
            
            Text("No songs generated yet")
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text("Songs will appear here automatically")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(height: 150)
    }
    
    // Individual song card
    private func songCard(for songItem: SongItem) -> some View {
        HStack(spacing: 10) {
            // Song artwork
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
            
            // Song details and play button
            VStack(alignment: .leading, spacing: 5) {
                Text(songItem.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                
                Text(songItem.artist)
                    .foregroundStyle(.gray)
                    .lineLimit(1)
                
                Button {
                    controller.togglePlayback(for: songItem)
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
    
    // Default artwork placeholder
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
}

// Preview (Updated)
#Preview {
    ResultView(promptController: PromptController())
}
