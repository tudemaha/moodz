import SwiftUI

// Preview view that accepts an Image as a parameter
struct PreviewPage: View {
    var selectedImage: UIImage? // Image passed from ContentView
    @State private var rotationAngle: Angle = .zero
    @State private var imageSize: CGSize = CGSize(width: 300, height: 600)
    @State private var value: Double = 0
    @State private var backgroundColor: Color = .black
    
    var body: some View {
        ZStack(alignment: .top){
            Image("Background_Black")
            VStack{
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
                    RoundedRectangle(cornerRadius: 25).fill(Color.white).frame(width : 80, height: 30).opacity(0)
                }.padding(.top, 60)
                
                Spacer().frame(height: 30)
                VStack{
                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage) // Use UIImage directly
                            .resizable()
                            .scaledToFit()
                            .frame(width: imageSize.width, height: imageSize.height)
                            .rotationEffect(rotationAngle) // Apply rotation based on orientation
                            .onAppear {
                                // Detect orientation when the image appears
                                detectOrientation(for: selectedImage)
                            }
                        
                    } else {
                        Text("No image selected")
                            .foregroundColor(.white)
                    }
                }.frame(height: 450)
                
                VStack{
                    HStack(){
                        Text("Masukan Mood dari foto anda : ").font(.custom("HelveticaNeue", size: 18)).foregroundStyle(.white).fontWeight(.semibold)
                        Spacer()
                    }.padding(20)
                    Slider(value: $value, in: 0...100, step: 25)
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        .onChange(of: value) { newValue in
                            updateBackgroundColor()
                        }
                    
                    Button(action: {
                        // Replace this with your desired action
                        print("Generate Songs Button tapped!")
                    }) {
                        Text("Generate Songs")
                            .font(.custom("HelveticaNeue", size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.P)
                            .cornerRadius(22)
                    }.padding(20)
                }
                
                
            }.padding()
        }.navigationBarBackButtonHidden(true)
    }
    private func detectOrientation(for image: UIImage) {
        // Check image dimensions (width vs height)
        if image.size.width > image.size.height {
            // Landscape orientation, set size to 400x200
            rotationAngle = Angle(degrees: 0)
            imageSize = CGSize(width: 350, height: 250)
        } else {
            // Portrait orientation, set size to 300x600
            rotationAngle = .zero
            imageSize = CGSize(width: 350, height: 450)
        }
    }
    private func updateBackgroundColor() {
        switch value {
        case 0...25:
            backgroundColor = .black // Black when value is 0
        case 26...50:
            backgroundColor = .white // White when value is 25
        case 51...75:
            backgroundColor = .red // Red when value is 50
        case 76...100:
            backgroundColor = .blue // Blue when value is 75
        default:
            backgroundColor = .black // Default to black
        }
    }
}

#Preview {
    PreviewPage(selectedImage: UIImage(systemName: "photo")!) // Example usage with a placeholder image
}
