//
//  ImageGalleryDataSource.swift
//
//  Created by Shady Mustafa on 17.07.19.
//  Copyright © 2019 Babylon Health. All rights reserved.
//

import UIKit
import CoreData

private enum Constants {
    static let ImageGalleryCellIdentififer = "ImageGalleryCellIdentififer"
}

final class ImageGalleryDataSource: NSObject, UICollectionViewDataSource {

    private var fetchedResultController: NSFetchedResultsController<Resource>
    
    init(fetchedResultController: NSFetchedResultsController<Resource>) {
        self.fetchedResultController = fetchedResultController
    }
  
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.ImageGalleryCellIdentififer,
                                                      for: indexPath) as? ImageGalleryCollectionViewCell
        let resource = fetchedResultController.fetchedObjects?[indexPath.item]
      
        cell?.viewModel.inputs.configure(with: resource)
        
        return cell ?? UICollectionViewCell()
    }
}

extension ImageGalleryDataSource {
    func resource(for indexPath: IndexPath) -> Resource? {
        return fetchedResultController.fetchedObjects?[indexPath.item]
    }
}
