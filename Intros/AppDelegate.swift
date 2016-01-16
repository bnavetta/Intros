//
//  AppDelegate.swift
//  Intros
//
//  Created by Ben Navetta on 1/7/16.
//  Copyright © 2016 Ben Navetta. All rights reserved.
//

import UIKit
import RxSwift
import CleanroomLogger
import NSObject_Rx
import FBSDKCoreKit

class HelloPage: Page {
    func createViewController() -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("hello")
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    let userManager = UserManagerImpl()
    
    override init() {
        if AppSetup.devMode {
            Log.enable(.Debug, synchronousMode: true)
        }
        else {
            Log.enable()
        }
        
        initializeTheming()
    }

    // TODO: apple watch app to show code

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Log.info?.message("App launched");
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        userManager.saveUser(User.testInstance, scheduler: MainScheduler.instance)
            .subscribe()
            .addDisposableTo(rx_disposeBag)

        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        let pagedViewController = PagedViewController(pages: [
            IntroducePage(), ReceiveIntroductionPage(), HelloPage()
            ], initialIndex: 0)
        window?.rootViewController = pagedViewController
        
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

