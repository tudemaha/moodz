//
//  ContentView.swift
//  moodz
//
//  Created by Tude Maha on 21/05/2025.
//


import SwiftUI

struct LandingPage: View {
    var body: some View {
        NavigationStack{
        ZStack (alignment: .top){
                    Image(.backgroundFoto)
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                        .containerRelativeFrame(.vertical) {height, _ in height * 1}
                        
                    
                    VStack(alignment: .center) {
                        Spacer().containerRelativeFrame(.vertical) { height, _ in height * 0.55
                        }
                        Text("Match")
                            .font(.custom("HelveticaNeue", size: 16))
                            .foregroundColor(.white)
                            .tracking(5)
                    
                        Image(.moodzLogo)
                            .resizable()
                            .frame(width: 200, height: 60)
                        Spacer()
                            .frame(height: 10)
                        Text("Music")
                            .font(.custom("HelveticaNeue", size: 16))
                            .foregroundColor(.white)
                            .tracking(5)
                    
                        Spacer().containerRelativeFrame(.vertical) {height, _ in height * 0.15}
                        
                        NavigationLink(destination: UploadScreen())
                        {
                            Text("Get Started")
                                .font(.custom("HelveticaNeue", size: 20)).bold()
                                .foregroundColor(.white)
                                .containerRelativeFrame(.horizontal, alignment: .center) { width, _ in width * 0.8 }
                                .padding(.vertical, 10)
                                .background(Color.accentColorLight)
                                .cornerRadius(25)
                        }
                        
                        
                    }
                }
            }
        }
    }


#Preview {
    LandingPage()
}
