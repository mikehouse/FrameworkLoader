//
//  Bundle.swift
//  FrameworkLoader
//
//  Created by mike on 4/21/16.
//  Copyright © 2016 Mikhail Demidov. All rights reserved.
//

import Foundation

public class Bundle: NSObject, BundleProtocol {
    
    private(set) public var bundle: NSBundle!
    
    public var bundlePath: String { return bundle.bundlePath }
    public var infoDictionary: [String : AnyObject]? { return bundle.infoDictionary }

    public required init(bundle: NSBundle) {
        self.bundle = bundle
        
        super.init()
    }
    
    public required convenience init?(name: String) {
        guard let path = NSFileManager.defaultManager().customFrameworkPath(name) else {
            return nil
        }
        
        self.init(path: path)
    }
    
    public required init?(path: String) {
        guard let b = NSBundle(path: path) else {
            return nil
        }
        
        do { try b.loadAndReturnError() }
        catch { return nil }
        
        self.bundle = b
        super.init()
    }
    
    public func loadClass(name: String) -> AnyClass? {
        return bundle.classNamed(name)
    }
    
    public func pathForResource(name: String?, ofType ext: String?) -> String? {
        return bundle.pathForResource(name, ofType: ext)
    }
        
}
