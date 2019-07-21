//
//  ImageGalleryViewController.swift
//  Mobile
//
//  Created by Shady Mustafa on 16.07.19.
//  Copyright © 2019 Ebay. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import CoreData

private enum Constants {
    static let collectionViewLeftMargin: CGFloat = 10.0
    static let collectionViewRightMargin: CGFloat = 10.0
    static let noOfColumnsForIPhones: CGFloat = 2.0
    static let noOfColumnsForIPad: CGFloat = 4.0
    static let cellHeight: CGFloat = 134
    static let showImageGalleryDetails = "showImageGalleryDetails"
}

final class ImageGalleryViewController: UIViewController, StoryboardMakeable {
   
    static var storyboardName: String = "ImageGallery"
    typealias StoryboardMakeableType = ImageGalleryViewController
   
    @IBOutlet weak var collectionView: UICollectionView!
    
    let viewModel: ImageGalleryViewProtocol = ImageGalleryViewModel()
    private var dataSource: ImageGalleryDataSource? {
        didSet {
            collectionView.dataSource = dataSource
            collectionView.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDataSource()
        configureViewModel()
        bindViewModel()

        viewModel.inputs.viewDidLoad()
    }
    
    private func setupDataSource() {
        dataSource = ImageGalleryDataSource(fetchedResultController: viewModel.outputs.fetchedResultController)
    }
    
    private func configureViewModel() {
        let numberOfItemsInSection: NumberOfItemsInSection = { [weak self] indexPath in
            guard let section = indexPath?.section else { return nil }
            return self?.collectionView.numberOfItems(inSection: section)
        }
        
        let numberOfSections: NumberOfSections = { [weak self] in
             self?.collectionView.numberOfSections
        }
        
        viewModel.inputs.configure(with: numberOfItemsInSection, numberOfSections: numberOfSections)
    }
    
    private func bindViewModel() {
        viewModel.outputs.insertedIndexPaths
            .observe(on: UIScheduler())
            .observeValues { [weak self] in
                self?.collectionView.insertItems(at: $0)
        }
        
        viewModel.outputs.updatedIndexPaths
            .observe(on: UIScheduler())
            .observeValues { [weak self] in
                self?.collectionView.reloadItems(at: $0)
        }
        
        viewModel.outputs.updatedIndexPaths
            .observe(on: UIScheduler())
            .observeValues { [weak self] in
                self?.collectionView.deleteItems(at: $0)
        }

        viewModel.outputs.insertedSection
            .observe(on: UIScheduler())
            .observeValues { [weak self] in
                self?.collectionView.insertSections($0 as IndexSet)
        }
        
        viewModel.outputs.updatedSection
            .observe(on: UIScheduler())
            .observeValues { [weak self] in
                self?.collectionView.reloadSections($0 as IndexSet)
        }
        
        viewModel.outputs.deletedSection
            .observe(on: UIScheduler())
            .observeValues { [weak self] in
                self?.collectionView.deleteSections($0 as IndexSet)
        }
        
        viewModel.outputs.performBatchUpdates
            .observe(on: UIScheduler())
            .observeValues { [weak self] _ in
                self?.collectionView.performBatchUpdates({ () -> Void in
                    self?.viewModel.inputs.performBatchUpdatesStarted()
            }, completion: { _ in
                    self?.viewModel.inputs.performBatchUpdatesCompeleted()
            })
        }
        
        collectionView.reactive.reloadData <~ viewModel.outputs.reloadData
    }
    
    @IBAction func addResourceBarButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            print("User click Camera button")
        }))
        
        alert.addAction(UIAlertAction(title: "Photo", style: .default, handler: { _ in
            print("User click Photo button")
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            print("User click Cancel button")
        }))
        
        self.present(alert, animated: true)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.showImageGalleryDetails,
            let viewController = segue.destination as? ImageGalleryDetailsViewController,
            let uri = sender as? String {
          
           // viewController.viewModel.inputs.configure(with: ImageGalleryProvider(), withUri: uri)
        }
    }
}

extension ImageGalleryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let margin = Constants.collectionViewLeftMargin + Constants.collectionViewRightMargin
        
        switch traitCollection.sizeClasses {
        case (.regular, .regular):
            return CGSize(width: (view.frame.width / Constants.noOfColumnsForIPad) - margin, height: Constants.cellHeight)
        default:
            return CGSize(width: (view.frame.width / Constants.noOfColumnsForIPhones) - margin, height: Constants.cellHeight)
        }
    }
}

extension ImageGalleryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
        performSegue(withIdentifier: Constants.showImageGalleryDetails, sender: nil)
    }
}
