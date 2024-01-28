//
//  PasswordCardView.swift
//  Authenticator
//
//  Created by Kelvin Reid on 1/27/24.
//  Copyright © 2024 Studio757 LLC. All rights reserved.
//

import SwiftUI
import Foundation

struct PasswordCardView: View {
    var credential: Credential

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(credential.website).font(.headline)
                Text(credential.username).font(.subheadline)
            }
            Spacer()
            Button(action: {
                UIPasteboard.general.string = credential.password
            }) {
                Image(systemName: "doc.on.clipboard")
            }
        }
    }
}
