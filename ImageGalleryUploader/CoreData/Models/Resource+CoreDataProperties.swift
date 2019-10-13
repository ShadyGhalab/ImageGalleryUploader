//
//  Resource+CoreDataProperties.swift
//  ImageUploader
//
//  Created by Shady Mustafa on 20.07.19.
//  Copyright © 2019 Babylon Health. All rights reserved.
//
//

import Foundation
import CoreData

fileprivate let isoDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    if let tmZone = TimeZone(abbreviation: "UTC") {
        dateFormatter.timeZone = tmZone
    }
    return dateFormatter
}()

extension Resource {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Resource> {
        return NSFetchRequest<Resource>(entityName: "Resource")
    }

    @NSManaged public var name: String?
    @NSManaged public var id: String?
    @NSManaged public var isUploaded: Bool
    @NSManaged public var createdAt: NSDate?

    static func make(id: String, name: String, createdAt: String, isUploaded: Bool) -> Resource {
        let appDelegate = AppDelegate.shared
        
        let resource = Resource(context: appDelegate.persistentContainer.viewContext)
        resource.createdAt = isoDateFormatter.date(from: createdAt) as NSDate?
        resource.isUploaded = isUploaded
        resource.id = id
        resource.name = name
        
        appDelegate.saveContext()
        
        return resource
    }
}
