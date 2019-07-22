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

private enum Constants {
    static let borderWidth: CGFloat = 0.5
    static let cornerRadius: CGFloat = 5
}

final class ImageGalleryCollectionViewCell: UICollectionViewCell {
   
    @IBOutlet weak var imageView: UIImageView!
   
    let viewModel: ImageGalleryCellViewProtocol = ImageGalleryCellViewModel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        makeImageViewRounded()
        bindViewModel()
    }
    
    func bindViewModel() {
        imageView.reactive.image <~ viewModel.outputs.image
    }
    
    private func makeImageViewRounded() {
        imageView.layer.borderWidth = Constants.borderWidth
        imageView.layer.masksToBounds = false
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.cornerRadius = Constants.cornerRadius
        imageView.clipsToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
    }
}
