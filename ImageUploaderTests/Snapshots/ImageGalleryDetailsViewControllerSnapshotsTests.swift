//
//  ImageGalleryDetailsViewControllerSnapshotsTests.swift
//  ImageUploaderTests
//
//  Created by Shady Mustafa on 23.07.19.
//  Copyright © 2019 Spark Network. All rights reserved.
//

import XCTest
import FBSnapshotTestCase
import ReactiveSwift

@testable import ImageUploader

class ImageGalleryDetailsViewControllerSnapshotsTests: FBSnapshotTestCase {
    private var imageGalleryNavigationController: ImageGalleryNavigationController!
    private var viewController: ImageGalleryDetailsViewController!
    private let fileStoringManager = FileStorageManager()
    private let resourceName = "Cat"
    private let resource = Resource.make(id: UUID().uuidString,
                                         name: "Cat",
                                         createdAt: "2019-07-23T11:33:33Z",
                                         isUploaded: true)
    private var window: UIWindow = {
        return UIWindow(frame: UIScreen.main.bounds)
    }()
    
    override func setUp() {
        super.setUp()

        setupView()
    }
    
    func setupView() {
        viewController = ImageGalleryDetailsViewController.make()
        imageGalleryNavigationController = ImageGalleryNavigationController.make()
        imageGalleryNavigationController.setViewControllers([viewController], animated: false)
        
        window.addSubview(imageGalleryNavigationController.view)
        window.makeKeyAndVisible()
    }
    
    func testImageGalleryDetailsViewControllerWithImages() {
        
        fileStoringManager.writeResourceToFile(withResourceName: resourceName)
        
        viewController.viewModel.inputs.configure(with: resource)
        
        viewController.loadViewIfNeeded()
        
        FBSnapshotVerifyView(imageGalleryNavigationController.view)
    }
    
    override func tearDown() {
        fileStoringManager.removeResource(withResourceName: resourceName)
        AppDelegate.shared.persistentContainer.viewContext.delete(resource)
        super.tearDown()
    }

}

extension FileStorageManager {
    func writeResourceToFile(withResourceName name: String)  {
        let testImage = UIImage(color: .blue)!
        do {
            try _ = write(data: testImage.jpegData(compressionQuality: 1)!, withResourceName: name)
        } catch  { }
    }
    
    func removeResource(withResourceName name: String)  {
        do {
            try _ = removeData(for: name)
        } catch  { }
    }
}
