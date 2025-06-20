import SwiftUI

struct OnBoardingView: View {
    // MARK: - Environment Object (Injected PromptController)
    @EnvironmentObject var promptController: PromptController
    
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
                    
                    Button(action: {
                        // Mark onboarding as completed
                        UserPreferencesManager.shared.completeOnboarding()
                    }) {
                        NavigationLink(destination: HomePage().environmentObject(promptController)) {
                        Text("Get Started")
                            .font(.custom("HelveticaNeue", size: 20))
                            .frame(maxWidth : .infinity)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                                .background(Color.P)
                            .cornerRadius(22)
                        }
                    }
                    .padding(.bottom, 80)
                    .padding(.horizontal, 30)
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }.navigationBarBackButtonHidden(true)
    }
}

#Preview {
    OnBoardingView()
        .environmentObject(PromptController())
}
