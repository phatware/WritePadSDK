//
//  WritePadSDK_Sample_SwiftTests.swift
//  WritePadSDK-Sample-SwiftTests
//
//  Created by Stanislav Miasnikov on 4/19/15.
//  Copyright (c) 2015 PhatWare Corp. All rights reserved.
//

import UIKit
import XCTest

import WritePadSDK_Sample_Swift

class WritePadSDK_Sample_SwiftTests: XCTestCase {
    
    override func setUp()
    {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown()
    {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRecognizerLanguages()
    {
        let recognizer = RecognizerManager.sharedManager()
        
        recognizer.reloadRecognizerForLanguage( WPLanguageGerman )
        XCTAssertTrue(recognizer.isEnabled(), "Recognizer for German is not loaded!")
        recognizer.reloadRecognizerForLanguage( WPLanguageFrench )
        XCTAssertTrue(recognizer.isEnabled(), "Recognizer for French is not loaded!")
        recognizer.reloadRecognizerForLanguage( WPLanguageSpanish )
        XCTAssertTrue(recognizer.isEnabled(), "Recognizer for Spanish is not loaded!")
        recognizer.reloadRecognizerForLanguage( WPLanguagePortuguese )
        XCTAssertTrue(recognizer.isEnabled(), "Recognizer for Portuguese is not loaded!")
        recognizer.reloadRecognizerForLanguage( WPLanguageBrazilian )
        XCTAssertTrue(recognizer.isEnabled(), "Recognizer for Brazilian is not loaded!")
        recognizer.reloadRecognizerForLanguage( WPLanguageIndonesian )
        XCTAssertTrue(recognizer.isEnabled(), "Recognizer for Indonesian is not loaded!")
        recognizer.reloadRecognizerForLanguage( WPLanguageIndonesian )
        XCTAssertTrue(recognizer.isEnabled(), "Recognizer for Indonesian is not loaded!")
        recognizer.reloadRecognizerForLanguage( WPLanguageFinnish )
        XCTAssertTrue(recognizer.isEnabled(), "Recognizer for Finnish is not loaded!")
        recognizer.reloadRecognizerForLanguage( WPLanguageNorwegian )
        XCTAssertTrue(recognizer.isEnabled(), "Recognizer for Norwegian is not loaded!")
        recognizer.reloadRecognizerForLanguage( WPLanguageSwedish )
        XCTAssertTrue(recognizer.isEnabled(), "Recognizer for Swedish is not loaded!")
        recognizer.reloadRecognizerForLanguage( WPLanguageEnglishUK )
        XCTAssertTrue(recognizer.isEnabled(), "Recognizer for English UK is not loaded!")
        recognizer.reloadRecognizerForLanguage( WPLanguageEnglishUS )
        XCTAssertTrue(recognizer.isEnabled(), "Recognizer for English US is not loaded!")
        recognizer.reloadRecognizerForLanguage( WPLanguageDanish )
        XCTAssertTrue(recognizer.isEnabled(), "Recognizer for Danish is not loaded!")
        recognizer.reloadRecognizerForLanguage( WPLanguageDutch )
        XCTAssertTrue(recognizer.isEnabled(), "Recognizer for Dutch is not loaded!")
        recognizer.reloadRecognizerForLanguage( WPLanguageItalian )
        XCTAssertTrue(recognizer.isEnabled(), "Recognizer for Italian is not loaded!")
        // This is an example of a functional test case.
    }
    
    func testPerformanceReloadSettings()
    {
        // This is an example of a performance test case.
        self.measureBlock() {
            let recognizer = RecognizerManager.sharedManager()
            recognizer.reloadSettings()
            // Put the code you want to measure the time of here.
        }
    }
    
}
