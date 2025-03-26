//
//  LockScreenOverlay.swift
//  Authenticator
//
//  Created by Kel Reid on 2/9/24.
//  Copyright © 2024 OneVR LLC. All rights reserved.
//

import SwiftUI

extension View {
    // Overlay view shown when locking the app
    // Parameters:
    // - isVisible: Binding to control visibility of overlay
    // - showAlert: Binding to control alert visibility
    // - duration: How long to show the overlay (defaults to 2 seconds)
    func overlayViewLock(isVisible: Binding<Bool>, showAlert: Binding<Bool>, duration: TimeInterval = 2.0) -> some View {
        self.fullScreenCover(isPresented: isVisible) {
            // Dark semi-transparent background
            ZStack {
                Color.gray.opacity(0.5)
                // Lock icon and text
                VStack {
                    Image(systemName: "lock.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.green)
                    Text("Encrypting Passcode...")
                        .foregroundColor(.green)
                        .padding()
                }
            }
            // Apply styling and animations
            .background(Color.gray.opacity(0.5))
            .ignoresSafeArea()
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .animation(.easeOut(duration: 0.15), value: isVisible.wrappedValue)
            // Show error alert if needed
            .alert("Incorrect Passcode", isPresented: showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please try again")
            }
            // Auto-dismiss after duration
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    isVisible.wrappedValue = false
                }
            }
        }
    }
    
    // Overlay view shown when unlocking the app
    // Parameters:
    // - isVisible: Binding to control visibility of overlay  
    // - showAlert: Binding to control alert visibility
    // - duration: How long to show the overlay (defaults to 3.5 seconds)
    func overlayViewUnlock(isVisible: Binding<Bool>, showAlert: Binding<Bool>, duration: TimeInterval = 3.5) -> some View {
        self.fullScreenCover(isPresented: isVisible) {
            // Dark semi-transparent background
            ZStack {
                Color.gray.opacity(0.5)
                // Lock icon and text
                VStack {
                    Image(systemName: "lock.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.green)
                    Text("Decrypting Passcode...")
                        .foregroundColor(.green)
                        .padding()
                }
            }
            // Apply styling and animations
            .background(Color.gray.opacity(0.5))
            .ignoresSafeArea()
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .animation(.easeOut(duration: 0.15), value: isVisible.wrappedValue)
            // Show error alert if needed
            .alert("Incorrect Passcode", isPresented: showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please try again")
            }
            // Auto-dismiss after duration
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    isVisible.wrappedValue = false
                }
            }
        }
    }
    
    // Overlay view shown when changing passcode
    // Parameters:
    // - isVisible: Binding to control visibility of overlay
    // - showAlert: Binding to control alert visibility  
    // - duration: How long to show the overlay (defaults to 2 seconds)
    func overlayViewChangePasscode(isVisible: Binding<Bool>, showAlert: Binding<Bool>, duration: TimeInterval = 2.0) -> some View {
        self.fullScreenCover(isPresented: isVisible) {
            // Dark semi-transparent background
            ZStack {
                Color.black.opacity(0.5)
                // Lock icon and text
                VStack {
                    Image(systemName: "lock.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.green)
                    Text("Changing Passcode...")
                        .foregroundColor(.green)
                        .padding()
                }
            }
            // Apply styling and animations
            .background(Color.black.opacity(0.5))
            .ignoresSafeArea()
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .animation(.easeOut(duration: 0.15), value: isVisible.wrappedValue)
            // Show error alert if needed
            .alert("Incorrect Passcode", isPresented: showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please try again")
            }
            // Auto-dismiss after duration
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    isVisible.wrappedValue = false
                }
            }
        }
    }
}
