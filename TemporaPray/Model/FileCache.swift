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
public class FileCache : Codable {
    
    var fileURLMap: [String:URL]
    let libraryPath = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
    let manifestFileURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!.appendingPathComponent("downloadedFilesManifest.json")
    
    private init() {
        fileURLMap = Dictionary()
    }
    
   
    
    private static let sharedFileCache :FileCache = {
        let fileCache = FileCache()
        try? FileManager.default.createDirectory(at: fileCache.libraryPath, withIntermediateDirectories: true, attributes: nil)
        let manifestFile = fileCache.libraryPath.appendingPathComponent("downloadedFilesManifest.json")
    
        do {
            let manifestData = try? Data(contentsOf: manifestFile)
            if manifestData == nil {
                
            } else {
        //        fileCache.fileURLMap = try JSONDecoder().decode(Dictionary<String,URL>.self, from: manifestData!)
            }
            
        } catch {
            os_log("Problem loading cache manifest")
        }
        
        return fileCache
    }()
    
    private func updateManifest() {
        do {
            let jsonOut = try JSONEncoder().encode(fileURLMap)
            try? FileManager.default.removeItem(at: manifestFileURL)
            try? jsonOut.write(to: manifestFileURL)
        } catch {
            os_log("Problem writing file cache manifest to disk")
        }
        
    }
    
    func downloadFileFromURLAsync(urlString: String, callback: @escaping (_: Bool) -> ()) {
        //download file, save to disk, add to registry
        let url = URL(string: urlString)!
        
//        if fileURLMap[urlString] != nil {
//            return
//        }
        
        let task = URLSession.shared.downloadTask(with: url) { localURL, urlResponse, error in
            if let localUrl = localURL {
                let destinationURL = self.libraryPath.appendingPathComponent(url.lastPathComponent)
                do {
                    let fileManager = FileManager.default
                    try? fileManager.removeItem(at: destinationURL)
//                    print(localUrlh)
                    
                    try FileManager.default.copyItem(at: localUrl, to: destinationURL)
                    self.fileURLMap[urlString] = destinationURL
                    self.updateManifest()
                    os_log("Downloaded file: %@", log: .default, type: .info, urlString)
                    callback( true)
                } catch let error {
                    os_log("Problem downloading file: %@", log: .default, type: .info, urlString)
                    print(error.localizedDescription)
                    callback(false)
                }
            }
            callback(false)
        }
        task.resume()
    }
    
//    func downloadFileFromURLSync(url: String) {
//
//    }
    
    subscript(key: String) -> URL? {
        return  fileURLMap[key]
    }
    
    static func shared() -> FileCache {
        return sharedFileCache
    }
}
