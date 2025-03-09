//
//  SplashScreen.swift
//  Watch Any Stream
//
//  Created by Marcél Busschers on 27/11/2024.
//

import SwiftUI

struct SplashScreen: View {
    @State private var isActive = false

    var body: some View {
        if isActive {
            HomeScreen()
        } else {
            ZStack {
                Color(red: 156/255, green: 186/255, blue: 241/255)
                VStack {
                    let logo = UIImage(named: "Logo")
                    if let logo = logo {
                        Image(uiImage: logo)
                            .resizable()
                            .scaledToFit()
                    }
                }
                .onAppear {
                    Task {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            isActive = true
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
    
    func loadAppIcon() -> UIImage? {
        // Get the app icon from the main bundle
        guard let icons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
              let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
              let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
              let iconName = iconFiles.first else {
            return nil
        }
        
        // Load the image from the bundle
        return UIImage(named: iconName)
    }
}

#Preview {
    SplashScreen()
}
