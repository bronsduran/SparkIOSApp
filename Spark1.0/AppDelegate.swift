//
//  AppDelegate.swift
//  Spark1.0
//
//  Created by Bronson Duran on 1/16/16.
//  Copyright © 2016 Bronson Duran. All rights reserved.
//

import UIKit
import CoreData
import Parse
import Bolts

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        Parse.enableLocalDatastore()
        
        User.registerSubclass()
        Student.registerSubclass()
        Moment.registerSubclass()
        Class.registerSubclass()

        // Initialize Parse.
        Parse.setApplicationId("inkL3uIc4NC2L4LgJi0ccNZUcHETUk7ebpbDQ9DJ",
            clientKey: "5XttMKEEaXT4fCyWH6Y2PmK3LixZuwH7VphKWf5g")
        
        // [Optional] Track statistics around application opens.
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        let isLoggedIn = NSUserDefaults.standardUserDefaults().boolForKey("is_logged_in")
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)

        
        if isLoggedIn {
            mainStoryboard.instantiateInitialViewController()
        } else {
            let vc = mainStoryboard.instantiateViewControllerWithIdentifier("SPLoginViewController") as! SPLoginViewController
            self.window!.rootViewController = vc
        }

        #if (arch(i386) || arch(x86_64)) && os(iOS)
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isSimulator")
        #endif
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        initSegmentedControlAppearance()
        initNavBarAppearance()
        initToolBarAppearance()
        initCollectionViewAppearance()
        
        return true
    }
    
    func initSegmentedControlAppearance() {
        // Control colors (selected):
       // UISegmentedControl.appearance().tintColor = UIColor(white: 1.0, alpha: 0.5)
        
        // Font colors:
        UISegmentedControl.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)
        UISegmentedControl.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Selected)
        
    }
    
    func initNavBarAppearance() {
        // Nav Bar
        UINavigationBar.appearance().setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        UINavigationBar.appearance().shadowImage = UIImage()
        //UINavigationBar.appearance().translucent = true
        
        UINavigationBar.appearance().tintColor = UIColor(red:255/255.0, green:37/255.0, blue:80/255.0,  alpha:1.0)
        UINavigationBar.appearance().backgroundColor = UIColor.clearColor()
        //UINavigationBar.appearance().backgroundColor = UIColor(red:255/255.0, green:37/255.0, blue:80/255.0,  alpha:1.0)
        
        //UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        //UINavigationBar.appearance().titleTextAttributes = UIColor(red:255/255.0, green:37/255.0, blue:80/255.0,  alpha:1.0)
    }
    
    func initToolBarAppearance() {
        //UIToolbar.appearance().tintColor = UIColor.whiteColor()
        //UIToolbar.appearance().backgroundColor = UIColor(red:255/255.0, green:37/255.0, blue:80/255.0,  alpha:1.0)
          UIToolbar.appearance().backgroundColor = UIColor.clearColor()
       
        //UIToolbar.appearance().barTintColor = UIColor(red:255/255.0, green:37/255.0, blue:80/255.0,  alpha:1.0)
    }

    func initCollectionViewAppearance() {
        UICollectionView.appearance().backgroundColor = UIColor(red:240/255.0, green:240/255.0, blue:240/255.0,  alpha:1);
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

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.example.Spark1_0" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Spark1_0", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

}

class MomentSingleton {
    static let sharedInstance = MomentSingleton()
    var image : UIImage?
    var videoUrl: NSURL?
    var notes : String?
    var voiceFile : NSURL?
    var voiceData : NSData?
    var mediaType : Int?
    var students : [Student]?
    var categories : [String]?
    
    
    var moment: Moment?
    
    private init() {}
    
    func clearData() {
        notes = nil
        mediaType = nil
        students = nil
        categories = nil
        
        image = nil
        videoUrl = nil
        voiceData = nil
        
        voiceFile = nil
        moment = nil
    }
    
    func populateWithMoment(moment: Moment, imageCB: () -> Void, videoCB: () -> Void, voiceCB: () -> Void) {
        self.moment = moment
        
        mediaType = moment["mediaType"] as? Int
        notes = moment["notes"] as? String
        if notes == "" {
            notes = nil
        }
        
        students = moment.studentsTagged()
        categories = moment.categoriesTagged()
        
        // image
        moment.image ({ image in
            self.image = image
            imageCB()
        })
        
        // video
        moment.video({ video in
            if let video = video, let videoUrl = video.url {
                self.videoUrl = NSURL(string: videoUrl)
            }
            
            videoCB()
        })
        
        // voice
        moment.getFileNamed("voiceData", callback: { (data: NSData?) -> Void in
            self.voiceData = data
            let urlString = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0].stringByAppendingString("/sound.caf")
            NSFileManager.defaultManager().createFileAtPath(urlString, contents: data, attributes: nil)
            self.voiceFile = NSURL(string: urlString)
            voiceCB()
        })
    }

}


