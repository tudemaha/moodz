import SwiftUI
import PhotosUI

// MARK: - View (UI Presentation Only)
struct HomePage: View {
    
    // MARK: - State Management
    @StateObject private var controller = HomePageController()
    @State private var pickerItem: PhotosPickerItem?
    
    // MARK: - Environment Object (Injected PromptController)
    @EnvironmentObject var promptController: PromptController
    
    // MARK: - Body
    var body: some View {
        ZStack {
            backgroundView
            mainContent
        }
        .navigationBarBackButtonHidden(true)
        .photosPicker(
            isPresented: $controller.photoState.isPickerPresented,
            selection: $pickerItem,
            matching: .images
        )
        .onChange(of: pickerItem) { oldValue, newValue in
            Task {
                await controller.handleImageSelection(newValue)
            }
        }        
        .background(
            NavigationLink(
                destination: PreviewPage(
                    selectedImage: controller.selectedUIImage,
                    isHuman: controller.isHuman,
                    place: controller.place
                )
                .environmentObject(promptController),
                isActive: $controller.isNavigating
            ) {
                EmptyView()
            }
        )

        .alert("Error", isPresented: .constant(controller.errorMessage != nil)) {
            Button("OK") {
                controller.errorMessage = nil
            }
        } message: {
            Text(controller.errorMessage ?? "")
        }
    }
    
    // MARK: - View Components
    private var backgroundView: some View {
        Image("Background_Main")
            .resizable()
            .ignoresSafeArea()
    }
    
    private var mainContent: some View {
        VStack {
            Spacer()
            logoSection
            uploadSection
            Spacer()
        }
        .padding()
    }
    
    private var logoSection: some View {
        VStack {
            Image("logo_W")
                .padding(.bottom, 20)
            
            Text("Every photo holds a feeling — let Moodz it.")
                .font(.custom("HelveticaNeue", size: 17))
                .foregroundColor(.white)
        }
    }
    
    private var uploadSection: some View {
        RoundedRectangle(cornerRadius: 32)
            .fill(Color.P)
            .frame(width: 345, height: 550)
            .shadow(radius: 10)
            .overlay(uploadContent)
            .padding(.top, 15)
            .onTapGesture {
                controller.showPhotoPicker()
            }
    }
    
    private var uploadContent: some View {
        VStack {
            Spacer().frame(height: 40)
            
            if controller.isAnalyzing {
                analysisLoadingView
            } else {
                uploadPromptView
            }
        }
    }
    
    private var analysisLoadingView: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(2)
                .padding(.vertical, 30)
            
            Text("Analyzing your image...")
                .font(.custom("HelveticaNeue", size: 18))
                .foregroundColor(.white)
                .padding(.vertical, 10)
        }
    }
    
    private var uploadPromptView: some View {
        VStack {
            Image(systemName: "square.and.arrow.up.circle.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(.white)
                .frame(width: 86)
                .padding(.top, 20)
            
            Text("Upload Image Here")
                .font(.custom("HelveticaNeue", size: 18))
                .foregroundColor(.white)
                .padding(.vertical, 10)
            
            Text("Supported Format : jpg, png, jpeg")
                .font(.custom("HelveticaNeue", size: 14))
                .foregroundColor(.white).opacity(0.5)
            
            Text("Please make sure the image is not blurry")
                .font(.custom("HelveticaNeue", size: 14))
                .foregroundColor(.white).opacity(0.5)
        }
    }
}

#Preview {
    HomePage()
        .environmentObject(PromptController())
}
