//
//  AuthenticatorUITests.swift
//  AuthenticatorUITests
//
//  Created by Kelvin Reid on 3/15/25.
//  Copyright © 2025 OneVR LLC. All rights reserved.
//

import XCTest

final class AuthenticatorUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // Launch the app before each test
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        app.launch()
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        app.terminate()
    }
    
    // MARK: - Basic UI Tests
    
    func testAppLaunch() throws {
        // Verify the app launches successfully
        XCTAssertTrue(app.waitForExistence(timeout: 5))
    }
    
    func testNavigation() throws {
        // Verify navigation bar exists
        let navigationBar = app.navigationBars["Authenticator"]
        XCTAssertTrue(navigationBar.exists)
        
        // Test settings button
        let settingsButton = navigationBar.buttons["gear"]
        XCTAssertTrue(settingsButton.exists)
        settingsButton.tap()
        
        // Verify settings view appears
        let settingsView = app.navigationBars["Settings"]
        XCTAssertTrue(settingsView.waitForExistence(timeout: 5))
        
        // Test done button to dismiss settings
        let doneButton = settingsView.buttons["Done"]
        XCTAssertTrue(doneButton.exists)
        doneButton.tap()
    }
    
    // MARK: - Authenticator Tests
    
    func testAddNewToken() throws {
        // Tap QR code button
        let qrButton = app.navigationBars.buttons["qrcode"]
        XCTAssertTrue(qrButton.exists)
        qrButton.tap()
        
        // Verify scanner sheet appears
        let scannerSheet = app.sheets["Scanning"]
        XCTAssertTrue(scannerSheet.waitForExistence(timeout: 5))
        
        // Test cancel button
        let cancelButton = scannerSheet.buttons["Cancel"]
        XCTAssertTrue(cancelButton.exists)
        cancelButton.tap()
    }
    
    func testTokenList() throws {
        // Verify token list exists
        let tokenList = app.tables.element
        XCTAssertTrue(tokenList.exists)
        
        // Test token cell interaction if any exist
        let firstToken = tokenList.cells.element(boundBy: 0)
        if firstToken.exists {
            firstToken.tap()
            
            // Verify token details view appears
            let detailsView = app.navigationBars["One-Time Password"]
            XCTAssertTrue(detailsView.waitForExistence(timeout: 5))
            
            // Test back button
            let backButton = detailsView.buttons["Authenticator"]
            XCTAssertTrue(backButton.exists)
            backButton.tap()
        }
    }
    
    // MARK: - Settings Tests
    
    func testSettingsNavigation() throws {
        // Open settings
        app.navigationBars.buttons["gear"].tap()
        
        // Verify settings options
        let settingsTable = app.tables.element
        XCTAssertTrue(settingsTable.exists)
        
        // Test biometric settings if available
        let biometricToggle = settingsTable.switches["Face ID"]
        if biometricToggle.exists {
            biometricToggle.tap()
            
            // Verify biometric verification sheet appears
            let verificationSheet = app.sheets["FaceID"]
            XCTAssertTrue(verificationSheet.waitForExistence(timeout: 5))
            
            // Test cancel button
            let cancelButton = verificationSheet.buttons["Cancel"]
            XCTAssertTrue(cancelButton.exists)
            cancelButton.tap()
        }
    }
    
    // MARK: - Performance Tests
    
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
    
    func testTokenListScrollingPerformance() throws {
        // Measure scrolling performance
        let tokenList = app.tables.element
        measure(metrics: [XCTClockMetric()]) {
            tokenList.swipeUp(velocity: .fast)
            tokenList.swipeDown(velocity: .fast)
        }
    }
}
