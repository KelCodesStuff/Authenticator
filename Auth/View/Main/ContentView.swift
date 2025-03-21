//
//  ContentView.swift
//  Authenticator
//
//  Created by Kel Reid on 06/29/23
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \TokenData.indexNumber, ascending: true)], animation: .default)
    private var fetchedTokens: FetchedResults<TokenData>
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var timeRemaining: Int = 30 - (Int(Date().timeIntervalSince1970) % 30)
    @State private var codes: [String] = Array(repeating: String.zeros, count: 50)
    @State private var animationTrigger: Bool = false
    @State private var isSheetPresented: Bool = false
    @State private var isFileImporterPresented: Bool = false
    @State private var editMode: EditMode = .inactive
    @State private var selectedTokens = Set<TokenData>()
    @State private var indexSetOnDelete: IndexSet = IndexSet()
    @State private var isDeletionAlertPresented: Bool = false
    @State private var isUnlocked = false
    
    // State variables for error handling
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack {
                List(selection: $selectedTokens) {
                    ForEach(0..<fetchedTokens.count, id: \.self) { index in
                        let item = fetchedTokens[index]
                        Section {
                            AuthCodeView(token: token(of: item), totp: $codes[index], timeRemaining: $timeRemaining, onDelete: {
                                deleteToken(item)
                            })
                        }
                    }
                }
                
            }
            .animation(.default, value: animationTrigger)
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                generateCodes()
                clearTemporaryDirectory()
            }
            .onReceive(timer) { _ in
                timeRemaining = 30 - (Int(Date().timeIntervalSince1970) % 30)
                if timeRemaining == 30 || codes.first == String.zeros {
                    generateCodes()
                }
            }
            .onAppear {
                handleTestTokens()
            }
            
            // MARK: - Nav Bar
            .navigationBarTitle("Authenticator", displayMode: .inline)
            .navigationBarItems(
                leading: settingsButton,
                trailing: HStack {
                    qrCodeButton
                    manualEntryButton
                }
            )
            .toolbarBackground(.visible, for: .navigationBar)
            
            .sheet(isPresented: $isSheetPresented) {
                switch presentingSheet {
                case .showSettings:
                    SettingsView(isPresented: $isSheetPresented)
                case .addByScanning:
                    Scanner(isPresented: $isSheetPresented, codeTypes: [.qr]) { result in
                        isSheetPresented = false
                        if case .success = result {
                            generateCodes()
                        }
                    }
                case .addManually:
                    ManualTokenEntryView(isPresented: $isSheetPresented) { result in
                        isSheetPresented = false
                        if case .success(let uri) = result {
                            if let token = Token(uri: uri) {
                                addItem(token)
                            }
                        }
                    }
                }
            }
        }
        .accentColor(.green)
        
        // Error alert
        .alert(isPresented: $showErrorAlert) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    // MARK: - Settings button
    private var settingsButton: some View {
        Button(action: {
            presentingSheet = .showSettings
            isSheetPresented = true
        }) {
            Image(systemName: "gearshape")
        }
        .accessibilityIdentifier("settingsButton")
        .accessibilityLabel("Settings")
    }
    
    // MARK: - QR Code button
    private var qrCodeButton: some View {
        Button(action: {
            presentingSheet = .addByScanning
            isSheetPresented = true
        }) {
            Image(systemName: "qrcode")
        }
        .accessibilityIdentifier("qrCodeButton")
        .accessibilityLabel("Scan QR Code")
    }
    
    // MARK: - Manual Entry button
    private var manualEntryButton: some View {
        Button(action: {
            presentingSheet = .addManually
            isSheetPresented = true
        }) {
            Image(systemName: "keyboard")
        }
        .accessibilityIdentifier("manualEntryButton")
        .accessibilityLabel("Manual Entry")
    }
    
    // MARK: - Add function
    private func addItem(_ token: Token) {
        let newTokenData = TokenData(context: viewContext)
        newTokenData.id = token.id
        newTokenData.uri = token.uri
        newTokenData.displayIssuer = token.displayIssuer
        newTokenData.displayAccountName = token.displayAccountName
        
        let lastIndexNumber: Int64 = fetchedTokens.last?.indexNumber ?? Int64(fetchedTokens.count)
        newTokenData.indexNumber = lastIndexNumber + 1
        do {
            try viewContext.save()
        } catch {
            showError(error: error)
        }
        generateCodes()
    }
    
    // MARK: - Handle test tokens for UI testing
    private func handleTestTokens() {
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            if let testTokenUri = ProcessInfo.processInfo.environment["TEST_TOKEN_URI"] {
                if let token = Token(uri: testTokenUri) {
                    addItem(token)
                }
            }
        }
        #endif
    }
    
    // MARK: - Delete function
    func deleteToken(_ tokenData: TokenData) {
        viewContext.delete(tokenData)
        do {
            try viewContext.save()
            // Update UI after successful deletion
            generateCodes()
            // Reset any selection state
            selectedTokens.removeAll()
            // Update animation trigger to refresh UI
            animationTrigger.toggle()
        } catch let error as NSError {
            // Handle the error, e.g., showing an alert to the user.
            print("Error deleting token: \(error), \(error.userInfo)")
            showError(error: error)
        }
    }
    
    private func token(of tokenData: TokenData) -> Token {
        guard let id: String = tokenData.id,
              let uri: String = tokenData.uri,
              let displayIssuer: String = tokenData.displayIssuer,
              let displayAccountName: String = tokenData.displayAccountName
                
        else { return Token() }
        guard let token = Token(id: id, uri: uri, displayIssuer: displayIssuer, displayAccountName: displayAccountName)
        else { return Token() }
        
        return token
    }
    
    private func generateCodes() {
        let placeholder: [String] = Array(repeating: String.zeros, count: 30)
        guard !fetchedTokens.isEmpty
                
        else {
            codes = placeholder
            return
        }
        
        let generated: [String] = fetchedTokens.map { code(of: $0) }
        codes = generated + placeholder
        animationTrigger.toggle()
    }
    
    private func code(of tokenData: TokenData) -> String {
        guard let uri: String = tokenData.uri else { return String.zeros }
        guard let token: Token = Token(uri: uri) else { return String.zeros }
        guard let code: String = OTPGenerator.totp(secret: token.secret, algorithm: token.algorithm, digits: token.digits, period: token.period) else { return String.zeros }
        return code
    }
    
    // MARK: - Error alerts
    private func showError(error: Error) {
        errorMessage = error.localizedDescription
        showErrorAlert = true
    }
    
    private var tokensToExport: [Token] {
        return fetchedTokens.map({ token(of: $0) })
    }
    
    private func clearTemporaryDirectory() {
        guard let urls: [URL] = try? FileManager.default.contentsOfDirectory(at: .tmpDirectoryUrl, includingPropertiesForKeys: nil) else { return }
        _ = urls.map { try? FileManager.default.removeItem(at: $0) }
    }
}

private var presentingSheet: SheetSet = .showSettings
private var tokenIndex: Int = 0

private enum SheetSet {
    case showSettings
    case addByScanning
    case addManually
    //        case cardDetailView
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
