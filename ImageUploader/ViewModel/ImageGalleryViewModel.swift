//
//  GalleryViewModel.swift
//  Mobile
//
//  Created by Shady Mustafa on 16.07.19.
//  Copyright © 2019 Ebay. All rights reserved.
//

import Foundation
import ReactiveSwift
import CoreData
import os.log

fileprivate let logger = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "ImageGallery") // swiftlint:disable:this force_unwrapping

typealias SectionItems = ((IndexPath?) -> Int?)
typealias NumberOfSections = (() -> Int?)

protocol ImageGalleryViewInputs {
    func configure(with fileUploader: FilesUploader, fileStorageManager: FilesStoring)
    func configure(sectionItems: SectionItems?, numberOfSections: NumberOfSections?)
    func viewDidLoad()
    func performBatchUpdatesStarted()
    func performBatchUpdatesCompeleted()
    func uploadResource(with data: Data?, name: String?)
}

protocol ImageGalleryViewOutputs {
    var insertedIndexPaths: Signal<[IndexPath], Never> { get }
    var updatedIndexPaths: Signal<[IndexPath], Never> { get }
    var deletedIndexPaths: Signal<[IndexPath], Never> { get }
    var insertedSection: Signal<NSIndexSet, Never> { get }
    var updatedSection: Signal<NSIndexSet, Never> { get }
    var deletedSection: Signal<NSIndexSet, Never> { get }
    var performBatchUpdates: Signal<(), Never> { get }
    var reloadData: Signal<(), Never> { get }
    var fetchedResultController: NSFetchedResultsController<Resource> { get }
    var loadingIndicatorStarted: Signal<(), Never> { get }
    var loadingIndicatorStopped: Signal<(), Never> { get }
    var uploadingProgress: Signal<Float, Never> { get }
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
        insertedIndexPaths = viewDidLoadProperty.signal
            .combineLatest(with: insertedIndexPathProperty.signal.skipNil())
            .map { [$0.1] }
        
        updatedIndexPaths = viewDidLoadProperty.signal
            .combineLatest(with: updatedIndexPathProperty.signal.skipNil())
            .map { [$0.1] }
        
        deletedIndexPaths = viewDidLoadProperty.signal
            .combineLatest(with: updatedIndexPathProperty.signal.skipNil())
            .map { [$0.1] }
        
        insertedSection = viewDidLoadProperty.signal
            .combineLatest(with: insertedSectionProperty.signal.skipNil())
            .map { NSIndexSet(index: $0.1) }
        
        updatedSection = viewDidLoadProperty.signal
            .combineLatest(with: updatedSectionProperty.signal.skipNil())
            .map { NSIndexSet(index: $0.1) }
        
        deletedSection = viewDidLoadProperty.signal
            .combineLatest(with: deletedSectionProperty.signal.skipNil())
            .map { NSIndexSet(index: $0.1) }
        
        reloadData = reloadDataProperty.signal
        
        performBatchUpdates = performBatchUpdatesProperty.signal
        
        resourceInfoProperty.signal.skipNil()
            .skipRepeats ( == )
            .withLatest(from: uploadedResourceNameProperty.signal.skipNil())
            .observeValues { resourceInfo, name in
                Resource.make(id: resourceInfo.id, name: name, createdAt: resourceInfo.createdAt, isUploaded: true)
        }
        
        let dataAndNameSignal = Signal.zip(uploadedResourceDataProperty.signal.skipNil(),
                                           uploadedResourceNameProperty.signal.skipNil())

        dataAndNameSignal.withLatest(from: fileUploaderProperty.signal.skipNil())
            .observeValues { dataAndName, fileUploader in
                let data = dataAndName.0
                let name = dataAndName.1
               
                fileUploader.upload(data: data, resourceName: name)
        }
        
        resourceInfoProperty.signal.skipNil()
            .skipRepeats ( == )
            .combineLatest(with: dataAndNameSignal.signal)
            .combineLatest(with: fileStorageManagerProperty.signal.skipNil())
            .map { ($0.0.1.1, $0.0.1.0, $0.1) }
            .observeValues { resourceName, data, fileStorageManager in
                do {
                    try fileStorageManager.removeData(for: resourceName)
                    try _ = fileStorageManager.write(data: data, withResourceName: resourceName)
                } catch {
                    os_log("Failed to write resource data in the file with name: %{public}@, with error: %{public}@",
                           log: logger, type: .info, resourceName, error.localizedDescription)
                }
        }
        
