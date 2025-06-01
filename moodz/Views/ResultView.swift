import SwiftUI

struct ResultView: View {
    
    @State private var isPlayed = false;
    
    var body: some View {
        ZStack(alignment: .top) {
            Image("Background_Main")
                .resizable()
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
                
                
                HStack {
                    Image("Background_Black")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .clipShape(.rect(cornerRadius: 10))
                        .padding(.trailing, 10)
                    
                    VStack(alignment: .leading) {
                        Text("Title")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        Text("Artist")
                            .font(.title3)
                            .foregroundStyle(.gray)
                        Button {
                            isPlayed.toggle()
                        } label: {
                            HStack {
                                Image(systemName: isPlayed ? "pause.fill" : "play.fill")
                                Text(isPlayed ? "PAUSE" : "PLAY")
                            }
                            .foregroundStyle(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 15)
                            .background(.P)
                            .clipShape(.rect(cornerRadius: 100))
                            
                        }
                    }
                }
                .containerRelativeFrame(.horizontal, alignment: .leading) { width, axis in
                    width * 0.6
                }
                .padding(15)
                .background(.black)
                .clipShape(.rect(cornerRadius: 20))
                
                VStack {
                    Button {
                        
                    } label: {
                        Text("Copy to clipboard")
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
}

#Preview {
    ResultView()
}
