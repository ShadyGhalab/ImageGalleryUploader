//
//  Resource+CoreDataProperties.swift
//  ImageUploader
//
//  Created by Shady Mustafa on 20.07.19.
//  Copyright © 2019 Spark Network. All rights reserved.
//
//

import Foundation
import CoreData


extension Resource {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Resource> {
        return NSFetchRequest<Resource>(entityName: "Resource")
    }

    @NSManaged public var name: String?
    @NSManaged public var id: String?
    @NSManaged public var isUploaded: Bool
    @NSManaged public var createdAt: NSDate?

}
