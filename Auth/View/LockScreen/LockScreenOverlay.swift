//
//  LockScreenOverlay.swift
//  Authenticator
//
//  Created by Kel Reid on 2/9/24.
//  Copyright © 2024 OneVR LLC. All rights reserved.
//

import SwiftUI

extension View {
    func overlayViewLock(isVisible: Binding<Bool>, duration: TimeInterval = 2.0) -> some View {
        self.overlay(
            Group {
                if isVisible.wrappedValue {
                    // Overlay content goes here
                    ZStack {
                        Color.black.opacity(0.5) // Semi-transparent background
                        VStack {
                            Image(systemName: "lock.fill") // Example image, replace with your asset
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.green)
                            Text("Encrypting Passcode...") // Customizable message
                                .foregroundColor(.green)
                                .padding()
                        }
                        .frame(width: 200, height: 200)
                        .background(Color.gray.opacity(0.8))
                        .cornerRadius(20)
                    }
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                            isVisible.wrappedValue = false
                        }
                    }
                }
            }
        )
    }
    
    func overlayViewUnlock(isVisible: Binding<Bool>, duration: TimeInterval = 3.5) -> some View {
        self.overlay(
            Group {
                if isVisible.wrappedValue {
                    // Overlay content goes here
                    ZStack {
                        Color.black.opacity(0.5) // Semi-transparent background
                        VStack {
                            Image(systemName: "lock.fill") // Example image, replace with your asset
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 80)
                                .foregroundColor(.green)
                            Text("Decrypting Passcode...") // Customizable message
                                .foregroundColor(.green)
                                .padding()
                        }
                        .frame(width: 200, height: 200)
                        .background(Color.gray.opacity(0.8))
                        .cornerRadius(20)
                    }
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                            isVisible.wrappedValue = false
                        }
                    }
                }
            }
        )
    }
}
