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

        init() {
                UITableView.appearance().sectionFooterHeight = 0
                UITextField.appearance().clearButtonMode = .always
        }
    
        var body: some View {
            TabView {
                // MARK: - Authenticator tab
                NavigationView {
                    VStack {
                        List(selection: $selectedTokens) {
                            ForEach(0..<fetchedTokens.count, id: \.self) { index in
                                let item = fetchedTokens[index]
                                Section {
                                    AuthCodeView(token: token(of: item), totp: $codes[index], timeRemaining: $timeRemaining)
                                }
                            }
                            .onDelete(perform: deleteItems)
                        }
                        // Tab bar color
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 5)
                            .background(Color.gray.opacity(0.3))
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
                    .fileImporter(isPresented: $isFileImporterPresented, allowedContentTypes: [.text, .image], allowsMultipleSelection: false) { result in
                        switch result {
                        case .failure(let error):
                            logger.debug(".fileImporter() failure: \(error.localizedDescription)")
                        case .success(let urls):
                            guard let pickedUrl: URL = urls.first else { return }
                            guard pickedUrl.startAccessingSecurityScopedResource() else { return }
                            let cachePathComponent = Date.currentDateText + pickedUrl.lastPathComponent
                            let cacheUrl: URL = .tmpDirectoryUrl.appendingPathComponent(cachePathComponent)
                            try? FileManager.default.copyItem(at: pickedUrl, to: cacheUrl)
                            pickedUrl.stopAccessingSecurityScopedResource()
                            handlePickedFile(url: cacheUrl)
                        }
                    }
                    .alert(isPresented: $isDeletionAlertPresented) {
                        deletionAlert
                    }
                    
                    // MARK: - Nav bar
                    .navigationBarTitle("Authenticator", displayMode: .inline)
                    .toolbarBackground(.gray .opacity(0.3), for: .navigationBar)
                    .toolbarBackground(.visible, for: .navigationBar)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                presentingSheet = .showSettings
                                isSheetPresented = true
                            }) {
                                Image(systemName: "gear")
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                presentingSheet = .addByScanning
                                isSheetPresented = true
                            }) {
                                Image(systemName: "qrcode")
                            }
                        }
                        
                    }
                    .sheet(isPresented: $isSheetPresented) {
                        switch presentingSheet {
                        case .showSettings:
                            SettingsView(isPresented: $isSheetPresented)
                        case .addByScanning:
                            Scanner(isPresented: $isSheetPresented, codeTypes: [.qr], completion: handleScanning(result:))
                        case .cardDetailView:
                            TokenDetailView(isPresented: $isSheetPresented, token: token(of: fetchedTokens[tokenIndex]))
                        }
                    }
                }
                
                .tabItem {
                    Image(systemName: "lock")
                    Text("Authenticator")
                }
                
                // MARK: - Passwords tab
                NavigationView {
                    PasswordsView()
                        .navigationBarTitle(Text("Passwords"), displayMode: .large)
                        .toolbarBackground(.gray .opacity(0.3), for: .navigationBar)
                        .toolbarBackground(.visible, for: .navigationBar)
                }
                .tabItem {
                    Image(systemName: "key")
                    Text("Passwords")
                }
                .navigationViewStyle(.stack)
            }
            .accentColor(.green) // set the accent color for the navigation links
        }


        // MARK: - Modification
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
                        let nsError = error as NSError
                        logger.debug("\(nsError)")
                }
                generateCodes()
        }
        private func move(from source: IndexSet, to destination: Int) {
                var idArray: [String] = fetchedTokens.map({ $0.id ?? Token().id })
                idArray.move(fromOffsets: source, toOffset: destination)
                for number in 0..<fetchedTokens.count {
                        let item = fetchedTokens[number]
                        if let index = idArray.firstIndex(where: { $0 == item.id }) {
                                if Int64(index) != item.indexNumber {
                                        fetchedTokens[number].indexNumber = Int64(index)
                                }
                        }
                }
                do {
                        try viewContext.save()
                } catch {
                        let nsError = error as NSError
                        logger.debug("Unresolved error \(nsError), \(nsError.userInfo)")
                }
        }

        private func deleteItems(offsets: IndexSet) {
                selectedTokens.removeAll()
                indexSetOnDelete = offsets
                isDeletionAlertPresented = true
        }

        private func cancelDeletion() {
                indexSetOnDelete.removeAll()
                selectedTokens.removeAll()
                isDeletionAlertPresented = false
        }

        private func performDeletion() {
                if !selectedTokens.isEmpty {
                        _ = selectedTokens.map { oneSelection in
                                _ = fetchedTokens.filter({ $0.id == oneSelection.id }).map(viewContext.delete)
                        }
                } else if !indexSetOnDelete.isEmpty {
                        _ = indexSetOnDelete.map({ fetchedTokens[$0] }).map(viewContext.delete)
                } else {
                        viewContext.delete(fetchedTokens[tokenIndex])
                }
                do {
                        try viewContext.save()
                } catch {
                        let nsError = error as NSError
                        logger.debug("Unresolved error \(nsError), \(nsError.userInfo)")
                }
                indexSetOnDelete.removeAll()
                selectedTokens.removeAll()
                isDeletionAlertPresented = false
                generateCodes()
        }
        private var deletionAlert: Alert {
                return Alert(title: Text("Are you sure you want to delete?"),
                             message: Text("You could lose access to your account"),
                             primaryButton: .cancel(cancelDeletion),
                             secondaryButton: .destructive(Text("Delete"), action: performDeletion))
        }


        // MARK: - Account Adding
        private func handleScanning(result: Result<String, ScannerView.ScanError>) {
                isSheetPresented = false
                switch result {
                case .success(let code):
                        let uri: String = code.trimmed()
                        guard !uri.isEmpty else { return }
                        guard let newToken: Token = Token(uri: uri) else { return }
                        addItem(newToken)
                case .failure(let error):
                        logger.debug("\(error.localizedDescription)")
                }
        }
        private func handlePickedFile(url: URL) {
                guard let content: String = url.readText() else { return }
                let lines: [String] = content.components(separatedBy: .newlines)
                _ = lines.map {
                        if let newToken: Token = Token(uri: $0.trimmed()) {
                                addItem(newToken)
                        }
                }
        }


        // MARK: - Functions
        private func token(of tokenData: TokenData) -> Token {
                guard let id: String = tokenData.id,
                      let uri: String = tokenData.uri,
                      let displayIssuer: String = tokenData.displayIssuer,
                      let displayAccountName: String = tokenData.displayAccountName
                else { return Token() }
                guard let token = Token(id: id, uri: uri, displayIssuer: displayIssuer, displayAccountName: displayAccountName) else { return Token() }
                return token
        }
        private func generateCodes() {
                let placeholder: [String] = Array(repeating: String.zeros, count: 30)
                guard !fetchedTokens.isEmpty else {
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

        private func handleAccountEditing(index: Int, issuer: String, account: String) {
                let item: TokenData = fetchedTokens[index]
                if item.displayIssuer != issuer {
                        fetchedTokens[index].displayIssuer = issuer
                }
                if item.displayAccountName != account {
                        fetchedTokens[index].displayAccountName = account
                }
                do {
                        try viewContext.save()
                } catch {
                        let nsError = error as NSError
                        logger.debug("Unresolved error \(nsError), \(nsError.userInfo)")
                }
                isSheetPresented = false
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
        case cardDetailView
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
