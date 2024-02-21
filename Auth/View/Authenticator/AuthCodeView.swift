//
//  AuthCodeView.swift
//  Authenticator
//
//  Created by Kel Reid on 06/29/23
//

import SwiftUI

struct AuthCodeView: View {
    let token: Token
    
    @Binding var totp: String
    @Binding var timeRemaining: Int
    
    var onDelete: () -> Void // Closure to handle deletion

    @State private var isBannerPresented: Bool = false
    @State private var isEditViewPresented: Bool = false

    private let diameter: CGFloat = 32

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 16) {
                issuerImage.resizable().scaledToFit().frame(width: diameter, height: diameter)
                Text(verbatim: token.displayIssuer).font(.headline)
                Spacer()
                
                Button(action: {
                    isEditViewPresented = true
                }) {
                    Image(systemName: "ellipsis.circle")
                }
                .sheet(isPresented: $isEditViewPresented) {
                    AuthCodeEditView(token: token, onDelete: {
                        onDelete() // This calls the deletion logic passed from the parent view
                    })
                }
            }
            VStack(spacing: 4) {
                HStack {
                    Text(verbatim: formattedTotp).font(.largeTitle.monospacedDigit())
                    .frame(maxWidth: .infinity, alignment: .center)
                    Spacer()
                }
                HStack {
                    Text(verbatim: token.displayAccountName).font(.footnote)
                    Spacer()
                    ZStack {
                        Circle().stroke(Color.primary.opacity(0.2), lineWidth: 2).frame(width: diameter, height: diameter)
                        CustomCircle(startAngle: .degrees(-90), endAngle: .degrees(endAngle), clockwise: true).stroke(lineWidth: 2).frame(width: diameter, height: diameter)
                        Text(verbatim: timeRemaining.description).font(.footnote.monospacedDigit())
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                UIPasteboard.general.string = totp
                guard !isBannerPresented else { return }
                isBannerPresented = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        isBannerPresented = false
                }
            }
        }
        .copiedBanner(isPresented: $isBannerPresented)
        .animation(.default, value: isBannerPresented)
    }

    private var formattedTotp: String {
        var code: String = totp
        switch code.count {
        case 6:
                code.insert(" ", at: code.index(code.startIndex, offsetBy: 3))
        case 8:
                code.insert(" ", at: code.index(code.startIndex, offsetBy: 4))
        default:
                break
        }
        return code
    }

    private var issuerImage: Image {
        let imageName: String = {
            let issuer: String = token.displayIssuer.lowercased()
            switch issuer {
            case "apple account":
                    return "apple"
            case "google account":
                    return "google"
            case "playstation account":
                    return "playstation"
            case "github account":
                    return "github"
            case "reddit account":
                    return "reddit"
            default:
                    return issuer
            }
        }()
            guard !imageName.isEmpty else { return Image(systemName: "person.circle") }
            guard let uiImage: UIImage = UIImage(named: imageName) else { return Image(systemName: "person.circle") }
            return Image(uiImage: uiImage)
    }
    
    private var endAngle: Double {
        return Double((30 - timeRemaining) * 12 - 89)
    }
}

private struct CustomCircle: Shape {
    let startAngle: Angle
    let endAngle: Angle
    let clockwise: Bool
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2.0, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)
        return path
    }
}
