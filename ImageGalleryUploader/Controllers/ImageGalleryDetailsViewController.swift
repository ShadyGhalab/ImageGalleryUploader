//
//  ImageGalleryDetailsViewController.swift
//
//  Created by Shady Mustafa on 16.07.19.
//  Copyright © 2019 Babylon Health. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

final class ImageGalleryDetailsViewController: UIViewController, StoryboardMakeable {
  
    static var storyboardName: String = "ImageGallery"
    typealias StoryboardMakeableType = ImageGalleryDetailsViewController
    
    @IBOutlet private weak var imageView: UIImageView!
    let viewModel: ImageGalleryDetailsViewProtocol = ImageGalleryDetailsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bindViewModel()
       
        viewModel.inputs.viewDidLoad()
    }
    
    private func bindViewModel() {
        viewModel.outputs.image
            .observe(on: UIScheduler())
            .observeValues { [unowned self] in
                self.imageView.image = $0
        }
    }
}
