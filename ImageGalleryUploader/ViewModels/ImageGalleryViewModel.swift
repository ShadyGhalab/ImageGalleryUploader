//
//  GalleryViewModel.swift
//
//  Created by Shady Mustafa on 16.07.19.
//

import Foundation
import ReactiveSwift
import CoreData
import os.log

fileprivate let logger = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "ImageGallery") // swiftlint:disable:this force_unwrapping

typealias SectionItems = ((IndexPath?) -> Int?)
typealias NumberOfSections = (() -> Int?)

protocol ImageGalleryViewInputs {
    func configure(with fileUploader: FilesUploading, fileStorageManager: FileStoring)
    func configure(sectionItems: SectionItems?, numberOfSections: NumberOfSections?)
    func viewDidLoad()
    func performBatchUpdatesStarted()
    func performBatchUpdatesCompeleted()
    func uploadResource(with data: Data?, name: String?)
}

protocol ImageGalleryViewOutputs {
    var insertedIndexPaths: Signal<[IndexPath], Never> { get }
    var performBatchUpdates: Signal<(), Never> { get }
    var reloadData: Signal<(), Never> { get }
    var loadingIndicatorStarted: Signal<(), Never> { get }
    var loadingIndicatorStopped: Signal<(), Never> { get }
    var uploadingProgress: Signal<Float, Never> { get }
    var uploadingFailed: Signal<(), Never> { get }
    var fetchedResultController: NSFetchedResultsController<Resource> { get }
}

protocol ImageGalleryViewProtocol: Any {
    var inputs: ImageGalleryViewInputs { get }
    var outputs: ImageGalleryViewOutputs { get }
}

final class ImageGalleryViewModel: NSObject, ImageGalleryViewInputs, ImageGalleryViewOutputs, ImageGalleryViewProtocol {
    
    var inputs: ImageGalleryViewInputs { return self }
    var outputs: ImageGalleryViewOutputs { return self }
    
    private var blockOperations: [BlockOperation] = []
    private var _fetchedResultsController: NSFetchedResultsController<Resource>? // swiftlint:disable:this identifier_name
    private var shouldReloadCollectionView: Bool = false
    private var sectionItems: SectionItems?
    private var numberOfSections: NumberOfSections?
    
    override init() {
        
        reloadData = reloadDataProperty.signal
        
        performBatchUpdates = performBatchUpdatesProperty.signal
        
        let dataAndNameSignal = Signal.zip(uploadedResourceDataProperty.signal.skipNil(),
                                           uploadedResourceNameProperty.signal.skipNil())
        
        loadingIndicatorStarted = dataAndNameSignal
            .withLatest(from: fileUploaderProperty.signal.skipNil())
            .on(value: { dataAndName, fileUploader in
                let data = dataAndName.0
                let name = dataAndName.1
                
                fileUploader.upload(data: data, resourceName: name, resourceType: .image)
            }).map { _ in () }
        
        let willStoreResouseDataInFile = didFinishUploadingWithResourceInfoProperty.signal.skipNil()
            .skipRepeats ( == )
            .withLatest(from: dataAndNameSignal.signal)
            .withLatest(from: fileStorageManagerProperty.signal.skipNil())
            .map { arg0 -> (String, Data, FileStoring) in
                let ((_, (data, name)), filesStoring) = arg0
                
                return (name, data, filesStoring)
        }
        
        let didStoreResouseDataInFile = willStoreResouseDataInFile
            .on(value: { resourceName, data, fileStorageManager  in
                do {
                    try fileStorageManager.replaceData(withResourceName: resourceName, for: data)
                } catch {
                    os_log("Failed to replace resource data in the file with name: %{public}@, with error: %{public}@",
                           log: logger, type: .info, resourceName, error.localizedDescription)
                }
            }).map { _ in () }
        
        let willStoredResourceInCoreData = didStoreResouseDataInFile.signal
            .zip(with: didFinishUploadingWithResourceInfoProperty.signal.skipNil())
            .withLatest(from: uploadedResourceNameProperty.signal.skipNil())
            .map { ($0.0.1, $0.1) }
        
        willStoredResourceInCoreData.observeValues { _ = Resource.make(id: $0.id,
                                                                       name: $1,
                                                                       createdAt: $0.createdAt,
                                                                       isUploaded: true) }
        insertedIndexPaths = viewDidLoadProperty.signal
            .combineLatest(with: insertedIndexPathProperty.signal.skipNil())
            .combineLatest(with: didStoreResouseDataInFile.signal)
            .map { [$0.0.1] }
            .skipRepeats(==)
        
        loadingIndicatorStopped = Signal.merge(didFinishUploadingWithResourceInfoProperty.signal.map { _ in () },
                                               didFinishUploadingWithErrorProperty.signal)
        
        uploadingProgress = uploadingProgressProperty.signal.skipNil()
        
        uploadingFailed = didFinishUploadingWithErrorProperty.signal
    }
    
