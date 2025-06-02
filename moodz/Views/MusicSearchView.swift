import SwiftUI
import MusicKit

struct MusicSearchView: View {
    @StateObject private var viewModel = MusicSearchViewModel()
    
    var body: some View {
        VStack {
            TextField("Search songs...", text: $viewModel.searchTerm)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            if viewModel.isSearching {
                ProgressView()
            } else {
                List(viewModel.results) { song in
                    SongRowView(
                        song: song,
                        isPlaying: viewModel.currentlyPlayingSong == song
                    ) {
                        viewModel.togglePlayback(for: song)
                    }
                }
            }
        }
        .alert("Error", isPresented: .constant(viewModel.error != nil)) {
            Button("OK") { viewModel.error = nil }
        } message: {
            if let error = viewModel.error {
                Text(error.localizedDescription)
            }
        }
    }
}

struct SongRowView: View {
    let song: SongItem
    let isPlaying: Bool
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            AsyncImage(url: song.artworkURL) { image in
                image.resizable()
            } placeholder: {
                Color.gray
            }
            .frame(width: 50, height: 50)
            .cornerRadius(8)
            
            VStack(alignment: .leading) {
                Text(song.title)
                    .font(.headline)
                Text(song.artist)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                .font(.title)
                .foregroundColor(.accentColor)
        }
        .onTapGesture(perform: onTap)
    }
} 

#Preview {
        MusicSearchView()
}
