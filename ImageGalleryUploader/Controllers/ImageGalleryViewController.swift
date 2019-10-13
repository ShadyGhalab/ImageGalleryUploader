//
//  ImageGalleryViewController.swift
//
//  Created by Shady Mustafa on 16.07.19.
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
    static let compressionQuality: CGFloat = 0.55
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
    
    private lazy var sectionItems: SectionItems = { indexPath in
        guard let section = indexPath?.section else { return nil }
        return self.collectionView.numberOfItems(inSection: section)
    }
    
    private lazy var numberOfSections: NumberOfSections = { 
        self.collectionView.numberOfSections
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDataSource()
        bindViewModel()
        viewModel.inputs.configure(sectionItems: sectionItems, numberOfSections: numberOfSections)
        viewModel.inputs.viewDidLoad()
    }
    
    private func setupDataSource() {
        dataSource = ImageGalleryDataSource(fetchedResultController: viewModel.outputs.fetchedResultController)
    }
    
    private func bindViewModel() {
        viewModel.outputs.insertedIndexPaths
            .observe(on: UIScheduler())
            .observeValues { [weak self] in
                self?.collectionView.insertItems(at: $0)
                self?.scrollCollectionViewToBottom()
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
        
        viewModel.outputs.loadingIndicatorStarted
            .observe(on: UIScheduler())
            .observeValues { [weak self] in
                self?.navigationItem.titleView?.isHidden = false
        }
        
        viewModel.outputs.loadingIndicatorStopped
            .observe(on: UIScheduler())
            .observeValues { [weak self] in
                self?.navigationItem.titleView?.isHidden = true
        }
        
        viewModel.outputs.uploadingProgress
            .observe(on: UIScheduler())
            .observeValues { [weak self] progress in
                (self?.navigationItem.titleView as? LoadingView)?.viewModel.inputs.configure(with: progress)
        }
        
        viewModel.outputs.uploadingFailed
            .observe(on: UIScheduler())
            .observeValues { [weak self] in
                self?.showAlertErrorMessage()
        }
        
        viewModel.outputs.reloadData
            .observe(on: UIScheduler())
            .observeValues { [weak self] in
                self?.collectionView.reloadData()
        }        
    }
    
    private func showAlertErrorMessage() {
        let alert = UIAlertController(title: nil, message: "imageGallery.alert.uploadFailed".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "imageGallery.alert.uploadFailed.Ok".localized, style: .default))

        present(alert, animated: false)
    }
    
    @IBAction func addResourceBarButtonTapped(_ sender: Any) {
        guard let addBarButtonItem = sender as? UIBarButtonItem else {
            return
        }

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "imageGallery.alert.Camera".localized, style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "imageGallery.alert.Photo".localized, style: .default, handler: { _ in
            self.openPhotoLibrary()
        }))
        
        alert.addAction(UIAlertAction(title: "imageGallery.alert.Cancel".localized, style: .cancel))
       
        // Known bug with iOS12 to fix constraint error
        // https://stackoverflow.com/questions/55653187/swift-default-alertviewcontroller-breaking-constraints
        alert.view.addSubview(UIView())

        if let presenter = alert.popoverPresentationController,
            let bounds = addBarButtonItem.view?.bounds {
            presenter.sourceView = addBarButtonItem.view
            presenter.sourceRect = bounds
        }
        
         present(alert, animated: false)
    }
    
    private func scrollCollectionViewToBottom() {
        let contentHeight = collectionView.contentSize.height
        let heightAfterInserts = collectionView.frame.size.height - (collectionView.contentInset.top + collectionView.contentInset.bottom)
        
        if contentHeight > heightAfterInserts {
            collectionView.setContentOffset(CGPoint(x: 0, y: collectionView.contentSize.height - collectionView.frame.size.height), animated: true)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.showImageGalleryDetails,
            let viewController = segue.destination as? ImageGalleryDetailsViewController,
            let resource = sender as? Resource {
            
            viewController.viewModel.inputs.configure(with: resource)
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
        guard let resource = dataSource?.resource(for: indexPath) else { return }
        
        performSegue(withIdentifier: Constants.showImageGalleryDetails, sender: resource)
    }
}

extension ImageGalleryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func openPhotoLibrary() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        let image = info[.editedImage] as? UIImage
        let fileUrl = info[.imageURL] as? URL
        let resourceName = fileUrl?.lastPathComponent ?? UUID().uuidString
        let resourceData = image?.jpegData(compressionQuality: Constants.compressionQuality)
        
        viewModel.inputs.uploadResource(with: resourceData, name: resourceName)
       
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}

fileprivate extension UIBarButtonItem {
    var view: UIView? {
        guard let view = value(forKey: "view") as? UIView else {
            return nil
        }
        
        return view
    }
}
