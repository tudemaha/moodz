import SwiftUI
import PhotosUI

struct HomePage: View {
    @State private var pickerItem: PhotosPickerItem? // To store the selected photo item
    @State private var selectedUIImage: UIImage? = nil  // Store UIImage for further processing
    @State private var selectedImage: Image? // SwiftUI Image to display the selected image
    @State private var isPickerPresented = false // State variable to manage when to present the photo picker
    @State private var isNavigating = false // State to control navigation to Preview
    
    var body: some View {
        ZStack {
            Image("Background_Main")
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                Image("logo_W").padding(.bottom, 20)
                
                Text("Every photo holds a feeling — let Moodz it.")
                    .font(.custom("HelveticaNeue", size: 17))
                    .foregroundColor(.white)
                
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color.P)
                    .frame(width: 345, height: 550)
                    .shadow(radius: 10)
                    .overlay(
                        VStack {
                            Spacer().frame(height: 40)
                            
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
                    )
                    .padding(.top, 15)
                    .onTapGesture {
                        isPickerPresented = true
                    }
                
                Spacer()
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .photosPicker(isPresented: $isPickerPresented, selection: $pickerItem, matching: .images)
        .onChange(of: pickerItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    selectedUIImage = uiImage
                    selectedImage = Image(uiImage: uiImage)
                    isNavigating = true
                }
            }
        }
        .background(
            NavigationLink(destination: PreviewPage(selectedImage: selectedUIImage), isActive: $isNavigating) {
                EmptyView()
            }
        )
    }
}

#Preview {
    HomePage()
}
