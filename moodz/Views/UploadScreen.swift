//
//  UploadScreen.swift
//  moodz
//
//  Created by Antonia Neumeier on 01/06/25.
//

import SwiftUI
import _PhotosUI_SwiftUI

struct UploadScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedItem: PhotosPickerItem?  // To store the selected photo item
    @State private var selectedUIImage: UIImage? = nil  // Store UIImage for further processing
    @State private var selectedImage: Image?  // SwiftUI Image to display the selected image

    @State private var isNavigating = false  // State to control navigation to Preview

    var body: some View {

        ZStack {
            Image(.background)
                .ignoresSafeArea()
                .scaleEffect(1.3)

            VStack {
                Spacer()
                    .frame(height: 90)
                Image(.moodzLogoWhite)
                    .resizable()
                    .frame(width: 140, height: 40)
                Spacer()
                    .frame(height: 10)

                Text("Every photo holds a feeling — let's Moodz it.")
                    .foregroundStyle(Color.white)
                    .font(.system(size: 17, weight: .regular, design: .default))
                Spacer()
                    .frame(height: 10)

                ZStack {
                    Rectangle()
                        .containerRelativeFrame(.horizontal) { height, _ in
                            height * 0.9
                        }
                        .padding(.bottom, 100)
                        .foregroundStyle(.white)
                        .cornerRadius(40)
                        .shadow(radius: 10)

                    Spacer()
                        .containerRelativeFrame(.vertical) { height, _ in
                            height * 0.1
                        }

                    PhotosPicker(selection: $selectedItem) {
                        VStack {
                            Spacer().frame(height: 100)
                            ZStack {
                                Circle()
                                    .foregroundStyle(.accentColorDark)
                                    .containerRelativeFrame(.vertical) {
                                        height,
                                        _ in height * 0.1
                                    }

                                Image(.iconDropPicture)
                                    .resizable()
                                    .frame(width: 55, height: 55)

                            }

                            Text("Upload image here")
                                .font(
                                    .system(
                                        size: 20,
                                        weight: .bold,
                                        design: .default
                                    )
                                )
                                .foregroundColor(.accentColorDark)

                            Text("Supported formats : jpg, jpeg, and png")
                                .font(
                                    .system(
                                        size: 16,
                                        weight: .regular,
                                        design: .default
                                    )
                                )
                                .foregroundColor(.accentColorDark)

                        }.background(
                            NavigationLink(
                                destination: PreviewPage(
                                    selectedImage: selectedUIImage
                                ),
                                isActive: $isNavigating
                            ) {
                                EmptyView()
                            }
                        )
                    }
                }
            }
            .ignoresSafeArea()
        }.background(.accentColorDark, )
            .toolbarVisibility(Visibility.hidden)
            .ignoresSafeArea()
            .navigationViewStyle(StackNavigationViewStyle())

    }
}

#Preview {
    UploadScreen()
}
