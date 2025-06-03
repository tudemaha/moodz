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
    @State private var selectedItem: PhotosPickerItem?
    
    var body: some View {
        
        ZStack{
            GeometryReader { geometry in
                Image(.background).ignoresSafeArea().scaledToFit()
                VStack() {
                    Spacer().frame(height: 90)
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
                            .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.7)
                            .foregroundStyle(.white)
                            .cornerRadius(40)
                        
                        Spacer()
                            .frame(height: geometry.size.height * 0.1)
                        
                        PhotosPicker(selection: $selectedItem){
                            VStack(){
                                Spacer().frame(height: 100)
                                ZStack {
                                    Circle()
                                        .foregroundStyle(.accentColorDark)
                                        .frame(height: geometry.size.height * 0.1)
                                    Image(.iconDropPicture)
                                        .resizable()
                                        .frame(width: 55, height: 55)
                                        
                                    
                                }
                                
                                Text("Upload image here")
                                    .font(.system(size: 20, weight: .bold, design: .default))
                                    .foregroundColor(.accentColorDark)
                                
                                Text("Supported formats : jpg, jpeg, and png")
                                    .font(.system(size: 16, weight: .regular, design: .default))
                                    .foregroundColor(.accentColorDark)
                                
                            }
                        }
                    }
                }
                .ignoresSafeArea()
                
            }
        }.toolbarVisibility(Visibility.hidden).background(.accentColorDark).ignoresSafeArea()
        .navigationViewStyle(StackNavigationViewStyle())
        
    }
}


#Preview {
    UploadScreen()
}
