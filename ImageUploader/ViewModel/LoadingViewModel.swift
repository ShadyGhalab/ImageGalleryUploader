//
//  LoadingViewModel.swift
//  ImageUploader
//
//  Created by Shady Mustafa on 21.07.19.
//  Copyright © 2019 Spark Network. All rights reserved.
//

import Foundation
import ReactiveSwift

protocol LoadingViewInputs {
    func configure(with progress: Float)
}

protocol LoadingViewOutputs {
    var uploadingProgress: Signal<String, Never> { get }
}

protocol LoadingViewProtocol: Any {
    var inputs: LoadingViewInputs { get }
    var outputs: LoadingViewOutputs { get }
}

struct LoadingViewModel: LoadingViewInputs, LoadingViewOutputs, LoadingViewProtocol {
    
    var inputs: LoadingViewInputs { return self }
    var outputs: LoadingViewOutputs { return self }
    
    init() {
        
        uploadingProgress = uploadingProgressProperty.signal
            .skipNil()
            .map { progress in
                let progressPercentage = progress * 100.0
                return "Uploading \(Int(progressPercentage))%"
        }
    }
    
    private let uploadingProgressProperty = MutableProperty<Float?>(nil)
    private let uriProperty = MutableProperty<String>("")
    func configure(with progress: Float) {
        uploadingProgressProperty.value = progress
    }
    
    let uploadingProgress: Signal<String, Never>
}
