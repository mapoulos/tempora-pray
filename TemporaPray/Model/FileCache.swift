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
    
    var fileURLMap: [String:String]
//    let libraryPath = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
    static let cachePath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    static let manifestFileURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("downloadedFilesManifest.json")
    
    private init() {
        fileURLMap = Dictionary()
    }
    
    
    
    private static let sharedFileCache :FileCache = {
        let fileCache = FileCache()
        try? FileManager.default.createDirectory(at: cachePath, withIntermediateDirectories: true, attributes: nil)
        
        let manifestFile = cachePath.appendingPathComponent("downloadedFilesManifest.json")
    
        do {
            let manifestData = try? Data(contentsOf: manifestFile)
            if manifestData == nil {
                
            } else {
                fileCache.fileURLMap = try JSONDecoder().decode(Dictionary<String,String>.self, from: manifestData!)
                //mp3s could have been deleted in the meantime, remove any from map that don't exist.
                
                let newMap = fileCache.fileURLMap.filter({ !FileManager.default.fileExists(atPath: cachePath.appendingPathComponent($0.value).absoluteString)})
                fileCache.fileURLMap = newMap
            }
            
        } catch {
            os_log("Problem loading cache manifest")
        }
        
        return fileCache
    }()
    
    private func updateManifest() {
        do {
            let jsonOut = try JSONEncoder().encode(fileURLMap)
            try? FileManager.default.removeItem(at: FileCache.manifestFileURL)
            try? jsonOut.write(to: FileCache.manifestFileURL)
        } catch {
            os_log("Problem writing file cache manifest to disk")
        }
        
    }
   
    
    func downloadFileFromURLAsync(urlString: String, callback: @escaping (_: Bool) -> ()) {
        //download file, save to disk, add to registry
        let url = URL(string: urlString)!
        
        //check local registry first
        if let _ = fileURLMap[urlString] {
            callback(true)
            return
        
        }
        
        let task = URLSession.shared.downloadTask(with: url) { localURL, urlResponse, error in
            if let httpResponse = urlResponse as? HTTPURLResponse {
                if httpResponse.statusCode == 404 {
                    os_log("404 on attempting download of file: %@", log: .default, type: .error, urlString)
                    callback(false)
                    return
                }
            } else {
                os_log("error connecting to server")
                callback(false)
                return
            }
            if let localUrl = localURL {
                let destinationURL = FileCache.cachePath.appendingPathComponent(url.lastPathComponent)
                do {
                    let fileManager = FileManager.default
                    try? fileManager.removeItem(at: destinationURL)
                    try FileManager.default.copyItem(at: localUrl, to: destinationURL)
                    self.fileURLMap[urlString] = url.lastPathComponent
                    self.updateManifest()
                    os_log("Downloaded file: %@", log: .default, type: .info, urlString)
                    callback( true)
                } catch let error {
                    os_log("Problem downloading file: %@", log: .default, type: .info, urlString)
                    print(error.localizedDescription)
                    callback(false)
                }
            }
//            print(urlResponse)
            callback(false)
        }
        task.resume()
    }
    
    
    subscript(key: String) -> String? {
        return  FileCache.cachePath.appendingPathComponent(fileURLMap[key]!).absoluteString
    }
    
    static func shared() -> FileCache {
        return sharedFileCache
    }
}
