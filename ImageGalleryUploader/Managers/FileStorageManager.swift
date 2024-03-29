//
//  FileStorageManager.swift
//  ImageUploader
//
//  Created by Shady Mustafa on 22.07.19.
//

import Foundation

protocol FileStoring: AnyObject {
    var documentUrl: URL { get }
    
    func write(data: Data, withResourceName resourceName: String) throws -> URL
    func removeData(for resourceName: String) throws
    func replaceData(withResourceName resourceName: String, for data: Data) throws
}

final class FileStorageManager: FileStoring {
    private let fileManager: FileManager
   
     lazy var documentUrl: URL = {
         fileManager.urls(for: .documentDirectory, in: .userDomainMask).first! // swiftlint:disable:this force_unwrapping
     }()
    
    init(fileManager: FileManager = FileManager.default) {
        self.fileManager = fileManager
    }
    
    func write(data: Data, withResourceName resourceName: String) throws -> URL {
        let url = documentUrl.appendingPathComponent(resourceName)
        
        try data.write(to: url)
        
        return url
    }
    
    func removeData(for resourceName: String) throws {
        let url = documentUrl.appendingPathComponent(resourceName)
        
        try fileManager.removeItem(at: url)
    }
    
    func replaceData(withResourceName resourceName: String, for data: Data) throws {
        try removeData(for: resourceName)
        try _ = write(data: data, withResourceName: resourceName)
    }
}
