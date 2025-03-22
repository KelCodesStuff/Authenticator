//
//  AuthCodeView.swift
//  Authenticator
//
//  Created by Kel Reid on 06/29/23
//

import SwiftUI

/// A view that displays an authentication code along with issuer information and a countdown timer
struct AuthCodeView: View {
    // MARK: - Properties
    
    /// The token containing issuer and account information
    let token: Token
    
    /// The current TOTP code, bound to parent view
    @Binding var totp: String
    /// The time remaining before code refresh, bound to parent view
    @Binding var timeRemaining: Int
    
    /// Closure called when token deletion is requested
    var onDelete: () -> Void

    // MARK: - Private State
    
    /// Controls visibility of the "Copied" banner
    @State private var isBannerPresented: Bool = false
    /// Controls visibility of the edit view
    @State private var isEditViewPresented: Bool = false

    /// Diameter used for circular UI elements
    private let diameter: CGFloat = 32

    // MARK: - Body
    var body: some View {
        VStack(spacing: 2) {
            // Top row with issuer info and edit button
            HStack(spacing: 16) {
                issuerImage.resizable().scaledToFit().frame(width: diameter, height: diameter)
                Text(verbatim: token.displayIssuer).font(.headline)
                Spacer()
                
                Button(action: {
                    isEditViewPresented = true
                }) {
                    Image(systemName: "ellipsis.circle")
                        .imageScale(.large)
                }
                .sheet(isPresented: $isEditViewPresented) {
                    AuthCodeEditView(token: token, onDelete: {
                        onDelete() // This calls the deletion logic passed from the parent view
                    })
                }
            }
            
            // TOTP code and account info
            VStack(spacing: 2) {
                HStack {
                    Text(verbatim: formattedTotp).font(.largeTitle.monospacedDigit())
                    .frame(maxWidth: .infinity, alignment: .center)
                    Spacer()
                }
                HStack {
                    Text(verbatim: token.displayAccountName).font(.footnote)
                    Spacer()
                    // Enhanced countdown timer circle
                    ZStack {
                        // Background circle
                        Circle()
                            .stroke(Color.primary.opacity(0.1), lineWidth: 2)
                            .frame(width: diameter, height: diameter)
                        
                        // Animated progress circle
                        Circle()
                            .trim(from: 0, to: CGFloat(timeRemaining) / 30)
                            .stroke(
                                timerColor,
                                style: StrokeStyle(
                                    lineWidth: 2,
                                    lineCap: .round,
                                    lineJoin: .round
                                )
                            )
                            .frame(width: diameter, height: diameter)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 1), value: timeRemaining)
                        
                        // Time remaining text
                        Text(verbatim: timeRemaining.description)
                            .font(.footnote.monospacedDigit())
                            .foregroundColor(timerColor)
                    }
                }
            }
            .contentShape(Rectangle())
            // Copy code on tap
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

    // MARK: - Private Methods
    
    /// Returns the appropriate color for the timer based on time remaining
    private var timerColor: Color {
        switch timeRemaining {
        case 0...5:
            return .red
        case 6...10:
            return .yellow
        default:
            return .green
        }
    }
    
    /// Formats the TOTP code by inserting spaces for readability
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

    /// Returns an appropriate image for the issuer, falling back to a default if none exists
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
}

/// A custom shape that draws an arc for the countdown timer
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
