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
    
    var cachedFiles: [String:String]
    var savedFiles: [String:String]
    static let libraryPath = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
    static let cachePath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    static let cachedFilesJSONURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("cachedFiles.json")
    static let savedManifestJSONURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("savedFiles.json")
    
    private init() {
        cachedFiles = Dictionary()
        savedFiles = Dictionary()
    }
    
    
    
    private static let sharedFileCache :FileCache = {
        let fileCache = FileCache()
        try? FileManager.default.createDirectory(at: cachePath, withIntermediateDirectories: true, attributes: nil)
        
//        let manifestFile = cachePath.appendingPathComponent("downloadedFilesManifest.json")
    
        do {
            let cachedManifestData = try? Data(contentsOf: FileCache.cachedFilesJSONURL)
            let savedManifestData = try? Data(contentsOf: FileCache.savedManifestJSONURL)
            if cachedManifestData == nil {
                
            } else {
                fileCache.cachedFiles = try JSONDecoder().decode(Dictionary<String,String>.self, from: cachedManifestData!)
                fileCache.savedFiles = try JSONDecoder().decode(Dictionary<String,String>.self, from: savedManifestData!)
            }
            
        } catch {
            os_log("Problem loading file manifests")
            print(error)
        }
        
        return fileCache
    }()
    
    private func updateManifests() {
        do {
            let jsonOutCached = try JSONEncoder().encode(cachedFiles)
            try? jsonOutCached.write(to: FileCache.cachedFilesJSONURL)
            
            let jsonOutSaved = try JSONEncoder().encode(savedFiles)
            try? jsonOutSaved.write(to: FileCache.savedManifestJSONURL)
            
            
        } catch {
            os_log("Problem writing file cache manifest to disk")
        }
        
    }
   
    func containsSavedFile(remoteURL : String) -> Bool{
        return savedFiles.contains(where: { (arg0) -> Bool in
            let (key, _) = arg0
            return key == remoteURL
        })
    }
    
    //on attempting to save a file, we need to check the local registries
    //if it is found in either, we don't need to redownload the file
    //if we are asked to store a file that is already in temp, we should move from temp to library
    
    private func moveFileFromCacheToLibrary(remoteURL: String) -> URL? {
        let fileManager = FileManager.default
        do {
            let cachedURL = URL(string: cachedFiles[remoteURL]!)
            let destinationURL = FileCache.libraryPath.appendingPathComponent(cachedURL!.lastPathComponent)
            try? fileManager.moveItem(at: cachedURL!, to: destinationURL )
            return destinationURL
        }
    }
    
    func saveFileToCache(urlString: String, store: Bool, callback: @escaping (_: Bool) -> ()) {
        //download file, save to disk, add to registry
        let url = URL(string: urlString)!
        
        
        //check local manifests first
        if let _ = cachedFiles[urlString] {
            if store == true {
                //move file from cache to library
                let destURL = moveFileFromCacheToLibrary(remoteURL: urlString)
                //update the maps appropriately
                self.cachedFiles.removeValue(forKey: urlString)
                self.savedFiles[urlString] = destURL?.absoluteString
                self.updateManifests()
            }
            callback(true)
            return
        
        } else if let _ = savedFiles[urlString] {
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
                var destinationURL: URL
                if store == true {
                    destinationURL = FileCache.libraryPath.appendingPathComponent(url.lastPathComponent)
                } else {
                    destinationURL = FileCache.cachePath.appendingPathComponent(url.lastPathComponent)
                }
                
                do {
                    if store == true {
                        destinationURL = FileCache.libraryPath.appendingPathComponent(url.lastPathComponent)
                        self.savedFiles[urlString] = url.lastPathComponent
                        try FileManager.default.copyItem(at: localUrl, to: destinationURL)
                    } else {
                        destinationURL = FileCache.cachePath.appendingPathComponent(url.lastPathComponent)
                        self.cachedFiles[urlString] = url.lastPathComponent
                        try FileManager.default.copyItem(at: localUrl, to: destinationURL)
                    }
                    
                    self.updateManifests()
                    os_log("Downloaded file: %@", log: .default, type: .info, urlString)
                    callback( true)
                    return
                } catch let error {
                    os_log("Problem downloading file: %@", log: .default, type: .info, urlString)
                    print(error.localizedDescription)
                    callback(false)
                    return
                }
            }
//            print(urlResponse)
            callback(false)
            return
        }
        task.resume()
    }
    
    
    subscript(key: String) -> String? {
        return  FileCache.cachePath.appendingPathComponent(cachedFiles[key]!).absoluteString
    }
    
    static func shared() -> FileCache {
        return sharedFileCache
    }
}
