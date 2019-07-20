//
//  FileUploader.swift
//  ImageUploader
//
//  Created by Shady Mustafa on 20.07.19.
//  Copyright © 2019 Spark Network. All rights reserved.
//

import Foundation
import UIKit
import os.log

fileprivate let logger = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "FilesDownloader") // swiftlint:disable:this force_unwrapping

fileprivate extension URLSessionTask {
    var taskRequestUrl: URL {
        return (originalRequest?.url ?? currentRequest?.url)! // swiftlint:disable:this force_unwrapping
    }
}

enum ResourceType: String {
    case image
    case video
}

public enum UploadCancelReason {
    case forceQuit
    case backgroundUpdatesDisabled
    case insufficientSystemResources
    case failedToWriteToFile
    case malformedUrl
    
    init?(from number: NSNumber) {
        switch number.intValue {
        case NSURLErrorCancelledReasonUserForceQuitApplication:
            self = .forceQuit
        case NSURLErrorCancelledReasonBackgroundUpdatesDisabled:
            self = .backgroundUpdatesDisabled
        case NSURLErrorCancelledReasonInsufficientSystemResources:
            self = .insufficientSystemResources
        case NSURLErrorCannotWriteToFile:
            self = .failedToWriteToFile
        case NSURLErrorBadURL:
            self = .malformedUrl
        default:
            return nil
        }
    }
}

public protocol FilesUploaderDelegate: class {
    func didFinishUploading(url: URL)
    func didChangeProgress(for url: URL, progress: Float)
    func uploadFailed(for url: URL?, resumeData: Data?, cancellationReason: UploadCancelReason?, error: Error?)
    func backgroundTasksFinished()
}

final class FilesUploader: NSObject {
    private var uploadSession: URLSession!
    private var cloudName: String!
    
    weak var delegate: FilesUploaderDelegate?

    public convenience init(sessionIdentifier: String, cloudName: String) {
        let configuration = URLSessionConfiguration.background(withIdentifier: sessionIdentifier)
        self.init(configuration: configuration, cloudName: cloudName)
    }
    
    init(configuration: URLSessionConfiguration, cloudName: String) {
        super.init()
        self.uploadSession = URLSession(configuration: configuration, delegate: self, delegateQueue: .main)
        self.cloudName = cloudName
    }
    
    func upload(data: Data, parameters: [String: Any], resourceName: String, resourceType: ResourceType = .image) {
        let boundaryConstant = UUID().uuidString
        
        if let url = buildUrl(for: resourceType),
            let urlRequest = self.urlRequest(with: url, boundaryConstant: boundaryConstant) {
            
            let data = buildUploadedData(withResourceData: data, boundaryConstant: boundaryConstant, parameters: parameters)
            
            do {
                let url = try writeUploadedDataToFile(data: data, withResourceName: resourceName)
                uploadSession.uploadTask(with: urlRequest, fromFile: url).resume()
            } catch {
                os_log("Failed to write resource data in the file for url: %{public}@, with error: %{public}@",
                       log: logger, type: .info, String(describing: urlRequest.url?.absoluteString), error.localizedDescription)
           
                let uploadCancelReason = UploadCancelReason(from: NSNumber(integerLiteral: -3003))
                delegate?.uploadFailed(for: nil, resumeData: nil, cancellationReason: uploadCancelReason, error: error)
            }
        } else {
                os_log("Failed to create URL for resource name: %{public}@, with resource type: %{public}@", log: logger, type: .info,
                   resourceName, resourceType.rawValue)
            
                let uploadCancelReason = UploadCancelReason(from: NSNumber(integerLiteral: -1000))
                delegate?.uploadFailed(for: nil, resumeData: nil, cancellationReason: uploadCancelReason, error: nil)
        }
    }
    
    private func containTask(for url: URL, completionHandler: @escaping ((Bool) -> Void)) {
        uploadSession.getAllTasks { tasks in
            guard tasks.map({ $0.taskRequestUrl }).contains(url) else { return completionHandler(false) }
            completionHandler(true)
        }
    }
    
    private func urlRequest(with url: URL, boundaryConstant: String) -> URLRequest? {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        let contentType = "multipart/form-data;boundary="+boundaryConstant
        urlRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        return urlRequest
    }
    
    private func buildUrl(for resourceType: ResourceType) -> URL! {
        guard let cloudName = self.cloudName else { return nil }
        let urlString = "https://api.cloudinary.com/v1_1/\(cloudName)/\(resourceType.rawValue)/upload"
       
        return URL(string: urlString)! // swiftlint:disable:this force_unwrapping
    }
    
    private func buildUploadedData(withResourceData resourceData: Data, boundaryConstant: String, parameters: [String: Any]) -> Data {
        var data = Data()
        //swiftlint:disable force_unwrapping
        data.append("\r\n--\(boundaryConstant)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"file\"; filename=\"file.png\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        data.append(resourceData)
        
        for (key, value) in parameters {
            data.append("\r\n--\(boundaryConstant)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".data(using: .utf8)!)
        }
        
        data.append("\r\n--\(boundaryConstant)--\r\n".data(using: .utf8)!)
        //swiftlint:enable force_unwrapping
        
        return data
    }
    
    private func writeUploadedDataToFile(data: Data, withResourceName resourceName: String) throws -> URL {
        let fileManager = FileManager.default
        let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(resourceName)
        
        try data.write(to: url!) // swiftlint:disable:this force_unwrapping
        
        return url! // swiftlint:disable:this force_unwrapping
    }
}

extension FilesUploader: URLSessionDataDelegate {
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        os_log("Uploading... : %{public}@", log: logger, type: .info, String(data: data, encoding: .utf8) ?? "Couldn't convert Data to String")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        guard totalBytesExpectedToSend != NSURLSessionTransferSizeUnknown,
            totalBytesExpectedToSend != 0 else { return }
        
        delegate?.didChangeProgress(for: task.taskRequestUrl,
                                    progress: Float(totalBytesSent) / Float(totalBytesExpectedToSend))
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        os_log("Finished task for url: %{public}@, with error: %{public}@", log: logger, type: .info,
               task.taskRequestUrl.absoluteString, error?.localizedDescription ?? "no error")
        
        guard let error = error else {
            delegate?.didFinishUploading(url: task.taskRequestUrl)
            return
        }
        
        let url = task.taskRequestUrl
        
        containTask(for: url) { [weak self] isValidUrl in
            if isValidUrl {
                let nsError = error as NSError
                let resumeData = nsError.userInfo[NSURLSessionDownloadTaskResumeData] as? Data
                let cancelReason = (nsError.userInfo[NSURLErrorBackgroundTaskCancelledReasonKey] as? NSNumber).flatMap { UploadCancelReason(from: $0) }
                
                self?.delegate?.uploadFailed(for: url, resumeData: resumeData, cancellationReason: cancelReason, error: nsError)
            }
        }
    }
    
    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        os_log("urlSessionDidFinishEvents called", log: logger, type: .info)
        delegate?.backgroundTasksFinished()
    }
}