import SwiftUI

struct PreviewPage: View {
    // MARK: - Controller
    @StateObject private var controller: PreviewPageController
    
    // MARK: - Environment Object (Injected PromptController)
    @EnvironmentObject var promptController: PromptController
    
    // MARK: - Local State for Alert
    @State private var showLimitAlert = false
    
    // MARK: - Initialization
    init(selectedImage: UIImage?, isHuman: String, place: String) {
        self._controller = StateObject(wrappedValue: PreviewPageController(
            selectedImage: selectedImage,
            isHuman: isHuman,
            place: place
        ))
    }
    
    var body: some View {
        let moodLayout = [
            GridItem(.adaptive(minimum: 90)),
            GridItem(.adaptive(minimum: 90)),
            GridItem(.adaptive(minimum: 90)),
        ]
        
        ZStack(alignment: .top){
            Image("Background_Black")
            
            VStack{
                headerSection
                
                Spacer()
                    .frame(height: 30)
                
                ScrollView{
                    VStack{
                        imageSection
                    }
                    .containerRelativeFrame(.vertical) { height, _ in
                        height * 0.5
                    }
                    
                    VStack{
                        moodSelectionSection(moodLayout: moodLayout)
                        
                        NavigationLink(
                            destination: ResultView(
                                customPrompt: controller.generatedPrompt,
                                SelectedImage: controller.imageDisplayInfo?.image,
                                promptController: promptController
                            ),
                            isActive: $controller.navigateToResults
                        ) {
                            EmptyView()
                        }
                        
                        generateSongsButton
                    }
                }
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
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
                }.padding(.top, 80)
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
                    
    private func moodSelectionSection(moodLayout: [GridItem]) -> some View {
                        VStack(spacing: 10) {
                            HStack {
                                Text("Select the vibes of the image: ")
                                    .font(.custom("HelveticaNeue", size: 18))
                                    .foregroundStyle(.white)
                                    .fontWeight(.semibold)
                                
                                Spacer()
                            }
                            
                            LazyVGrid(columns: moodLayout) {
                ForEach(controller.availableMoods, id: \.self) { mood in
                                    Button {
                        controller.selectMood(mood)
                                    } label: {
                                        Text(mood)
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 10)
                                            .containerRelativeFrame(.horizontal) { width, _ in
                                                width * 0.28
                                            }
                            .background(mood == controller.selectedMood ? .P : .white)
                                            .clipShape(.capsule)
                                            .font(.custom("HelveticaNeue", size: 16))
                                            .fontWeight(.semibold)
                            .foregroundStyle(mood == controller.selectedMood ? .white : .black)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
    }
    
    private var generateSongsButton: some View {
        VStack(spacing: 8) {
            // Generation limit indicator with better styling
            HStack {
                Image(systemName: promptController.remainingGenerations > 0 ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                    .foregroundColor(promptController.remainingGenerations > 0 ? .green : .orange)
                
                Text("Daily generations: \(promptController.remainingGenerations)/\(UserPreferencesManager.shared.dailyGenerationLimit)")
                    .font(.custom("HelveticaNeue", size: 12))
                    .foregroundColor(.white.opacity(0.7))
                        }
                        
                        Button {
                handleGenerateButtonTap()
                        } label: {
                            Text("Generate Songs")
                                .font(.custom("HelveticaNeue", size: 16))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .containerRelativeFrame(.horizontal) { width, _ in
                                    width * 0.6
                                }
                                .padding(12)
                    .background(promptController.remainingGenerations > 0 ? Color.P : Color.gray)
                                .cornerRadius(22)
                        }
            // ✅ REMOVED .disabled() - Button is always clickable now
            
            // Show additional info when limit is reached
            if promptController.remainingGenerations <= 0 {
                Text("Tap to see when you can generate again")
                    .font(.custom("HelveticaNeue", size: 10))
                    .foregroundColor(.white.opacity(0.5))
                    .italic()
            }
        }
        .padding(20)
        .alert("Daily Limit Reached", isPresented: $showLimitAlert) {
            Button("OK") { 
                showLimitAlert = false
            }
        } message: {
            VStack {
                Text("You've used all \(UserPreferencesManager.shared.dailyGenerationLimit) daily generations.\nCome back tomorrow for more songs!\nYour limit will reset at midnight.")
            }
        }
    }
    
    // MARK: - Button Action Handler
    private func handleGenerateButtonTap() {
        // Check if user has remaining generations
        if promptController.remainingGenerations > 0 {
            // User can generate, proceed normally
            controller.generateSongs()
        } else {
            // User has no remaining generations, show alert
            showLimitAlert = true
        }
    }
    
}

#Preview {
    PreviewPage(selectedImage: UIImage(systemName: "photo")!, isHuman: "test", place: "test")
        .environmentObject(PromptController())
}
