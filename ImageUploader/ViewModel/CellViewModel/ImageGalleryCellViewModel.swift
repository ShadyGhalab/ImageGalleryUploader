//
//  ImageGalleryCellViewModel.swift
//  Mobile
//
//  Created by Shady Mustafa on 18.07.19.
//  Copyright © 2019 Spark Network. All rights reserved.
//

import Foundation
import ReactiveSwift
import UIKit

protocol ImageGalleryCellViewInputs {
    func configure(with resource: Resource?)
}

protocol ImageGalleryCellViewOutputs {
    var image: Signal<UIImage, Never> { get }
}

protocol ImageGalleryCellViewProtocol: Any {
    var inputs: ImageGalleryCellViewInputs { get }
    var outputs: ImageGalleryCellViewOutputs { get }
}

struct ImageGalleryCellViewModel: ImageGalleryCellViewInputs, ImageGalleryCellViewOutputs, ImageGalleryCellViewProtocol {
  
    var inputs: ImageGalleryCellViewInputs { return self }
    var outputs: ImageGalleryCellViewOutputs { return self }
    private let fileManager = FileStorageManager()
    
    init() {

          let documentUrl = fileManager.documentUrl
          image = resourceProperty.signal.skipNil()
            .map { $0.name }
            .skipNil()
            .map { name -> UIImage? in
                do {
                    let file = documentUrl.appendingPathComponent(name)
                    let data = try Data(contentsOf: file)
                  
                    return UIImage(data: data)
                } catch {
                    return nil
                }
            }.skipNil()
    }
    
    private let resourceProperty = MutableProperty<Resource?>(nil)
    func configure(with resource: Resource?) {
        resourceProperty.value = resource
    }
    
    let image: Signal<UIImage, Never>
}
