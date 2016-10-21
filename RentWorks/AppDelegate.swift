//
//  AppDelegate.swift
//  RentWorks
//
//  Created by Michael Perry on 9/17/16.
//  Copyright © 2016 Michael Perry. All rights reserved.
//

import UIKit
import CoreData
import FBSDKCoreKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FIRApp.configure()
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        if FBSDKAccessToken.current() == nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "loginVC")
            
            self.window?.rootViewController = loginVC
            self.window?.makeKeyAndVisible()
        } else {
            UserController.getCurrentLandlordFromCoreData()
        }
        
        
        return true
    }
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        guard let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
            let annotation = options[UIApplicationOpenURLOptionsKey.annotation] else {
                return false
        }
        
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url,
                                                                     sourceApplication: sourceApplication,
                                                                     annotation: annotation)
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
        
        FBSDKAppEvents.activateApp()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
        AuthenticationController.signOutOfFirebase()
    }
    
    // MARK: - Core Data stack
}

