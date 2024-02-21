//
//  EditPasswordView.swift
//  Auth
//
//  Created by Kelvin Reid on 2/7/24.
//  Copyright © 2024 Studio757 LLC. All rights reserved.
//

import SwiftUI

struct EditPasswordView: View {
    @Binding var credential: Credential
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Website")) {
                    TextField("Website", text: $credential.website)
                }
                Section(header: Text("Username")) {
                    TextField("Username", text: $credential.username)
                }
                Section(header: Text("Password")) {
                    TextField("Username", text: $credential.password)
                }
                // Add more fields as necessary (e.g., password)
            }
            .navigationBarTitle("Edit Password", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save") {
                // Add save action here
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
