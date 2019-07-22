//
//  ImageGalleryDetailsViewController.swift
//  Mobile
//
//  Created by Shady Mustafa on 16.07.19.
//  Copyright © 2019 Ebay. All rights reserved.
//

import Foundation
import ReactiveSwift
import UIKit.UIImage

protocol ImageGalleryDetailsViewInputs {
    func configure(with resource: Resource)
    func viewDidLoad()
}

protocol ImageGalleryDetailsViewOutputs {
    var image: Signal<UIImage, Never> { get }
}

protocol ImageGalleryDetailsViewProtocol: Any {
    var inputs: ImageGalleryDetailsViewInputs { get }
    var outputs: ImageGalleryDetailsViewOutputs { get }
}

struct ImageGalleryDetailsViewModel: ImageGalleryDetailsViewInputs, ImageGalleryDetailsViewOutputs, ImageGalleryDetailsViewProtocol {
   
    var inputs: ImageGalleryDetailsViewInputs { return self }
    var outputs: ImageGalleryDetailsViewOutputs { return self }
   
    private let fileManager = FileStorageManager()

    init() {
        
        let documentUrl = fileManager.documentUrl
        image = viewDidLoadProperty.signal
            .combineLatest(with: resourceProperty.signal)
            .map { $0.1?.name }
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
    func configure(with resource: Resource) {
        resourceProperty.value = resource
    }
    
    private let viewDidLoadProperty = MutableProperty(())
    func viewDidLoad() {
        viewDidLoadProperty.value = ()
    }
    
    let image: Signal<UIImage, Never>
}
