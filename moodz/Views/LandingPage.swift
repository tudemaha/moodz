//
//  ContentView.swift
//  moodz
//
//  Created by Tude Maha on 21/05/2025.
//


import SwiftUI

struct LandingPage: View {
    
    var body: some View {
        ZStack {
            NavigationStack{
                GeometryReader { geometry in
                    Image(.backgroundFoto)
                        .resizable()
                        .ignoresSafeArea()
                    
                    
                    VStack(alignment: .center) {
                        Spacer().frame(height: geometry.size.height * 0.55)
                        Text("Match")
                            .font(.system(size: 16, weight: .medium, design: .default))
                            .foregroundColor(Color.white)
                        
                        Image(.moodzLogo)
                            .resizable()
                            .frame(width: 200, height: 60)
                        Spacer()
                            .frame(height: 10)
                        Text("Music")
                            .font(.system(size: 16, weight: .medium, design: .default))
                            .foregroundColor(Color.white)
                        
                        Spacer().frame(height: geometry.size.height * 0.15)
                        
                        
                        NavigationLink(destination: UploadScreen())
                        {
                            Text("Get Started")
                                .font(.system(size: 20, weight: .bold, design: .default))
                                .foregroundColor(Color.white)
                                .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.05, alignment: .center)
                                .background(Color.accentColorLight)
                                .cornerRadius(25)
                        }
                        
                        
                    }.padding(geometry.size.width * 0.1)
                }.ignoresSafeArea()
            }
        }
    }
}

#Preview {
    LandingPage()
}
