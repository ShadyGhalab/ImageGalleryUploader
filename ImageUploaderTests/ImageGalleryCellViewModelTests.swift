//
//  ImageGalleryCellViewModelTests.swift
//  ImageUploaderTests
//
//  Created by Shady Mustafa on 23.07.19.
//  Copyright © 2019 Spark Network. All rights reserved.
//

import XCTest

@testable import ImageUploader

class ImageGalleryCellViewModelTests: XCTestCase {

    private let viewModel: ImageGalleryCellViewProtocol = ImageGalleryCellViewModel()
    private let image: TestObserver<UIImage, Never> = TestObserver()

    override func setUp() {
        viewModel.outputs.image.observe(image.observer)
    }

    func testExample() {
        let resourceName = "Cat"
        
        writeResourceToFile(withResourceName: resourceName)
        let resource = Resource.make(id: UUID().uuidString,
                                     name: resourceName,
                                     createdAt: "2019-07-23T11:33:33Z",
                                     isUploaded: true)
     
        viewModel.inputs.configure(with: resource)
        
        image.assertDidEmitValue("Image has been loaded")
        
        removeResource(withResourceName: resourceName)
    }
    
    private func writeResourceToFile(withResourceName name: String)  {
        let testImage = UIImage(color: .blue)!
        let fileStoringManager = FileStorageManager()
        do {
            try _ = fileStoringManager.write(data: testImage.jpegData(compressionQuality: 1)!, withResourceName: name)
        } catch  {
            image.assertDidFail(error.localizedDescription)
        }
    }
    
    private func removeResource(withResourceName name: String)  {
        let fileStoringManager = FileStorageManager()
        do {
            try _ = fileStoringManager.removeData(for: name)
        } catch  {
            image.assertDidFail(error.localizedDescription)
        }
    }
}
