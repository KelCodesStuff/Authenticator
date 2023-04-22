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
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
