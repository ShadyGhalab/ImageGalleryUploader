//
//  ImageGalleryViewControllerSnapshotsTests.swift
//  MobileTests
//
//  Created by Shady Mustafa on 19.07.19.
//  Copyright © 2019 Spark Networks. All rights reserved.
//

import XCTest
import FBSnapshotTestCase
import ReactiveSwift

@testable import ImageUploader

class ImageGalleryViewControllerSnapshots: FBSnapshotTestCase {
    
    private var imageGalleryNavigationController: ImageGalleryNavigationController!
    private var viewController: ImageGalleryViewController!
    private let fileStoringManager = FileStorageManager()
    private let fileUploaderMock = FileUploaderMock()
    private let resourceName = "Cat"
  
    private var window: UIWindow = {
        return UIWindow(frame: UIScreen.main.bounds)
    }()
    
    override func setUp() {
        super.setUp()

        setupView()
    }
    
    func setupView() {
        viewController = ImageGalleryViewController.make()
        imageGalleryNavigationController = ImageGalleryNavigationController.make()
        imageGalleryNavigationController.setViewControllers([viewController], animated: false)
        
        window.addSubview(imageGalleryNavigationController.view)
        window.makeKeyAndVisible()
    }
    
    func testImageGalleryViewControllerWithEmptyView() {
        
        fileStoringManager.writeResourceToFile(withResourceName: resourceName)
        
        viewController.viewModel.inputs.configure(with: fileUploaderMock, fileStorageManager: FileStorageManager())
        
        viewController.loadViewIfNeeded()
        
        FBSnapshotVerifyView(imageGalleryNavigationController.view)
    }
    
    func testImageGalleryViewControllerWithImages() {
        
        _ = Resource.make(id: UUID().uuidString, name: resourceName, createdAt: "2019-07-23T11:33:33Z", isUploaded: true)
        _ = Resource.make(id: UUID().uuidString, name: resourceName, createdAt: "2019-07-23T11:33:33Z", isUploaded: true)
        
        fileStoringManager.writeResourceToFile(withResourceName: resourceName)
        
        viewController.viewModel.inputs.configure(with: fileUploaderMock, fileStorageManager: FileStorageManager())

        viewController.loadViewIfNeeded()

        FBSnapshotVerifyView(imageGalleryNavigationController.view)
    }
    
    func testImageGalleryViewControllerLoadingView() {
        viewController.navigationItem.titleView?.isHidden = false
        
        FBSnapshotVerifyView(imageGalleryNavigationController.view)
    }
    
    override func tearDown() {
        fileStoringManager.removeResource(withResourceName: resourceName)
        
        super.tearDown()
    }
}

fileprivate class FileUploaderMock: FilesUploading {
    var delegate: FilesUploaderDelegate?
    
    func upload(data: Data, resourceName: String, resourceType: ResourceType = .image) {
        let resource = ResourceInfo(id: UUID().uuidString, createdAt: "2019-07-23T11:33:33Z")
        delegate?.didFinishUploading(for: URL(string: "https://www.spark.net")!, resourceInfo: resource)
    }
}
