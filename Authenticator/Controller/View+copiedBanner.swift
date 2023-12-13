//
//  View+copiedBanner.swift
//  Authenticator
//
//  Created by Kel Reid on 06/29/23
//

import SwiftUI

struct CopiedBannerModifier: ViewModifier {

        @Binding var isPresented: Bool

        func body(content: Content) -> some View {
                ZStack {
                        content
                        if isPresented {
                                Text("Copied")
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 40)
                                        .background(.thinMaterial)
                                        .clipShape(Capsule())
                                        .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
                        }
                }
        }
}

extension View {
        func copiedBanner(isPresented: Binding<Bool>) -> some View {
                self.modifier(CopiedBannerModifier(isPresented: isPresented))
        }
}
