//
//  ImageGalleryDetailsViewController.swift
//  Mobile
//
//  Created by Shady Mustafa on 16.07.19.
//  Copyright © 2019 Ebay. All rights reserved.
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
        imageView.reactive.image <~ viewModel.outputs.image
    }
}
