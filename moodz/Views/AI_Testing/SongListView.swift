import SwiftUI

struct SongsListView: View {
    let songs: [SongResponse]
    
    var body: some View {
        if songs.isEmpty {
            EmptyView()
        } else {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "music.note.list")
                        .foregroundColor(.blue)
                    Text("Songs Found (\(songs.count))")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                }
                
                LazyVStack(spacing: 8) {
                    ForEach(songs) { song in
                        SongCardView(song: song)
                    }
                }
            }
        }
    }
}

struct SongCardView: View {
    let song: Song
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(song.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("by \(song.artist)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if let year = song.year {
                    Text("\(year)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            
            HStack {
                if let album = song.album {
                    Label(album, systemImage: "opticaldisc")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if let genre = song.genre {
                    Text(genre)
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(4)
                }
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
    }
}
