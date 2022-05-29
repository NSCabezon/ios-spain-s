//
//  GetOfferImageUseCase.swift
//  PrivateMenu
//
//  Created by Boris Chirino Fernandez on 13/4/22.
//

import OpenCombine
import OpenCombineFoundation
import CoreFoundationLib

public protocol GetImageUseCase {
    func fetchImageFromUrl(_ url: URL) -> AnyPublisher<Data, Error>
}

struct DefaultGetOfferImageUseCase {
    enum APIError: Error, LocalizedError {
        case unknown, apiError(reason: String)
        var errorDescription: String? {
            switch self {
            case .unknown:
                return "Unknown error"
            case .apiError(let reason):
                return reason
            }
        }
    }
    private let imageCache = ImageCache.shared
}

extension DefaultGetOfferImageUseCase: GetImageUseCase {
    func fetchImageFromUrl(_ url: URL) -> AnyPublisher<Data, Error> {
        guard let _ = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return Fail(error: NSError(description: "invalid-url")).eraseToAnyPublisher()
        }
        return getFromUrl(url)
    }
    
    private func getFromUrl(_ url: URL)  -> AnyPublisher<Data, Error> {
        if let imageData = imageCache[url.absoluteString] {
            return Just(imageData as Data).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
      return URLSession.shared.ocombine.dataTaskPublisher(for: url)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse,
                        200..<300 ~= httpResponse.statusCode else { throw APIError.unknown }
                self.imageCache[url.absoluteString] = NSData(data: data)
                return data
            }
            .mapError { error in
                if let error = error as? APIError {
                    return error
                } else {
                    return APIError.apiError(reason: error.localizedDescription)
                }
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Image cache

private class ImageCache {
    static let shared = ImageCache()
    private var cache: NSCache = NSCache<NSString, NSData>()
    subscript(key: String) -> NSData? {
        get { cache.object(forKey: key as NSString) }
        set(image) {
            guard let img = image else {
                self.cache.removeObject(forKey: (key as NSString))
                return
            }
            self.cache.setObject(img, forKey: (key as NSString))
        }
    }
}
