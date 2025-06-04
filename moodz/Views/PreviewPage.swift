import SwiftUI

struct PreviewPage: View {
    var selectedImage: UIImage? // Image passed from ContentView
    //var backgroundImage: UIImage?
    @State private var rotationAngle: Angle = .zero
    @State private var imageSize: CGSize = CGSize(width: 300, height: 600)
    @State private var shouldHide = false
    @State private var selectedMood: String = "Melancholy"
    @State private var place = ""
    @State private var mood = ""
    @State private var navigateToResults = false
    @State private var addMood = false
    
    // Create a computed property for the prompt based on mood and place
    private var generatedPrompt: String {
        var prompt = "Given the detected vibes of the photo "
        
        // Add mood
        prompt += selectedMood.lowercased()
        
        // Add place if provided
        if !place.isEmpty {
            prompt += " and location at \(place.lowercased())"
        }
        
        // Complete the prompt
        prompt += ", generate a list of 5 song recommendations. Your response MUST be ONLY a valid JSON array containing exactly 5 objects. Each object in the array must have two string properties: 'title' and 'artist'. Do not include any explanations, introductory text, or any characters outside of this JSON array."
        
        return prompt
    }
    
    var body: some View {
        let moods = ["Chill", "Melancholic", "Confident", "Romantic", "Energetic", "Dreamy"]
        let moodLayout = [
            GridItem(.adaptive(minimum: 90)),
            GridItem(.adaptive(minimum: 90)),
            GridItem(.adaptive(minimum: 90)),
        ]
        
        ZStack(alignment: .top){
            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage) // Set UIImage as background
                    .resizable()
                    .scaledToFit()
                    .blur(radius: 10)
                    .scaleEffect(1.3)
                    .opacity(70)
                    .rotationEffect(rotationAngle) // Apply rotation based on orientation
                    .containerRelativeFrame(.vertical) {
                        height,
                        _ in height * 1
                    }
                    .onAppear {
                        // Detect orientation when the image appears
                        detectOrientation(for: selectedImage)
                    }
            } else {
                Rectangle()
                    .foregroundColor(Color.accentColorDark)
                    .scaledToFill()
            }
           
            
            VStack{
                HStack(alignment: .top){
                    NavigationLink(destination: UploadScreen()) {
                        Image("back_arrow")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    }.padding()
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
                            Text("Describe the mood of the image: ")
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
                        
                        Button {
                            // Add new, customized mood
                            addMood = true
                            selectedMood = ""
                            self.shouldHide = true
                        }
                        label: {
                            Text("Add Mood")
                                .font(.custom("HelveticaNeue", size: 16))
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                                .containerRelativeFrame(.horizontal) { width, _ in
                                    width * 0.6
                                }
                                .padding(12)
                                .background(Color.white)
                                .clipShape(.capsule)
                            
                            }.opacity(shouldHide ? 0 : 1)
                        
                        
                        if (addMood == true) {
                            HStack{
                                TextField("Describe Mood", text: $mood)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .disableAutocorrection(true)
                                    .background(.white)
                                    .font(.custom("HelveticaNeue", size: 16))
                                    .clipShape(.capsule)
                                    .padding(.top, -35)
                                
                                /*Button {
                                    
                                } label: {
                                    Text("Add")
                                        .font(.custom("HelveticaNeue", size: 16))
                                        .fontWeight(.semibold)
                                        .foregroundColor(.black)
                                    
                                        .padding(12)
                                        .background(Color.white)
                                        .clipShape(.capsule)
                                }
                                 */
                            }.containerRelativeFrame(.horizontal) { width, _ in
                                width * 0.6
                            }
                            
                        }
                            
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                    
                    VStack {
                        HStack(spacing: 10) {
                            /*Text("Show the place: ")
                                .font(.custom("HelveticaNeue", size: 18))
                                .foregroundStyle(.white)
                                .fontWeight(.semibold)
                             */
                            
                            Spacer()
                        }
                        
                        /*TextField("Place", text: $place)
                            .frame(height: 35).border(Color.P)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .disableAutocorrection(true)
                            .background(.white)
                            .font(.custom("HelveticaNeue", size: 16))
                            .clipShape(.capsule)
                         */
                        
                    }
                    .padding(.horizontal, 20)
                    
                    NavigationLink(destination: ResultView(customPrompt: generatedPrompt, backgroundImage: selectedImage), isActive: $navigateToResults) {
                        EmptyView()
                    }
                    
                    Button {
                        // Navigate to ResultView
                        navigateToResults = true
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
    
    func detectOrientation(for image: UIImage) {
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
