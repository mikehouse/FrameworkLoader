//
//  ReflectionTests.swift
//  FrameworkLoader
//
//  Created by mike on 4/23/16.
//  Copyright © 2016 Mikhail Demidov. All rights reserved.
//

import XCTest
@testable import FrameworkLoader

class ReflectionFake: NSObject {
    
    static var gotCalled = false
    static var gotObj: AnyObject?
    static var gotMethod = ""
    
    static func reset() {
        gotObj = nil
        gotMethod = ""
        gotCalled = false
    }
    
    func instanceMethod1() {
        ReflectionFake.gotCalled = true
        ReflectionFake.gotMethod = "instanceMethod1"
    }
    
    func instanceMethod2(arg: AnyObject?) {
        ReflectionFake.gotCalled = true
        ReflectionFake.gotMethod = "instanceMethod2:"
        ReflectionFake.gotObj = arg
    }
    
    static func classMethod1() {
        ReflectionFake.gotCalled = true
        ReflectionFake.gotMethod = "classMethod1"
    }
    
    static func classMethod2(arg: AnyObject?) {
        ReflectionFake.gotCalled = true
        ReflectionFake.gotMethod = "classMethod2:"
        ReflectionFake.gotObj = arg
    }
    
}

class ReflectionTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        ReflectionFake.reset()
    }
    
    func testInstanceReflection() {
        let method = try! Reflection.instanceMethod(NSSelectorFromString("instanceMethod1"), cls: ReflectionFake.self)
        method()
        
        XCTAssertEqual(ReflectionFake.gotMethod, "instanceMethod1")
        XCTAssertTrue(ReflectionFake.gotCalled)
    }
    
    func testInstanceReflectionWithArgs() {
        let method = try! Reflection.instanceMethodWithArg(NSSelectorFromString("instanceMethod2:"), cls: ReflectionFake.self)
        method("fake1")
        
        XCTAssertEqual(ReflectionFake.gotMethod, "instanceMethod2:")
        XCTAssertTrue(ReflectionFake.gotCalled)
        XCTAssertEqual(ReflectionFake.gotObj as? String, "fake1")
    }
    
    func testClassReflection() {
        let method = try! Reflection.classMethod(NSSelectorFromString("classMethod1"), cls: ReflectionFake.self)
        method()
        
        XCTAssertEqual(ReflectionFake.gotMethod, "classMethod1")
        XCTAssertTrue(ReflectionFake.gotCalled)
    }
    
    func testClassReflectionWithArgs() {
        let method = try! Reflection.classMethodWithArg(NSSelectorFromString("classMethod2:"), cls: ReflectionFake.self)
        method("fake2")
        
        XCTAssertEqual(ReflectionFake.gotMethod, "classMethod2:")
        XCTAssertTrue(ReflectionFake.gotCalled)
        XCTAssertEqual(ReflectionFake.gotObj as? String, "fake2")
    }
    
}
