//
//  ImageGalleryViewModelTests.swift
//  ImageUploaderTests
//
//  Created by Shady Mustafa on 22.07.19.
//  Copyright © 2019 Spark Network. All rights reserved.
//

import Foundation

import XCTest

@testable import ImageGalleryUploader

fileprivate enum Constants {
    static let compressionQuality: CGFloat = 1
}

class ImageGalleryViewModelTests: XCTestCase {
    
    private let viewModel: ImageGalleryViewProtocol = ImageGalleryViewModel()
    
    private let insertedIndexPaths: TestObserver<[IndexPath], Never> = TestObserver()
    private let performBatchUpdates: TestObserver<(), Never> = TestObserver()
    private let reloadData: TestObserver<(), Never> = TestObserver()
    private let loadingIndicatorStarted: TestObserver<(), Never> = TestObserver()
    private let loadingIndicatorStopped: TestObserver<(), Never> = TestObserver()
    private let uploadingProgress: TestObserver<Float, Never> = TestObserver()

    private let fileUploader = FilesUploader(cloudName: "dmpiy9djh")
    private let fileStorageManager = FileStorageManager()
    private let testImage = UIImage(color: .blue)
    private lazy var resourceData = testImage?.compressedData

    override func setUp() {
        viewModel.outputs.insertedIndexPaths.observe(insertedIndexPaths.observer)
        viewModel.outputs.performBatchUpdates.observe(performBatchUpdates.observer)
        viewModel.outputs.reloadData.observe(reloadData.observer)
        viewModel.outputs.loadingIndicatorStarted.observe(loadingIndicatorStarted.observer)
        viewModel.outputs.loadingIndicatorStopped.observe(loadingIndicatorStopped.observer)
        viewModel.outputs.uploadingProgress.observe(uploadingProgress.observer)
    }
    
    private func configureViewModel(sectionItems: @escaping SectionItems = { _ in 1 },
                                    numberOfSections: @escaping NumberOfSections = { 1 }) {
        _ = viewModel.outputs.fetchedResultController
        viewModel.inputs.configure(with: fileUploader, fileStorageManager: fileStorageManager)
        viewModel.inputs.configure(sectionItems: sectionItems, numberOfSections: numberOfSections)
        
        viewModel.inputs.viewDidLoad()
    }
    
    func testInsertNewResource() {

        configureViewModel()

        let fileUploadExpectation = expectation(description: "Waiting for the uploading")

        viewModel.inputs.uploadResource(with: resourceData, name: "resourceName1")

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.viewModel.inputs.performBatchUpdatesStarted()
            self.viewModel.inputs.performBatchUpdatesCompeleted()

            self.insertedIndexPaths.assertValueCount(1)

            fileUploadExpectation.fulfill()
        }

        waitForExpectations(timeout: 6) { error in
            if let error = error {
                self.insertedIndexPaths.assertDidFail(error.localizedDescription)
            }
        }
    }
    
    func testPerformBatchUpdatesIsNeeded() {

        configureViewModel()

        let fileUploadExpectation = expectation(description: "Waiting for the uploading")

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.performBatchUpdates.assertDidEmitValue()

            fileUploadExpectation.fulfill()
        }

        viewModel.inputs.uploadResource(with: resourceData, name: "resourceName2")

        waitForExpectations(timeout: 6) { error in
            if let error = error {
                self.performBatchUpdates.assertDidFail(error.localizedDescription)
            }
        }
    }

    func testReloadData() {
       
        configureViewModel(sectionItems: { _ in 0 }, numberOfSections: { 1 })

        let fileUploadExpectation = expectation(description: "Waiting for the uploading")

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.reloadData.assertDidEmitValue()

            fileUploadExpectation.fulfill()
        }

        viewModel.inputs.uploadResource(with: resourceData, name: "resourceName3")

        waitForExpectations(timeout: 6) { error in
            if let error = error {
                self.reloadData.assertDidFail(error.localizedDescription)
            }
        }
    }
    
    func testLoadingIndicatorStarted() {
        
        configureViewModel()
        
        viewModel.inputs.uploadResource(with: resourceData, name: "resourceName5")
        
        loadingIndicatorStarted.assertDidEmitValue()
    }
    
    func testLoadingIndicatorStopped() {

        configureViewModel()

        let fileUploadExpectation = expectation(description: "Waiting for the uploading")

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {

            self.loadingIndicatorStopped.assertDidEmitValue()

            fileUploadExpectation.fulfill()
        }

        viewModel.inputs.uploadResource(with: resourceData, name: "resourceName4")

        waitForExpectations(timeout: 6) { error in
            if let error = error {
                self.loadingIndicatorStopped.assertDidFail(error.localizedDescription)
            }
        }
    }
 
    func testUploadingProgress() {
        
        configureViewModel()
        
        let fileUploadExpectation = expectation(description: "Waiting for the uploading")
        
        viewModel.inputs.uploadResource(with: resourceData, name: "resourceName4")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            
            self.uploadingProgress.assertDidEmitValue()
            
            fileUploadExpectation.fulfill()
        }
        
        
        waitForExpectations(timeout: 6) { error in
            if let error = error {
                self.uploadingProgress.assertDidFail(error.localizedDescription)
            }
        }
    }
}

extension UIImage {
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

fileprivate extension UIImage {
    var compressedData: Data? {
       return self.jpegData(compressionQuality: Constants.compressionQuality)
    }
}
