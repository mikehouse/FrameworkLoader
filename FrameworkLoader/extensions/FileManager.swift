//
//  FileManager.swift
//  FrameworkLoader
//
//  Created by mike on 4/21/16.
//  Copyright © 2016 Mikhail Demidov. All rights reserved.
//

import Foundation
import SSZipArchive

extension NSFileManager {
    
    /// Public
    
    public func isDirectory(path: String) -> Bool {
        var boo: ObjCBool = false
        fileExistsAtPath(path, isDirectory: &boo)
        return boo.boolValue
    }
    
    /** pass a name without '.extension', just like MyFramework */
    
    public func customFrameworkPath(name: String) -> String? {
        let root = customFrameworksRootPath()
        let list = try! subpathsOfDirectoryAtPath(root)
        return list.filter({ $0.hasSuffix("\(name).framework") })
            .map({ (root as NSString).stringByAppendingPathComponent($0)})
            .filter(isDirectory).first
    }
    
    /** returns [paths] all loaded frameworks */
    
    public func customFrameworks() -> [String] {
        let root = customFrameworksRootPath()
        let list = try! subpathsOfDirectoryAtPath(root)
        return list.filter({ $0.hasSuffix(".framework") })
            .map({ (root as NSString).stringByAppendingPathComponent($0)})
            .filter(isDirectory)
    }
    
    public func removeAllCustomFrameworks() {
        do { try removeItemAtPath(customFrameworksRootPath())}
        catch { print(error) }
    }
    
    /// Internal
    
    func customFrameworksRootPath() -> String {
        let rootPath = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, .UserDomainMask, true).first!
        let frameworks = (rootPath as NSString).stringByAppendingPathComponent("CustomFrameworks")
        if !fileExistsAtPath(frameworks) {
            let url = NSURL(fileURLWithPath: frameworks, isDirectory: true)
            try! createDirectoryAtURL(url, withIntermediateDirectories: true, attributes: nil)
            try! url.setResourceValue(true, forKey: NSURLIsExcludedFromBackupKey)// don't want to back up this folder
        }
        return frameworks
    }
    
    func customFrameworksAtPath(path: String) -> [String] {
        do {
            let list = try subpathsOfDirectoryAtPath(path)
            return list.filter({ $0.hasSuffix(".framework") })
                .map({ (path as NSString).stringByAppendingPathComponent($0)})
                .filter(isDirectory)
        } catch {
            print(error)
        }
        
        return []
    }
    
    func unzip(whereDir: String, zipFile: String) -> String? {
        let path = (whereDir as NSString).stringByAppendingPathComponent(randomFileName())
        return SSZipArchive.unzipFileAtPath(zipFile, toDestination: path) ? path : nil
    }
    
    func unzip(zipFile: String) -> String? {
        return unzip(customFrameworksRootPath(), zipFile: zipFile)
    }
    
    // returns a path to written file
    func createFileAtTempDir(data: NSData, ext: String) -> String? {
        let cache = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first!
        let path = (cache as NSString).stringByAppendingPathComponent(randomFileName())
        if !fileExistsAtPath(path) {
            try! createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil) // must not fail
        }
        
        let zipName = randomFileName() + ext
        let fullPath = (path as NSString).stringByAppendingPathComponent(zipName)
        do {
            try data.writeToFile(fullPath, options: .AtomicWrite)
            return fullPath
        } catch { print(error) }
        
        return nil
    }
    
    func randomFileName() -> String {
        return String(Int64(CFAbsoluteTimeGetCurrent()))
    }
    
}
