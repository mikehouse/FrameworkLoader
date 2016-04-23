//
//  FrameworkLoaderTests.swift
//  FrameworkLoaderTests
//
//  Created by mike on 4/21/16.
//  Copyright © 2016 Mikhail Demidov. All rights reserved.
//

import XCTest
@testable import FrameworkLoader

class BundleTests: XCTestCase {
    
    func testBundleGetters() {
        let bundleTarget = NSBundle(forClass: BundleTests.self)
        let bundle = Bundle(bundle: bundleTarget)
        
        XCTAssertNotNil(bundle.loadClass(NSStringFromClass(BundleTests)))
        XCTAssertNotNil(bundle.pathForResource("Fake", ofType: "txt"))
        XCTAssertTrue(bundle.bundlePath.hasSuffix("FrameworkLoaderTests.xctest"))
    }
    
}
