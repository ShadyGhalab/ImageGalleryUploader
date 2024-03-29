//
//  AppDelegate.swift
//  ImageUploader
//
//  Created by Shady Mustafa on 20.07.19.
//

import UIKit
import CoreData

private enum Constants {
    static let cloudName: String = "dmpiy9djh"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        guard ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil else { return true }
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        let fileUploader: FilesUploading = FilesUploader(sessionIdentifier: UUID().uuidString, cloudName: Constants.cloudName)
        let imageGalleryNavigationController = ImageGalleryNavigationController.make()
        let imageGalleryViewController = imageGalleryNavigationController.topViewController as? ImageGalleryViewController
       
        imageGalleryViewController?.viewModel.inputs.configure(with: fileUploader, fileStoring: FileStorageManager())
        
        self.window?.rootViewController = imageGalleryNavigationController
        self.window?.makeKeyAndVisible()
        return true
    }
    
    func application(_ application: UIApplication,
                     handleEventsForBackgroundURLSession identifier: String,
                     completionHandler: @escaping () -> Void) { }

    func applicationWillResignActive(_ application: UIApplication) { }

    func applicationDidEnterBackground(_ application: UIApplication) { }

    func applicationWillEnterForeground(_ application: UIApplication) { }

    func applicationDidBecomeActive(_ application: UIApplication) { }

    func applicationWillTerminate(_ application: UIApplication) {
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ImageUploader")
        
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
        }
        
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}


extension AppDelegate {
   static var shared: AppDelegate {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate // swiftlint:disable:this force_cast
    
        return appDelegate
    }
}
