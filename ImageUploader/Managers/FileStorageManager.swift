//
//  FileStorageManager.swift
//  ImageUploader
//
//  Created by Shady Mustafa on 22.07.19.
//  Copyright © 2019 Spark Network. All rights reserved.
//

import Foundation

protocol FilesStoring {
    func writeUploadedDataToFile(with data: Data, withResourceName resourceName: String) throws -> URL
    func removeData(with resourceName: String) throws 
}

final class FileStorageManager: FilesStoring {
     private let fileManager = FileManager.default
   
     lazy var documentUrl: URL = {
         fileManager.urls(for: .documentDirectory, in: .userDomainMask).first! // swiftlint:disable:this force_unwrapping
     }()
    
    func writeUploadedDataToFile(with data: Data, withResourceName resourceName: String) throws -> URL {
        let url = documentUrl.appendingPathComponent(resourceName)
        
        try data.write(to: url)
        
        return url
    }
    
    func removeData(with resourceName: String) throws {
        let url = documentUrl.appendingPathComponent(resourceName)
        
        try fileManager.removeItem(at: url)
    }
}
