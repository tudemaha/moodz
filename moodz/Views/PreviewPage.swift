import SwiftUI

struct PreviewPage: View {
    var selectedImage: UIImage? // Image passed from ContentView
    @State private var rotationAngle: Angle = .zero
    @State private var imageSize: CGSize = CGSize(width: 300, height: 600)
    
    @State private var selectedMood: String = "Melancholy"
    @State private var place = ""
    
    
    var body: some View {
        let moods = ["Chill", "Melancholy", "Confident", "Romantinc", "Energetic", "Dreamy"]
        let moodLayout = [
            GridItem(.adaptive(minimum: 90)),
            GridItem(.adaptive(minimum: 90)),
            GridItem(.adaptive(minimum: 90)),
        ]
        
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
                    
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.white)
                        .frame(width : 80, height: 30)
                        .opacity(0)
                }
                .padding(.top, 60)
                
                Spacer()
                    .frame(height: 30)
                
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
                }
                .containerRelativeFrame(.vertical) { height, _ in
                    height * 0.5
                }
                
                VStack{
                    VStack(spacing: 10) {
                        HStack {
                            Text("Select current mood of the image: ")
                                .font(.custom("HelveticaNeue", size: 18))
                                .foregroundStyle(.white)
                                .fontWeight(.semibold)
                            
                            Spacer()
                        }
                        
                        LazyVGrid(columns: moodLayout) {
                            ForEach(moods, id: \.self) {mood in
                                Button {
                                    selectedMood = mood
                                } label: {
                                    Text(mood)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 10)
                                        .containerRelativeFrame(.horizontal) { width, _ in
                                            width * 0.28
                                        }
                                        .background(mood == selectedMood ? .P : .white)
                                        .clipShape(.capsule)
                                        .font(.custom("HelveticaNeue", size: 16))
                                        .fontWeight(.semibold)
                                        .foregroundStyle(mood == selectedMood ? .white : .black)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    
                    VStack {
                        HStack(spacing: 10) {
                            Text("Show the place: ")
                                .font(.custom("HelveticaNeue", size: 18))
                                .foregroundStyle(.white)
                                .fontWeight(.semibold)
                            
                            Spacer()
                        }
                        
                        TextField("Place", text: $place)
                            .frame(height: 35).border(Color.P)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .disableAutocorrection(true)
                            .background(.white)
                            .font(.custom("HelveticaNeue", size: 16))
                            .clipShape(.capsule)
                        
                    }
                    .padding(.horizontal, 20)
                    
                    Button {
                        // Replace this with your desired action
                        print("Generate Songs Button tapped!")
                    } label: {
                        Text("Generate Songs")
                            .font(.custom("HelveticaNeue", size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .containerRelativeFrame(.horizontal) { width, _ in
                                width * 0.6
                            }
                            .padding(12)
                            .background(Color.P)
                            .cornerRadius(22)
                    }
                    .padding(20)
                }
                
                
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
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
}

#Preview {
    PreviewPage(selectedImage: UIImage(systemName: "photo")!) // Example usage with a placeholder image
}
