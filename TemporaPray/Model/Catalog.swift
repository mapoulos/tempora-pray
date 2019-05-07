//
//  Catalog.swift
//  TemporaPray
//
//  Created by Matthew Poulos on 5/1/19.
//  Copyright © 2019 Equulus. All rights reserved.
//

import Foundation


struct WebResponse : Codable {
    //  var authors: [Author] = Array()
    fileprivate let _embedded : Embedded?
    fileprivate let _links : Links?
    fileprivate let page : Page?
    
    
    func getAuthors() -> [Author]? {
        return _embedded?.authors
    }
   
    
}

fileprivate struct Embedded : Codable {
    let authors : [Author]
    let _links : Links?
}

fileprivate struct Page : Codable {
    let size :Int?
    let totalElements :Int?
    let totalPages : Int?
    let number : Int?
}

fileprivate struct Links : Codable {
    let _self: LinkSelf?
    let profile: Profile?
    let author : String?
    private enum CodingKeys: String, CodingKey {
        case _self = "self"
        case profile = "profile"
        case author = "author"
    }
}

fileprivate struct LinkSelf : Codable {
    let href : String?
    let templated : Bool?
}

fileprivate struct Profile : Codable {
    let href : String?
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
    
    init(number: String, text: String, audioURL: String) {
        self.text = text
        self.number = number
        self.audioURL = audioURL
    }
    
    
    
    private enum CodingKeys: String, CodingKey {
        case text
        case number
        case audioURL
    }
}


