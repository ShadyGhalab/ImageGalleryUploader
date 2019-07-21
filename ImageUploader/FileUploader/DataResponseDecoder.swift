//
//  DataResponseDecoder.swift
//  ImageUploader
//
//  Created by Shady Mustafa on 21.07.19.
//  Copyright © 2019 Spark Network. All rights reserved.
//

import Foundation
import ReactiveSwift

public struct ResourceInfo {
    let id: String
    let createdAt: String
}

public protocol DecodedItem {
    associatedtype JSONResponseStructure: Codable
    associatedtype Model
    
    var customDateFormat: String? { get }
    
    func unwrapModel(_ jsonDecodingResult: JSONResponseStructure) -> Model?
}

struct UploadedDecodedItem: DecodedItem {
    
    typealias JSONResponseStructure = UploadedResource
    typealias Model = ResourceInfo
    
    func unwrapModel(_ jsonDecodingResult: JSONResponseStructure) -> ResourceInfo? {
        return ResourceInfo(id: jsonDecodingResult.publicId, createdAt: jsonDecodingResult.createdAt)
    }

    var customDateFormat: String? { return nil }
}

enum DataResponseDecodeError: Error {
    case decodeToModelFailed
    case decodeToJsonFailed
}

public protocol DataResponseDecoding {
    func decodeModel<D: DecodedItem>(from data: Data, for decodedItem: D) throws -> D.Model
    func decodeModel<D: DecodedItem>(from json: [String: Any], for decodedItem: D) throws -> D.Model where D.Model: Decodable
    func decodeJson(from data: Data) throws -> [String: Any]
}

public struct DataResponseDecoder: DataResponseDecoding {
    public init() {}
    
    public func decodeModel<D: DecodedItem>(from data: Data, for decodedItem: D) throws -> D.Model {
        let decoder = JSONDecoder.makeDecoder(with: decodedItem.customDateFormat)
        let jsonResultModel = try decoder.decode(D.JSONResponseStructure.self, from: data)
        if let model = decodedItem.unwrapModel(jsonResultModel) {
            return model
        } else {
            throw DataResponseDecodeError.decodeToModelFailed
        }
    }
    
    public func decodeModel<D: DecodedItem>(from json: [String: Any], for decodedItem: D) throws -> D.Model {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try decodeModel(from: data, for: decodedItem)
    }
    
    public func decodeJson(from data: Data) throws -> [String: Any] {
        let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
        guard let jsonDict = json as? [String: Any] else {
            throw DataResponseDecodeError.decodeToJsonFailed
        }
        return jsonDict
    }
}

public extension JSONDecoder {
    static func makeDecoder(with customDateFormat: String?) -> JSONDecoder {
        guard let customDateFormat = customDateFormat else { return JSONDecoder() }
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = customDateFormat
        decoder.dateDecodingStrategy = .formatted(formatter)
        return decoder
    }
}
