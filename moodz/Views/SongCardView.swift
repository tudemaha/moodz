import SwiftUI

struct SongCardView: View {
    let song: AISongResponse
    @ObservedObject var promptController: PromptController
    
    var body: some View {
        HStack(spacing: 10) {
            // Song artwork - with a default placeholder
            if let artworkURL = song.artworkURL {
                AsyncImage(url: artworkURL) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(.rect(cornerRadius: 10))
                    } else if phase.error != nil {
                        defaultArtwork
                    } else {
                        ProgressView()
                    }
                }
            } else {
                // Show default artwork when URL is nil
                defaultArtwork
            }
            
            // Song details and play button
            VStack(alignment: .leading) {
                Text(song.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                Text(song.artist)
                    .foregroundStyle(.gray)
                
                playButton
            }
        }
        .onAppear {
            // Removed print statements for performance
        }
    }
    
    // Extract the play button to a separate view for clarity
    private var playButton: some View {
        Button {
            // Find the matching song in songItems
            if let songItem = findMatchingSongItem() {
                promptController.togglePlayback(for: songItem)
            } else {
                // Silently handle case where no matching song is found
            }
        } label: {
            HStack {
                // Check if this song is playing
                let isPlaying = isThisSongPlaying()
                
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                Text(isPlaying ? "PAUSE" : "PLAY")
            }
            .foregroundStyle(.white)
            .padding(.vertical, 5)
            .padding(.horizontal, 12)
            .background(findMatchingSongItem() != nil ? Color.P : Color.gray)
            .clipShape(.rect(cornerRadius: 100))
        }
        .disabled(findMatchingSongItem() == nil)
    }
    
    // Default artwork placeholder
    private var defaultArtwork: some View {
        ZStack {
            Color.gray.opacity(0.3)
            Image(systemName: "music.note")
                .font(.system(size: 40))
                .foregroundColor(.white)
        }
        .frame(width: 100, height: 100)
        .clipShape(.rect(cornerRadius: 10))
    }
    
    // Helper method to find matching SongItem
    private func findMatchingSongItem() -> SongItem? {
        return promptController.songItems.first { songItem in
            // Match by title and artist (case insensitive)
            let titleMatches = songItem.title.lowercased().contains(song.title.lowercased()) || 
                               song.title.lowercased().contains(songItem.title.lowercased())
            
            let artistMatches = songItem.artist.lowercased().contains(song.artist.lowercased()) || 
                                song.artist.lowercased().contains(songItem.artist.lowercased())
            
            return titleMatches && artistMatches
        }
    }
    
    // Helper method to check if this song is playing
    private func isThisSongPlaying() -> Bool {
        guard let matchingSongItem = findMatchingSongItem() else {
            return false
        }
        
        return matchingSongItem.isPlaying
    }
}
