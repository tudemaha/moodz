import SwiftUI
import MusicKit

struct ResultView: View {
    
    @State private var selectedIndex: MusicItemID?
    @State private var clipboardContent = ""
    @State private var copyButtonText = "Copy to clipboard"
    
    @StateObject private var musicSearchController = MusicSearchController()
    @StateObject private var musicPlayerController = MusicPlayerController()

    var body: some View {
        ZStack(alignment: .top) {
            Image("Background_Main")
                .resizable()
                .ignoresSafeArea()
            
            LinearGradient(
                gradient: Gradient(colors: [.black.opacity(0.5), .black.opacity(0)]),
                startPoint: .bottom,
                endPoint: .top
            )
            .ignoresSafeArea()
            
            VStack {
                HStack {
                    NavigationLink(destination: PreviewPage()) {
                        Image("back_arrow")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    }
                    .padding()
                    
                    Spacer()
                    
                    Image("logo_W")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 80)
                    
                    Spacer()
                        .containerRelativeFrame(.horizontal) { width, axis in
                            width * 0.35
                        }
                }
                
                Image("Background_Black")
                    .resizable()
                    .scaledToFill()
                    .containerRelativeFrame(.vertical) { height, axis in
                        height * 0.5
                    }
                    .containerRelativeFrame(.horizontal) { width, axis in
                        width * 0.6
                    }
                    .clipShape(.rect(cornerRadius: 20))
                
                Spacer()
                
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(musicSearchController.results) { song in
                                HStack(spacing: 10) {
                                    AsyncImage(url: song.artworkURL) { phase in
                                        if let image = phase.image {
                                            image
                                                .resizable()
                                                .frame(width: 100, height: 100)
                                                .clipShape(.rect(cornerRadius: 10))
                                        } else if phase.error != nil {
                                            Color.red
                                        } else {
                                            ProgressView()
                                        }
                                    }
                                    
                                    VStack(alignment: .leading) {
                                        Text(song.title)
                                            .fontWeight(.bold)
                                            .foregroundStyle(.white)
                                        Text(song.artist)
                                            .foregroundStyle(.gray)
                                        Button {
                                            if song.isPlaying {
                                                musicPlayerController.pausePreview()
                                                musicSearchController.updatePausedState(song)
                                            } else {
                                                musicPlayerController.playPreview(for: song)
                                                musicSearchController.updatePlayingState(song)
                                            }
                                        } label: {
                                            HStack {
                                                Image(systemName: song.isPlaying ? "pause.fill" : "play.fill")
                                                Text(song.isPlaying ? "PAUSE" : "PLAY")
                                            }
                                            .foregroundStyle(.white)
                                            .padding(.vertical, 5)
                                            .padding(.horizontal, 12)
                                            .background(.P)
                                            .clipShape(.rect(cornerRadius: 100))
                                            
                                        }
                                    }
                                }
                                .containerRelativeFrame(.horizontal, alignment: .leading) { width, _ in
                                    width * 0.8
                                }
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
                        .padding(.horizontal, UIScreen.main.bounds.width * 0.06)
                    }
                    .scrollTargetBehavior(.viewAligned)
                    .scrollPosition(id: $selectedIndex)
                }
                
                Button {
                    musicSearchController.searchTerm = "take me home"
                    musicSearchController.search()
                } label: {
                    Text("search")
                }
                
                Spacer()
                
                VStack {
                    Button {
                        copyToClipboard(selectedIndex!)
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
                    .padding(.bottom, 2)
                    
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
            }
        }
    }
    
    func copyToClipboard(_ id: MusicItemID) {
        let currentSong = musicSearchController.results.first(where: {$0.id == id})
        
        UIPasteboard.general.string = "\(currentSong!.artist) - \(currentSong!.title)"
        self.copyButtonText = "Copied!"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.copyButtonText = "Copy to clipboard"
        }
    }
}

#Preview {
    ResultView()
}
