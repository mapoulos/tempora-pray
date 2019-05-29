//
//  AppDelegate.swift
//  TemporaPray
//
//  Created by Matthew Poulos on 4/30/19.
//  Copyright © 2019 Equulus. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let authorURL = "https://localhost:8080/authors"
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let catalog = Catalog.initializeCatalog(url: URL(string: authorURL)!)
        // set the defaults
        let defaults = UserDefaults()
        let defaultsDictionary = [Preferences.SessionLength.rawValue: 300,
                                  Preferences.IntermittentBell.rawValue: 120, Preferences.currentAuthorName.rawValue: "",
                                  Preferences.currentWorkName.rawValue: "",
                                  Preferences.currentSectionName.rawValue: ""] as [String: Any]
        defaults.register(defaults: defaultsDictionary)
        let currentAuthor =  defaults.string(forKey: Preferences.currentAuthorName.rawValue)
        if currentAuthor == "" && catalog.authors.count > 0 {
            let author = catalog.authors.first ?? Author()
            let work = author.works.first ?? Work()
            let section = work.sections.first ?? Section()
            
            Preferences.updateDefaults(authorName: author.name, workName: work.name, sectionName: section.number)
        }
        defaults.synchronize()

        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
        
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

