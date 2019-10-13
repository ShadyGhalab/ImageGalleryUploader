//
//  ImageGalleryDataSourceTests.swift
//  ImageUploaderTests
//
//  Created by Shady Mustafa on 23.07.19.
//

import XCTest
import CoreData
@testable import ImageGalleryUploader

class ImageGalleryDataSourceTests: XCTestCase {

    private var dataSource: ImageGalleryDataSource!
  
    override func setUp() {
        dataSource = ImageGalleryDataSource(fetchedResultController: FetchedResultsControllerMock())
    }
    
    func testValueInDataSource() {
        
        let collectionView = UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: UICollectionViewFlowLayout())
        
        collectionView.dataSource = dataSource
        
        XCTAssertEqual(collectionView.numberOfSections, 1)
        XCTAssertEqual(collectionView.numberOfItems(inSection: 0), 2)
    }
}

fileprivate class FetchedResultsControllerMock: NSFetchedResultsController<Resource> {
    override var sections: [NSFetchedResultsSectionInfo]? {
        return [SectionInfo()]
    }
}

fileprivate class SectionInfo: NSFetchedResultsSectionInfo {
    var name: String = "SectionInfo"
    var indexTitle: String?
    var numberOfObjects: Int = 2
    var objects: [Any]?
}
