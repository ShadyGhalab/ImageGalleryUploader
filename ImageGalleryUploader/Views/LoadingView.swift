//
//  LoadingView.swift
//  ImageUploader
//
//  Created by Shady Mustafa on 21.07.19.
//

import UIKit
import ReactiveSwift

final class LoadingView: UIView {

    @IBOutlet private weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var progressLabel: UILabel!
    
    let viewModel: LoadingViewProtocol = LoadingViewModel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
     
        bindViewModel()
    }
    
    func bindViewModel() {
        viewModel.outputs.uploadingProgress
            .observe(on: UIScheduler())
            .observeValues { [unowned self] in
                self.progressLabel.text = $0
        }
    }
}
