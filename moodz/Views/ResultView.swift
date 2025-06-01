import SwiftUI

struct ResultView: View {
    
    @State private var isPlayed = false;
    @State private var selectedIndex: Int? = 0
    @State private var clipboardContent = ""
    @State private var copyButtonText = "Copy to clipboard"
    
    var songs: [SongItem] = []

    
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
                            ForEach(0..<5, id: \.self) { index in
                                HStack(spacing: 10) {
                                    Image("Background_Black")
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                        .clipShape(.rect(cornerRadius: 10))
                                    
                                    VStack(alignment: .leading) {
                                        Text("everything u are")
//                                            .font(.)
                                            .fontWeight(.bold)
                                            .foregroundStyle(.white)
                                        Text("Hindia")
//                                            .font(.title3)
                                            .foregroundStyle(.gray)
                                        Button {
                                            isPlayed.toggle()
                                        } label: {
                                            HStack {
                                                Image(systemName: isPlayed ? "pause.fill" : "play.fill")
                                                Text(isPlayed ? "PAUSE" : "PLAY")
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
                
                Spacer()
                
                VStack {
                    Button {
                        copyToClipboard((String(selectedIndex!)))
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
    
    func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
        self.copyButtonText = "Copied!"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.copyButtonText = "Copy to clipboard"
        }
    }
}

#Preview {
    ResultView()
}
