//
//  MenuCopyButton.swift
//  Authenticator
//
//  Created by Kel Reid on 06/29/23
//

import SwiftUI

struct MenuCopyButton: View {

        init(_ text: String) {
                self.text = text
        }

        private let text: String

        var body: some View {
                Button {
                        UIPasteboard.general.string = text
                } label: {
                        Label("Copy", systemImage: "doc.on.doc")
                }
        }
}
