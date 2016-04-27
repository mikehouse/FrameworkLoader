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
        let task = session.dataTaskWithRequest(request) { (data, resp, error) in
            if let er = error {
                self.fetchStatus = .Nothing
                completion(LoaderError.RequestError(er.localizedDescription), self)
            } else {
                if let response = resp as? NSHTTPURLResponse where response.statusCode != 200 {
                    self.fetchStatus = .Nothing
                    completion(LoaderError.RequestError("Server error with status code \(response.statusCode)"), self)
                    return
                }
                
                let fm = NSFileManager.defaultManager()
                
                guard let savedDataPath = fm.createFileAtTempDir(data!, ext: ".zip") else {
                    self.fetchStatus = .Nothing
                    completion(LoaderError.InvalidZipFile("Not writable response data for request \(self.request)"), self)
                    return
                }
                
                print("wrote data to \(savedDataPath)")
                
                guard let unzipPath = fm.unzip(savedDataPath) else {
                    self.fetchStatus = .Nothing
                    completion(LoaderError.InvalidZipFile("Unzippable response data for request \(self.request)"), self)
                    return
                }
                
                print("unzip to \(unzipPath)")
                
                guard let frPath = fm.customFrameworksAtPath(unzipPath).first else {
                    self.fetchStatus = .Nothing
                    completion(LoaderError.InvalidZipFile("Zip archive does not have any frameworks files in for request \(self.request)"), self)
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
            throw LoaderError.BundleError("Must call #fetchAsync: with success result before!")
        }
        
        if let bundle = NSBundle(path: path) {
            try bundle.loadAndReturnError()
            
            return Bundle(bundle: bundle)
        } else {
            throw LoaderError.BundleError("Could not load Bundle for framework path \(path)")
        }
    }

}
