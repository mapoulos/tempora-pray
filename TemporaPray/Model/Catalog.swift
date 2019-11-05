//
//  Catalog.swift
//  TemporaPray
//
//  Created by Matthew Poulos on 5/1/19.
//  Copyright © 2019 Equulus. All rights reserved.
//

import Foundation
import os


extension URLSession {
    func synchronousDataTask(url: URL) -> (Data?, URLResponse?, Error?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?
        
        let sem = DispatchSemaphore(value: 0)
        
        let dataTask = self.dataTask(with: url) {
            data = $0
            response = $1
            error = $2
            sem.signal()
        }
        dataTask.resume()
        _ = sem.wait(timeout: .distantFuture)
        return (data,response, error)
    }
}

public class Catalog {
    private static var catalogInstance: Catalog?
    
    var authors: [Author]
    
    private init() {
        authors = []
    }
    
    
    
    static func initializeCatalog(url: URL) -> Catalog {
        catalogInstance = Catalog()
        catalogInstance?.loadAuthorCatalog(with: url)
        return catalogInstance!
    }
    
    static func shared() -> Catalog {
        return catalogInstance!
    }
    // syncronously load the catalog from a URL
    private func loadAuthorCatalog(with url: URL) {
        
        func loadAuthorCatalogFromBundle() {
            let catalogBundle = Bundle(path: Bundle.main.path(forResource: "Catalog", ofType: "bundle")!)!
            let catalogData = try! Data(contentsOf: catalogBundle.url(forResource: "catalog", withExtension: "json")!,  options: .mappedIfSafe)
            
            let parsedResponse = try! JSONDecoder().decode([Author].self, from: catalogData)
            self.authors = parsedResponse
        }
        
        let (data, response, error) = URLSession.shared.synchronousDataTask(url: url)
        do {
            if (data == nil) {
                //no response at all from server
                os_log("problem connecting to the catalog server")
                os_log("Defaulting to built in catalog")
                let catalogBundle = Bundle(path: Bundle.main.path(forResource: "Catalog", ofType: "bundle")!)!
                let catalogData = try Data(contentsOf: catalogBundle.url(forResource: "catalog", withExtension: "json")!,  options: .mappedIfSafe)
                
                let parsedResponse = try  JSONDecoder().decode([Author].self, from: catalogData)
                
                self.authors = parsedResponse
                
            } else {
                let str = String(decoding: data!, as: UTF8.self)
                let parsedResponse = try JSONDecoder().decode([Author].self, from: data!)
                self.authors = parsedResponse
                os_log("Finished loading the authors' list from the web." )
               
            }
            
            
        } catch Swift.DecodingError.typeMismatch(let type, let context) {
            os_log("unexpected response from web server, resorting to built in catalog.")
            loadAuthorCatalogFromBundle()
        } catch {
            loadAuthorCatalogFromBundle()
        }
    }
    
    private func loadAuthorCatalog(bundle: Bundle) {
        
    }
}

struct Author : Comparable, Codable {
    static func < (lhs: Author, rhs: Author) -> Bool {
        return lhs.name < rhs.name
    }
    
    static func == (lhs: Author, rhs: Author) -> Bool {
        return lhs.name == rhs.name
    }
    
    var name: String = ""
    var works: [Work] = []
    var info: String = ""
    
}

struct Work : Comparable, Codable {
    
    static func < (lhs: Work, rhs: Work) -> Bool {
        return lhs.name < rhs.name
    }
    
    static func == (lhs: Work, rhs: Work) -> Bool {
        return lhs.name == rhs.name
    }
    
    var name: String = ""
    var sections: [Section] = []
    var info: String  = ""
    

}

struct Section : Comparable, Codable {
    
    static func < (lhs: Section, rhs: Section) -> Bool {
        return lhs.number < rhs.number
    }
    
    static func == (lhs: Section, rhs: Section) -> Bool {
        return lhs.number == rhs.number
    }
    
    var text: String = ""
    var audioURL: String = ""
    var number: String = ""
    
//    init(number: String, text: String, audioURL: String) {
//        self.text = text
//        self.number = number
//        self.audioURL = audioURL
//    }
    
    
    
    private enum CodingKeys: String, CodingKey {
        case text
        case number
        case audioURL = "url"
    }
}


