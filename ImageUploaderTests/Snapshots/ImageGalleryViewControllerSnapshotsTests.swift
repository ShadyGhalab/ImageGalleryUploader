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
    private let resource1 = Resource.make(id: UUID().uuidString,
                                  name: "Cat",
                                  createdAt: "2019-07-23T11:33:33Z",
                                  isUploaded: true)
    private let resource2 = Resource.make(id: UUID().uuidString,
                                  name: "Cat",
                                  createdAt: "2019-07-23T11:33:33Z",
                                  isUploaded: true)
    var window: UIWindow = {
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
    
    func testImageGalleryViewControllerWithImages() {
        
        writeResourceToFile(withResourceName: resourceName)
        
        viewController.viewModel.inputs.configure(with: fileUploaderMock, fileStorageManager: FileStorageManager())

        viewController.loadViewIfNeeded()

        FBSnapshotVerifyView(imageGalleryNavigationController.view)
    }
    
    override func tearDown() {
        removeResource(withResourceName: resourceName)
        
        super.tearDown()
    }
}

extension ImageGalleryViewControllerSnapshots {
    private func writeResourceToFile(withResourceName name: String)  {
        let testImage = UIImage(color: .blue)!
        do {
            try _ = fileStoringManager.write(data: testImage.jpegData(compressionQuality: 1)!, withResourceName: name)
        } catch  { }
    }
    
    private func removeResource(withResourceName name: String)  {
        do {
            try _ = fileStoringManager.removeData(for: name)
        } catch  { }
    }
}

fileprivate class FileUploaderMock: FilesUploading {
    var delegate: FilesUploaderDelegate?
    
    func upload(data: Data, resourceName: String, resourceType: ResourceType = .image) {
        let resource = ResourceInfo(id: UUID().uuidString, createdAt: "2019-07-23T11:33:33Z")
        delegate?.didFinishUploading(for: URL(string: "https://www.spark.net")!, resourceInfo: resource)
    }
}
