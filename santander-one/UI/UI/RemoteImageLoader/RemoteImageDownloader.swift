//
//  RemoteImageDownloader.swift
//  UI
//
//  Created by Jorge Ouahbi Martín
//

import CoreFoundationLib
import Foundation
import ImageIO
import UIKit
import SwiftyGif

// MARK: - ImageLoaderProtocol -

/// The idea is to use the setImage method of both UIImageView and UIButton.
/// Although now it is very simple, the idea would be to put a disk cache and to centralize the
/// management of the images. But mainly to homogenize the functions of each part of the software, until it is cohesive.
///
/// setImage() -> load[Manual]RemoteImage()                                                             |
///                     /\                                                                                    |
///                    /     loadImageGif(url: url, completion: completion)         |   \
///                   /                                                                                          |    [CACHE]
///    loadImage(url: url, completion: completion)                                                        |  /
///
public protocol ImageLoaderProtocol {
    // The completions with valid image will be executes asynchronously in main queue

    typealias RemoteImageCompletion = (UIImage?) -> Void
    func loadImageGif(url: URL, completion: (RemoteImageCompletion)?) -> CancelableTask?
    func loadImage(url: URL, completion: (RemoteImageCompletion)?) -> CancelableTask?
}

// MARK: - RemoteDownloaderProtocol -

public protocol RemoteDownloaderProtocol {
    typealias RemoteImageDownloadCompletionHandler = (Result<Data, Error>) -> Void
    func downloadContent(fromUrl: URL, completionHandler: @escaping RemoteImageDownloadCompletionHandler) -> CancelableTask?
    func urlSession() -> URLSession
}

// MARK: - RemoteImageDownloader

final class RemoteImageDownloader: ImageLoaderProtocol {
    // A convenient default manager

    public static var shared = RemoteImageDownloader()

    private let allowedDiskSize = 100 * 1024 * 1024
    private lazy var cache: URLCache = {
        URLCache(memoryCapacity: 0, diskCapacity: allowedDiskSize, diskPath: "remoteImageCache")
    }()

    // MARK: - RemoteImageLoaderProtocol -

    public func loadImageGif(url: URL, completion: (RemoteImageCompletion)? = nil) -> CancelableTask? {
        let result = downloadContent(fromUrl: url, completionHandler: { result in
            switch result {
            case .success(let data):
                guard let image = try? UIImage(gifData: data) else {
                    completion?(nil)
                    return
                }
                completion?(image)
            case .failure(let error):
                print("Error: loading a image\(error.localizedDescription)")
                completion?(nil)
                return
            }
        })
        return result
    }

    func loadImage(url: URL, completion: (RemoteImageCompletion)? = nil) -> CancelableTask? {
        let result = downloadContent(fromUrl: url, completionHandler: { result in
            switch result {
            case .success(let data):
                guard let image = UIImage(data: data) else {
                    completion?(nil)
                    return
                }
                completion?(image)
            case .failure(let error):
                print("Error: loading a image \(error.localizedDescription)")
                completion?(nil)
                return
            }
        })
        return result
    }
}

// MARK: - RemoteDownloaderProtocol -

extension RemoteImageDownloader: RemoteDownloaderProtocol {
    // MARK: - Cached URLSeesion  -

    func urlSession() -> URLSession {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.requestCachePolicy = .returnCacheDataElseLoad
        sessionConfiguration.urlCache = cache
        return URLSession(configuration: sessionConfiguration)
    }

    private func downloadContent(fromUrlString: String, completionHandler: @escaping RemoteImageDownloadCompletionHandler) -> CancelableTask? {
        guard let downloadUrl = URL(string: fromUrlString) else { return nil }
        return downloadContent(fromUrl: downloadUrl, completionHandler: completionHandler)
    }

    func peekCache(fromUrl: URL) -> Data? {
        return cache.cachedResponse(for: URLRequest(url: fromUrl))?.data
    }

    func downloadContent(fromUrl: URL, completionHandler: @escaping RemoteImageDownloadCompletionHandler) -> CancelableTask? {
        let urlRequest = URLRequest(url: fromUrl)
        // First try to fetching cached data if exist
        if let cachedData = cache.cachedResponse(for: urlRequest) {
            completionHandler(.success(cachedData.data))
            return nil
        } else {
            // No cached data, download content than cache the data
            let result: URLSessionTask = urlSession().dataTask(with: urlRequest) { data, response, error in

                if let error = error {
                    completionHandler(.failure(error))
                } else {
                    if let response = response, let data = data {
                        let cachedData = CachedURLResponse(response: response, data: data)
                        self.cache.storeCachedResponse(cachedData, for: urlRequest)

                        completionHandler(.success(data))
                    } else {
                        // No error and no data
                        completionHandler(.failure(NSError(domain: "eu.onepap.remoteimageloader.downloadContent", code: NSURLErrorUnknown, userInfo: nil)))
                    }
                }
            }
            result.resume()
            return result
        }
    }
}
