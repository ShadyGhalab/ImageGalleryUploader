//
//  ImageGalleryCellViewModelTests.swift
//  ImageUploaderTests
//
//  Created by Shady Mustafa on 23.07.19.
//

import XCTest

@testable import ImageGalleryUploader

class ImageGalleryCellViewModelTests: XCTestCase {

    private let viewModel: ImageGalleryCellViewProtocol = ImageGalleryCellViewModel()
    private let image: TestObserver<UIImage, Never> = TestObserver()
    private let fileStoringManager = FileStorageManager()
    private let resourceName = "Cat"
    private lazy var resource = Resource.make(id: UUID().uuidString,
                                              name: resourceName,
                                              createdAt: "2019-07-23T11:33:33Z",
                                              isUploaded: true)
    override func setUp() {
        viewModel.outputs.image.observe(image.observer)
    }

    func testLoadingImage() {
        writeResourceToFile(withResourceName: resourceName)
        
        viewModel.inputs.configure(with: resource)
        
        image.assertDidEmitValue("Image has been loaded")
    }
    
    override func tearDown() {
        removeResource(withResourceName: resourceName)
        delete(resource: resource)
        
        super.tearDown()
    }
}

private extension ImageGalleryCellViewModelTests {
     func writeResourceToFile(withResourceName name: String)  {
        let testImage = UIImage(color: .blue)!
        do {
            try _ = fileStoringManager.write(data: testImage.jpegData(compressionQuality: 1)!, withResourceName: name)
        } catch  {
            image.assertDidFail(error.localizedDescription)
        }
    }
    
    func removeResource(withResourceName name: String)  {
        do {
            try _ = fileStoringManager.removeData(for: name)
        } catch  {
            image.assertDidFail(error.localizedDescription)
        }
    }
    
    func delete(resource: Resource)  {
        AppDelegate.shared.persistentContainer.viewContext.delete(resource)
        AppDelegate.shared.saveContext()
    }
}
