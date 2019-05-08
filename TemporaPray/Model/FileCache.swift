//
//  FileCache.swift
//  TemporaPray
//
//  Created by Matthew Poulos on 5/8/19.
//  Copyright © 2019 Equulus. All rights reserved.
//

import Foundation
import os

//TODO handle loading from disk
class FileCache {
    
    var fileURLMap: [String:URL]
    let libraryPath = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
    private init() {
        fileURLMap = Dictionary()
    }
    
    private static var sharedFileCache : FileCache {
        let fileCache = FileCache()
        return fileCache
    }
    
    
    func downloadFileFromURLAsync(urlString: String) {
        //download file, save to disk, add to registry
        let url = URL(string: urlString)!
        
        let task = URLSession.shared.downloadTask(with: url) { localURL, urlResponse, error in
            if let localUrl = localURL {
                let destinationURL = self.libraryPath.appendingPathComponent(url.lastPathComponent)
                do {
                    let fileManager = FileManager.default
                    try? fileManager.removeItem(at: destinationURL)
//                    print(localUrlh)
                    try FileManager.default.copyItem(at: localUrl, to: destinationURL)
                    self.fileURLMap[urlString] = destinationURL
                    os_log("Downloaded file: %@", log: .default, type: .info, urlString)
                } catch let error {
                    os_log("Problem downloading file: %@", log: .default, type: .info, urlString)
                    print(error.localizedDescription)
                }
            }
            
        }
        task.resume()
        //put in
    }
    
    func downloadFileFromURLSync(url: String) {
        
    }
    
    subscript(key: String) -> URL? {
        return  fileURLMap[key]
    }
    
    class func shared() -> FileCache {
        return sharedFileCache
    }
}
