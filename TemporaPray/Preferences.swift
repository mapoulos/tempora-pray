//
//  Preferences.swift
//  TemporaPray
//
//  Created by Matthew Poulos on 4/30/19.
//  Copyright © 2019 Equulus. All rights reserved.
//

import Foundation

enum Preferences : String {
    case SessionLength = "SessionLength"
    case IntermittentBell = "IntermittentBell"
    case currentAuthorName = "CurrentAuthorName"
    case currentWorkName = "CurrentWorkName"
    case currentSectionName = "CurrentSectionName"
    
    static func updateDefaults(authorName: String, workName: String, sectionName: String) {
        let defaults = UserDefaults()
        defaults.set(authorName, forKey: currentAuthorName.rawValue)
        defaults.set(workName, forKey: currentWorkName.rawValue)
        defaults.set(sectionName, forKey: currentSectionName.rawValue)
        defaults.synchronize()
    }
    
    static func updateDefaults(_ tuple : (author:Author, work:Work, section:Section)) {
        Preferences.updateDefaults(authorName: tuple.author.name, workName: tuple.work.name, sectionName: tuple.section.number)
    }
}
