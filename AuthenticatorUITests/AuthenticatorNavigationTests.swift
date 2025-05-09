//
//  AuthenticatorNavigationTests.swift
//  Authenticator
//
//  Created by Kel Reid on 3/22/25.
//  Copyright © 2025 OneVR LLC. All rights reserved.
//

import XCTest

final class AuthenticatorNavigationTests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments = ["UI-Testing"]
        
        // Enable biometric authentication in simulator
        if #available(iOS 13.0, *) {
            app.launchEnvironment["XCUITest_FASTLANE_SKIP_BIOMETRICS"] = "false"
        }
        
        // Add test token before launching the app
        let secret = "JBSWY3DPEHPK3PXP"
        let uri = "otpauth://totp/Test%20Service:test@example.com?secret=\(secret)&issuer=Test%20Service"
        app.launchEnvironment["TEST_TOKEN_URI"] = uri
        
        app.launch()
    }
    
    override func tearDownWithError() throws {
        // Only tear down if setup was actually performed
        if app != nil {
            app = nil
        }
    }
    
    // MARK: - Helper Methods
    private func unlockApp() throws {
        let app = XCUIApplication()
        
        // Check if SetPasscodeView is present
        if app.navigationBars["Set Passcode"].exists {
            // Set a passcode
            let passcodeField1 = app.secureTextFields["Passcode"]
            passcodeField1.tap()
            passcodeField1.typeText("12345678")
            
            let passcodeField2 = app.secureTextFields["Confirm passcode"]
            passcodeField2.tap()
            passcodeField2.typeText("12345678")
            
            app.buttons["Start"].tap()
        }
        
        // Input Passcode View
        let passcodeField = app.secureTextFields["Passcode"]
        passcodeField.tap()
        passcodeField.typeText("12345678")
        
        let unlockButton = app.buttons["Unlock"]
        
        // Wait for unlock button to be enabled
        let startTime = Date()
        let timeout: TimeInterval = 20
        while !unlockButton.exists {
            if Date().timeIntervalSince(startTime) > timeout {
                XCTFail("Unlock button did not appear after \(timeout) seconds")
                return
            }
            sleep(1)
        }
        
        unlockButton.tap()
        
        // Wait for main view to appear
        let navBarTitle = app.staticTexts["Authenticator"]
        let navBarTitleLoaded = navBarTitle.waitForExistence(timeout: 15)
        XCTAssertTrue(navBarTitleLoaded, "Navigation bar title did not load in time")
    }
    
    // MARK: - Navigation Tests    
    func testTabBarNavigation() throws {
        try unlockApp()
        
        // Verify we're on the Tokens tab
        XCTAssertTrue(app.tabBars.buttons["Tokens"].isSelected)
        
        // Tap the Settings tab
        app.tabBars.buttons["Settings"].tap()
        
        // Verify we're on the Settings tab
        XCTAssertTrue(app.tabBars.buttons["Settings"].isSelected)
        XCTAssertTrue(app.navigationBars["Settings"].exists)
        
        // Tap back to Tokens tab
        app.tabBars.buttons["Authenticator"].tap()
        
        // Verify we're back on the Tokens tab
        XCTAssertTrue(app.tabBars.buttons["Codes"].isSelected)
        XCTAssertTrue(app.navigationBars["Authenticator"].exists)
    }
    
}
