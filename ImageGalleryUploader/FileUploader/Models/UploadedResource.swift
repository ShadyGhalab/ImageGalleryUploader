//
//  UploadedResource.swift
//  ImageUploader
//
//  Created by Shady Mustafa on 21.07.19.
//  Copyright © 2019 Spark Network. All rights reserved.
//

import Foundation

struct UploadedResource: Codable {
    let publicId: String
    let version: Float
    let signature: String
    let width: Int
    let height: Int
    let format: String
    let resourceType: String
    let createdAt: String
    let tags: [String]?
    let bytes: Double
    let type: String
    let etag: String
    let url: String
    let secureUrl: String
    let originalFilename: String
    let placeholder: Bool
    
    private enum CodingKeys: String, CodingKey {
        case publicId = "public_id"
        case createdAt = "created_at"
        case secureUrl = "secure_url"
        case originalFilename = "original_filename"
        case resourceType = "resource_type"
        case url = "url"
        case etag = "etag"
        case bytes = "bytes"
        case tags = "tags"
        case format = "format"
        case width = "width"
        case height = "height"
        case signature = "signature"
        case version = "version"
        case type = "type"
        case placeholder = "placeholder"
    }
}
