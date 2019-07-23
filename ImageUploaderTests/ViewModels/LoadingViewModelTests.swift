//
//  LoadingViewModelTests.swift
//  ImageUploaderTests
//
//  Created by Shady Mustafa on 23.07.19.
//  Copyright © 2019 Spark Network. All rights reserved.
//

import XCTest
@testable import ImageUploader

class LoadingViewModelTests: XCTestCase {
    
    private let viewModel: LoadingViewProtocol = LoadingViewModel()
    private let uploadingProgress: TestObserver<String, Never> = TestObserver()

    override func setUp() {
        viewModel.outputs.uploadingProgress.observe(uploadingProgress.observer)
    }

    func testUploadingProgressPercentageText() {
        viewModel.inputs.configure(with: 0.5000)
       
        uploadingProgress.assertValue("Uploading 50%")
    }
}