    private let fileUploaderProperty = MutableProperty<FilesUploading?>(nil)
    private let fileStorageManagerProperty = MutableProperty<FileStoring?>(nil)
    func configure(with fileUploader: FilesUploading, fileStorageManager: FileStoring) {
        var filesUploading = fileUploader
        filesUploading.delegate = self
        fileUploaderProperty.value = fileUploader
        fileStorageManagerProperty.value = fileStorageManager
    }
    
    func configure(sectionItems: SectionItems?, numberOfSections: NumberOfSections?) {
        self.sectionItems = sectionItems
        self.numberOfSections = numberOfSections
    }
    
    private let viewDidLoadProperty = MutableProperty(())
    func viewDidLoad() {
        viewDidLoadProperty.value = ()
    }
    
    func performBatchUpdatesStarted() {
        blockOperations.forEach { $0.start() }
    }
    
    func performBatchUpdatesCompeleted() {
        blockOperations.removeAll(keepingCapacity: false)
    }
    
    private let insertedIndexPathProperty = MutableProperty<IndexPath?>(nil)
    private func willInsertItem(at indexPaths: IndexPath?) {
        insertedIndexPathProperty.value = indexPaths
    }
    
    private let reloadDataProperty = MutableProperty<()>(())
    private func reloadDataIfNeeded() {
        reloadDataProperty.value = ()
    }
    
    private let performBatchUpdatesProperty = MutableProperty<()>(())
    private func performBatchUpdatesIfNeeded() {
        performBatchUpdatesProperty.value = ()
    }
    
    private let uploadingCompletedProperty = MutableProperty<String?>(nil)
    private func uploadingCompleted(with id: String?) {
        uploadingCompletedProperty.value = id
    }
    
    private let uploadedResourceDataProperty = MutableProperty<Data?>(nil)
    private let uploadedResourceNameProperty = MutableProperty<String?>(nil)
    func uploadResource(with data: Data?, name: String?) {
        uploadedResourceDataProperty.value = data
        uploadedResourceNameProperty.value = name
    }
    
    private let didFinishUploadingWithResourceInfoProperty = MutableProperty<ResourceInfo?>(nil)
    private func didFinishUploading(with resourceInfo: ResourceInfo?) {
        didFinishUploadingWithResourceInfoProperty.value = resourceInfo
    }
    
    private let didFinishUploadingWithErrorProperty = MutableProperty<()>(())
    private func didFinishWithErrorUploading() {
        didFinishUploadingWithErrorProperty.value = ()
    }
    
    private let uploadingProgressProperty = MutableProperty<Float?>(nil)
    private func uploading(with progress: Float) {
        uploadingProgressProperty.value = progress
    }
    
    deinit {
        blockOperations.forEach { $0.start() }
        blockOperations.removeAll(keepingCapacity: false)
    }
    
    let insertedIndexPaths: Signal<[IndexPath], Never>
    let reloadData: Signal<(), Never>
    let performBatchUpdates: Signal<(), Never>
    let loadingIndicatorStarted: Signal<(), Never>
    let loadingIndicatorStopped: Signal<(), Never>
    let uploadingProgress: Signal<Float, Never>
    let uploadingFailed: Signal<(), Never>
}

extension ImageGalleryViewModel: NSFetchedResultsControllerDelegate {
    
    var fetchedResultController: NSFetchedResultsController<Resource> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController! // swiftlint:disable:this force_unwrapping
        }
        
        let fetchRequest: NSFetchRequest<Resource> = Resource.fetchRequest()
        let managedObjectContext = AppDelegate.shared.persistentContainer.viewContext
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        let resultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                           managedObjectContext: managedObjectContext,
                                                           sectionNameKeyPath: nil,
                                                           cacheName: nil)
        resultsController.delegate = self
        _fetchedResultsController = resultsController
        
        do {
            try _fetchedResultsController?.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror)")
        }
        return _fetchedResultsController! // swiftlint:disable:this force_unwrapping
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            insertItem(at: newIndexPath)
        default:
            break
        }
    }
    
    private func insertItem(at newIndexPath: IndexPath?) {
        if let numberOfSections = numberOfSections?(), numberOfSections > 0 {
            if let numberOfItems = sectionItems?(newIndexPath), numberOfItems == 0 {
                shouldReloadCollectionView = true
            } else {
                blockOperations.append(
                    BlockOperation(block: { [weak self] in
                        self?.willInsertItem(at: newIndexPath)
                    })
                )
            }
        } else {
            shouldReloadCollectionView = true
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if shouldReloadCollectionView {
            self.reloadDataIfNeeded()
        } else {
            self.performBatchUpdatesIfNeeded()
        }
    }
}

extension ImageGalleryViewModel: FilesUploaderDelegate {
    func didFinishUploading(for url: URL, resourceInfo: ResourceInfo?) {
        if let resourceInfo = resourceInfo {
            didFinishUploading(with: resourceInfo)
        } else {
            didFinishWithErrorUploading()
        }
    }
    
    func didChangeProgress(for url: URL, progress: Float) {
        uploading(with: progress)
    }
    
    func uploadFailed(for url: URL?, cancellationReason: UploadCancelReason?, error: Error?) {
        didFinishWithErrorUploading()
    }
    
    func backgroundTasksFinished() { }
}
