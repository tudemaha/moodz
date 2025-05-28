import SwiftUI

struct OnBoardingView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Image("Background_onboarding")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack {
                    
                    Spacer().frame(height: 510)
                    
                    Text("Match")
                        .font(.custom("HelveticaNeue", size: 20))
                        .foregroundColor(.white)
                        .tracking(5)
                        .padding(.bottom, 12)
                    
                    Image("logo_C")
                    
                    Text("Music")
                        .font(.custom("HelveticaNeue", size: 20))
                        .foregroundColor(.white)
                        .tracking(5)
                        .padding(.top, 12)
                    
                    Spacer()
                    
                    NavigationLink(destination: HomePage()) {
                        Text("Get Started")
                            .font(.custom("HelveticaNeue", size: 20))
                            .frame(maxWidth : .infinity)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .background(Color.P) // You can change this to your desired color
                            .cornerRadius(22)
                    }
                    .padding(.bottom, 80)
                    .padding(.horizontal, 30)
                    .buttonStyle(PlainButtonStyle()) // Optional: Keeps button styling intact
                }
            }
        }.navigationBarBackButtonHidden(true)
    }
}

#Preview {
    OnBoardingView()
}
