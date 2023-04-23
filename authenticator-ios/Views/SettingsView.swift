//
//  SettingsView.swift
//  authenticator-ios
//
//  Created by Kelvin Reid on 4/19/23.
//

import SwiftUI

struct SettingsView: View {
    @State private var faceIdEnabled = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.gray
                    .opacity(0.1)
                    .ignoresSafeArea()
                VStack {
                    
                    List {
                        NavigationLink(destination: ReleaseNotesView()) {
                            Text("Version 0.0.1")
                        }
                        Toggle(isOn: $faceIdEnabled) {
                            Text("Face ID")
                        }
                        NavigationLink(destination: PrivacyPolicyView()) {
                            Text("Privacy Policy")
                        }
                        NavigationLink(destination: TermsView()) {
                            Text("Terms of Use")
                        }
                    }
                    .listStyle(GroupedListStyle())
                    
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 5)
                        .background(Color.gray.opacity(0.2))
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
