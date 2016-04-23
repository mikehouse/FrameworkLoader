//
//  Loader.swift
//  FrameworkLoader
//
//  Created by mike on 4/21/16.
//  Copyright © 2016 Mikhail Demidov. All rights reserved.
//

import Foundation

public let kErrorDomain = "FrameworkLoaderErrorDomain"

public enum FetchStatus {
    
    case Nothing // nothing happened, you can try to fetch
    case Fetching // in progress
    case Fetched // done fetch success else will be Nothing
    
}

public enum LoaderError: ErrorType {
    
    case RequestError(NSError)
    case InvalidZipFile(NSError)
    case BundleError(NSError)
    
}

public protocol BundleProtocol {
    
    init(bundle: NSBundle)
    init?(name: String)
    init?(path: String)
    
    var bundle: NSBundle! { get }
    var bundlePath: String { get }
    var infoDictionary: [String : AnyObject]? { get }
        
    func loadClass(name: String) -> AnyClass?
    
    func pathForResource(name: String?, ofType ext: String?) -> String?
    
}

public protocol LoaderProtocol {
    
    var fetchStatus: FetchStatus { get }
    
    /**
        At success fetching will be filled with its result
     */
    
    var frameworkPath: String? { get }
    
    init(request: NSURLRequest)
    
    /**
        For url a server must give *.zip archive with *.framework in it.
     
        - downloads archive from server
        - unzips archive
        - validates that it has a directory with suffix like '.framework' in
     
        BUT does not check that structure of the .framework is valid, see #tryLoad
     
     */
    
    func fetchAsync(completion: (LoaderError?, Self) -> Void)
    
    /**
        Try to load a fetched framework file through NSBundle.load(../../.framework)
     */
    
    func tryLoad() throws -> BundleProtocol
    
}