//
//  Catalog.swift
//  TemporaPray
//
//  Created by Matthew Poulos on 5/1/19.
//  Copyright © 2019 Equulus. All rights reserved.
//

import Foundation

class Catalog {
    var authors: [Author] = []
    
    
}


class Author : Comparable {
    static func < (lhs: Author, rhs: Author) -> Bool {
        return lhs.name < rhs.name
    }
    
    static func == (lhs: Author, rhs: Author) -> Bool {
        return lhs.name == rhs.name
    }
    
    var name: String = ""
    var works: [Work] = []
    var infoText: String = ""
    var uuid: Int = 0
    
}

class Work : Comparable {
    
    static func < (lhs: Work, rhs: Work) -> Bool {
        return lhs.name < rhs.name
    }
    
    static func == (lhs: Work, rhs: Work) -> Bool {
        return lhs.name == rhs.name
    }
    
    var name: String = ""
    var sections: [Section] = []
    var infoText: String  = ""
    var uuid: Int = 0
}

class Section : Comparable {
    
    static func < (lhs: Section, rhs: Section) -> Bool {
        return lhs.name < rhs.name
    }
    
    static func == (lhs: Section, rhs: Section) -> Bool {
        return lhs.name == rhs.name
    }
    
    var text: String = ""
    var audioURL: URL = URL(fileURLWithPath: "")
    var name: String = ""
    var uuid: Int = 0
    
}
