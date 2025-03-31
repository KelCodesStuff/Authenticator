//
//  AuthCodeView.swift
//  Authenticator
//
//  Created by Kel Reid on 06/29/23
//

import SwiftUI

/// A view that displays an authentication code along with issuer information and a countdown timer
struct TokenView: View {
    // MARK: - Properties
    
    /// The token containing issuer and account information
    let token: Token
    
    /// The current TOTP code, bound to parent view
    @Binding var totp: String
    /// The time remaining before code refresh, bound to parent view
    @Binding var timeRemaining: Int
    
    /// Closure called when token deletion is requested
    var onDelete: () -> Void
    /// Closure called when token is edited
    var onEdit: (String, String) -> Void

    // MARK: - Private State
    
    /// Controls visibility of the "Copied" banner
    @State private var isBannerPresented: Bool = false
    /// Controls visibility of the edit view
    @State private var isEditViewPresented: Bool = false
    /// Controls visibility of the delete confirmation alert
    @State private var showingDeleteAlert: Bool = false

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
            }
            
            // TOTP code and account info
            VStack(spacing: 2) {
                HStack {
                    Text(verbatim: formattedTotp).font(.largeTitle.monospacedDigit())
                    .frame(maxWidth: .infinity, alignment: .center)
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
                HStack {
                    Text(verbatim: token.displayAccountName).font(.footnote)
                    Spacer()
                }
            }
            .contentShape(Rectangle())
            // Copy code on tap
            .onTapGesture {
                UIPasteboard.general.string = totp
                guard !isBannerPresented else { return }
                isBannerPresented = true
                // Log when user copies the token code by tapping
                AnalyticsService.shared.logEvent(.tokenCopied)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    isBannerPresented = false
                }
            }
            // Context menu for long press
            .contextMenu {
                Button(action: {
                    UIPasteboard.general.string = totp
                    guard !isBannerPresented else { return }
                    isBannerPresented = true
                    // Log both the copy event and the context menu usage
                    AnalyticsService.shared.logEvent(.tokenCopied)
                    AnalyticsService.shared.logContextMenuAction(action: "copy")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        isBannerPresented = false
                    }
                }) {
                    Label("Copy", systemImage: "doc.on.doc")
                }
                
                Button(action: {
                    isEditViewPresented = true
                    // Log both the edit event and the context menu usage
                    AnalyticsService.shared.logEvent(.tokenEdited)
                    AnalyticsService.shared.logContextMenuAction(action: "edit")
                }) {
                    Label("Edit", systemImage: "pencil")
                }
                
                Button(role: .destructive, action: {
                    showingDeleteAlert = true
                    // Log both the context menu usage and the alert being shown
                    AnalyticsService.shared.logContextMenuAction(action: "delete")
                    AnalyticsService.shared.logAlertShown(type: "delete_confirmation")
                }) {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
        .copiedBanner(isPresented: $isBannerPresented)
        .animation(.default, value: isBannerPresented)
        // Delete alert
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("Delete Account"),
                message: Text("Are you sure you want to delete this account? You will not be able to use this device to verify your identity."),
                primaryButton: .destructive(Text("Delete")) {
                    // Log when user confirms token deletion
                    AnalyticsService.shared.logEvent(.tokenDeleted)
                    onDelete()
                },
                secondaryButton: .cancel()
            )
        }
        // Add sheet presentation for edit view
        .sheet(isPresented: $isEditViewPresented) {
            TokenEditView(
                token: token,
                onDelete: {
                    // Log when user deletes token from edit view
                    AnalyticsService.shared.logEvent(.tokenDeleted)
                    onDelete()
                },
                onSave: { issuer, accountName in
                    // Log when user saves token edits
                    AnalyticsService.shared.logEvent(.tokenEdited)
                    // Call the onEdit callback with the new values
                    onEdit(issuer, accountName)
                }
            )
        }
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
