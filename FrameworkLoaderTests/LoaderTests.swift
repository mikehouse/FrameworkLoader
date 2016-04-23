//
//  LoaderTests.swift
//  FrameworkLoader
//
//  Created by mike on 4/22/16.
//  Copyright © 2016 Mikhail Demidov. All rights reserved.
//

import XCTest
@testable import FrameworkLoader

class LoaderTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        NSFileManager.defaultManager().removeAllCustomFrameworks()
    }
    
    override func tearDown() {
        NSFileManager.defaultManager().removeAllCustomFrameworks()
        
        super.tearDown()
    }
    
    func testShouldLoadBundleSuccess() {
        let zipURL = NSBundle(forClass: LoaderTests.self).URLForResource("CoreLocationBundle", withExtension: "zip")!
        let loader = Loader(request: NSURLRequest(URL: zipURL))
        
        XCTAssertEqual(loader.fetchStatus, FetchStatus.Nothing)
        XCTAssertNil(loader.frameworkPath)
        
        let expectation = expectationWithDescription("testShouldLoadBundleSuccess")
        loader.fetchAsync { (error, _) in
            
            XCTAssertNil(error)
            XCTAssertEqual(loader.fetchStatus, FetchStatus.Fetched)
            XCTAssertNotNil(loader.frameworkPath)
            XCTAssertTrue(loader.frameworkPath!.hasSuffix("CoreLocation.framework"))
            
            let bundle = try! loader.tryLoad()
            
            XCTAssertTrue(bundle.bundlePath.hasSuffix("CoreLocation.framework"))
            
            XCTAssertNotNil(Bundle(name: "CoreLocation"))
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(5) { (error) in
            if let er = error {
                print(er)
            }
        }
    }
        
}
