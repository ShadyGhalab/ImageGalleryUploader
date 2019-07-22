//
//  ImageGalleryCollectionViewCell.swift
//  Mobile
//
//  Created by Shady Mustafa on 17.07.19.
//  Copyright © 2019 Ebay. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

final class ImageGalleryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!

    let viewModel: ImageGalleryCellViewProtocol = ImageGalleryCellViewModel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bindViewModel()
    }
    
    func bindViewModel() {
        imageView.reactive.image <~ viewModel.outputs.image
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
    }
}
