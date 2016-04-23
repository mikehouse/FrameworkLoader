//
//  Reflection.swift
//  FrameworkLoader
//
//  Created by mike on 4/22/16.
//  Copyright © 2016 Mikhail Demidov. All rights reserved.
//

import UIKit

public enum ReflectionError: ErrorType {
    
    case SelectorNotFound(Selector, AnyClass)
    case ClassNotConformNSObjectType // Reflection works for swift classes that are inherited from NSObject class only
    
}

public class Reflection: NSObject {
    
    /// Instance reflection
    
    public static func instanceMethod(sel: Selector, cls: AnyClass) throws -> () -> Void {
        let fn = try internalInstanceMethod(sel, cls: cls)
        return { fn(nil) }
    }
    
    public static func instanceMethodWithArg(sel: Selector, cls: AnyClass) throws -> (AnyObject?) -> Void {
        return try internalInstanceMethod(sel, cls: cls)
    }
    
    private static func internalInstanceMethod(sel: Selector, cls: AnyClass) throws -> (AnyObject?) -> Void {
        guard cls is NSObject.Type else {
            throw ReflectionError.ClassNotConformNSObjectType
        }
        
        let method = class_getInstanceMethod(cls, sel)
        guard method != nil else {
            throw ReflectionError.SelectorNotFound(sel, cls)
        }
        
        let obj = (cls as! NSObject.Type ).init()
        return { arg in obj.performSelector(sel, onThread: NSThread.currentThread(), withObject: arg, waitUntilDone: true) }
    }
    
    /// Class reflection
    
    public static func classMethod(sel: Selector, cls: AnyClass) throws -> () -> Void {
        let fn = try internalClassMethod(sel, cls: cls)
        return { fn(nil) }
    }
    
    public static func classMethodWithArg(sel: Selector, cls: AnyClass) throws -> (AnyObject?) -> Void {
        return try internalClassMethod(sel, cls: cls)
    }
    
    private static func internalClassMethod(sel: Selector, cls: AnyClass) throws -> (AnyObject?) -> Void {
        guard cls is NSObject.Type else {
            throw ReflectionError.ClassNotConformNSObjectType
        }
        
        let method = class_getClassMethod(cls, sel)
        guard method != nil else {
            throw ReflectionError.SelectorNotFound(sel, cls)
        }
        
        return { arg in (cls as! NSObject.Type ).performSelector(sel, onThread: NSThread.currentThread(), withObject: arg, waitUntilDone: true) }
    }

}
