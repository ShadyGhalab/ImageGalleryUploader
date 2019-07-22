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

struct FileStorageManager: FilesStoring {
     let fileManager = FileManager.default
    
     func writeUploadedDataToFile(with data: Data, withResourceName resourceName: String) throws -> URL {
        let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(resourceName)
        
        try data.write(to: url!) // swiftlint:disable:this force_unwrapping
        
        return url! // swiftlint:disable:this force_unwrapping
    }
    
    func removeData(with resourceName: String) throws {
        let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(resourceName)
        
        try fileManager.removeItem(at: url!)  // swiftlint:disable:this force_unwrapping
    }
}