        loadingIndicatorStarted = dataAndNameSignal
            .map { _ in () }
        
        loadingIndicatorStopped = didFinishUploadingProperty.signal
        
        uploadingProgress = uploadingProgressProperty.signal.skipNil()
    }
    
    private let fileUploaderProperty = MutableProperty<FilesUploader?>(nil)
    private let fileStorageManagerProperty = MutableProperty<FilesStoring?>(nil)
    func configure(with fileUploader: FilesUploader, fileStorageManager: FilesStoring) {
        fileUploader.delegate = self
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
    
    private let updatedIndexPathProperty = MutableProperty<IndexPath?>(nil)
    private func willUpdateItem(at indexPath: IndexPath?) {
        updatedIndexPathProperty.value = indexPath
    }
    
    private let deletedIndexPathProperty = MutableProperty<IndexPath?>(nil)
    private func willWillItem(at indexPath: IndexPath?) {
        deletedIndexPathProperty.value = indexPath
    }
    
    private let insertedSectionProperty = MutableProperty<Int?>(nil)
    private func willInsertSection(atSectionIndex sectionIndex: Int) {
        insertedSectionProperty.value = sectionIndex
    }
    
    private let updatedSectionProperty = MutableProperty<Int?>(nil)
    private func willUpdateSection(atSectionIndex sectionIndex: Int) {
        updatedSectionProperty.value = sectionIndex
    }
    
    private let deletedSectionProperty = MutableProperty<Int?>(nil)
    private func willDeleteSection(atSectionIndex sectionIndex: Int) {
        deletedSectionProperty.value = sectionIndex
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
    
    private let resourceInfoProperty = MutableProperty<ResourceInfo?>(nil)
    private func insertResource(with resourceInfo: ResourceInfo?) {
        resourceInfoProperty.value = resourceInfo
    }
    
    private let didFinishUploadingProperty = MutableProperty<()>(())
    private func didFinishUploading() {
        didFinishUploadingProperty.value = ()
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
    let updatedIndexPaths: Signal<[IndexPath], Never>
    let deletedIndexPaths: Signal<[IndexPath], Never>
    let insertedSection: Signal<NSIndexSet, Never>
    let updatedSection: Signal<NSIndexSet, Never>
    let deletedSection: Signal<NSIndexSet, Never>
    let reloadData: Signal<(), Never>
    let performBatchUpdates: Signal<(), Never>
    let loadingIndicatorStarted: Signal<(), Never>
    let loadingIndicatorStopped: Signal<(), Never>
    let uploadingProgress: Signal<Float, Never>
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
        case .update:
            updateItem(at: indexPath)
        case .delete:
            deleteItem(at: indexPath)
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
    
    private func updateItem(at indexPath: IndexPath?) {
        blockOperations.append(
            BlockOperation(block: { [weak self] in
                self?.willUpdateItem(at: indexPath)
            })
        )
    }
    
    private func deleteItem(at indexPath: IndexPath?) {
        if let numberOfItems = sectionItems?(indexPath), numberOfItems == 1 {
            shouldReloadCollectionView = true
        } else {
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    self?.willUpdateItem(at: indexPath)
                })
            )
        }
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                           didChange sectionInfo: NSFetchedResultsSectionInfo,
                           atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    self?.willInsertSection(atSectionIndex: sectionIndex)
                })
            )
        case .update:
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    self?.willUpdateSection(atSectionIndex: sectionIndex)
                })
            )
        case .delete:
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    self?.willDeleteSection(atSectionIndex: sectionIndex)
                })
            )
        default:
            break
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
        insertResource(with: resourceInfo)
        didFinishUploading()
    }
    
    func didChangeProgress(for url: URL, progress: Float) {
        uploading(with: progress)
    }
    
    func uploadFailed(for url: URL?, resumeData: Data?, cancellationReason: UploadCancelReason?, error: Error?) {
        didFinishUploading()
    }
    
    func backgroundTasksFinished() { }
}
