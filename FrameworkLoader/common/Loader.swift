//
//  Loader.swift
//  FrameworkLoader
//
//  Created by mike on 4/21/16.
//  Copyright © 2016 Mikhail Demidov. All rights reserved.
//

import Foundation

public class Loader: NSObject, LoaderProtocol {
    
    private(set) public var fetchStatus: FetchStatus = .Nothing
    private(set) public var frameworkPath: String?
    
    private let request: NSURLRequest
    
    public required init(request: NSURLRequest) {
        self.request = request
        
        super.init()
    }
    
    public func fetchAsync(completion: (LoaderError?, Loader) -> Void) {
        guard fetchStatus != .Fetching else { return }
        
        fetchStatus = .Fetching
        fetch(completion)
    }
    
    private func fetch(completion: (LoaderError?, Loader) -> Void) {
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: nil, delegateQueue: NSOperationQueue())
        let task = session.dataTaskWithRequest(request) { (data, _, error) in
            if let er = error {
                self.fetchStatus = .Nothing
                completion(LoaderError.RequestError(er), self)
            } else {
                let fm = NSFileManager.defaultManager()
                
                guard let savedDataPath = fm.createFileAtTempDir(data!) else {
                    self.fetchStatus = .Nothing
                    let msg = "Not writable response data for request \(self.request)"
                    let e = NSError(domain: kErrorDomain, code: -97, userInfo: [NSLocalizedDescriptionKey:msg])
                    completion(LoaderError.InvalidZipFile(e), self)
                    return
                }
                
                print("wrote data to \(savedDataPath)")
                
                guard let unzipPath = fm.unzip(savedDataPath) else {
                    self.fetchStatus = .Nothing
                    let msg = "Unzippable response data for request \(self.request)"
                    let e = NSError(domain: kErrorDomain, code: -96, userInfo: [NSLocalizedDescriptionKey:msg])
                    completion(LoaderError.InvalidZipFile(e), self)
                    return
                }
                
                print("unzip to \(unzipPath)")
                
                guard let frPath = fm.customFrameworksAtPath(unzipPath).first else {
                    self.fetchStatus = .Nothing
                    let msg = "Zip archive does not have any frameworks files in for request \(self.request)"
                    let e = NSError(domain: kErrorDomain, code: -95, userInfo: [NSLocalizedDescriptionKey:msg])
                    completion(LoaderError.InvalidZipFile(e), self)
                    return
                }
                
                print("found framework \(frPath)")
                
                self.frameworkPath = frPath
                self.fetchStatus = .Fetched
                completion(nil, self)
            }
        }
        task.resume()
    }
    
    public func tryLoad() throws -> BundleProtocol {
        guard fetchStatus == .Fetched, let path = frameworkPath else {
            let msg = "Must call #fetchAsync: with success result before!"
            throw LoaderError.BundleError(NSError(domain: kErrorDomain, code: -99, userInfo: [NSLocalizedDescriptionKey:msg]))
        }
        
        if let bundle = NSBundle(path: path) {
            try bundle.loadAndReturnError()
            
            return Bundle(bundle: bundle)
        } else {
            let msg = "Could not load Bundle for framework path \(path)"
            throw LoaderError.BundleError(NSError(domain: kErrorDomain, code: -98, userInfo: [NSLocalizedDescriptionKey:msg]))
        }
    }

}
