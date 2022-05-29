//
//  RemoteImage.swift
//  UI
//
//  Created by Jorge Ouahbi Martín
//

import CoreFoundationLib
import Foundation
import SwiftyGif

// MARK: - RemoteImageProtocol -

public protocol RemoteImageProtocol {
    func setImage(url: String?, placeholder: UIImage?, completion: ImageLoaderProtocol.RemoteImageCompletion?) -> CancelableTask?
}

// MARK: - UIViews Support RemoteImageProtocol -

extension UIImageView: RemoteImageProtocol {}
extension UIButton: RemoteImageProtocol {}

// MARK: - Module Configuration

enum RemoteImageConstants {
    // UIView animation duration
    static var animationDuration: TimeInterval = 0
}

// MARK: - Private UIView extension -

private extension UIView {
    func imageWithTransition(to image: UIImage,
                             options: UIView.AnimationOptions = [],
                             duration: TimeInterval = RemoteImageConstants.animationDuration,
                             completion: (ImageLoaderProtocol.RemoteImageCompletion)? = nil) {
        if duration == 0 {
            completion?(image)
            return
        }
        DispatchQueue.main.async {
            UIView.transition(with: self,
                              duration: duration,
                              options: options,
                              animations: {
                                  completion?(image)
                              },
                              completion: nil)
        }
    }
}

// MARK: - RemoteImageProtocol for UIImageView

public extension RemoteImageProtocol where Self: UIImageView {
    ///
    /// Donwload the UIImage asynchronously and add it to the UIImageView.
    ///
    /// - Parameters:
    ///   - url: absolute url string
    ///   - placeholder: image placeholder
    ///   - options: UIView.AnimationOption
    ///   - completion: RemoteImageCompletion
    ///
    /// - Returns: A optional CancelableTask
    func setImage(url: String?,
                  placeholder: UIImage? = nil,
                  options: UIView.AnimationOptions = [],
                  completion: ImageLoaderProtocol.RemoteImageCompletion? = nil) -> CancelableTask? {
        assert(url != nil)
        guard let url = url else { completion?(nil); return nil }
        let strategy: DownloadImageStrategy
        if url.suffix(4) == ".gif" {
            strategy = DownloadGifImageStrategy(imageView: self)
        } else {
            strategy = DownloadDefaultImageStrategy(imageView: self)
        }
        return strategy.loadImage(urlString: url, placeholder: placeholder, options: options) { image in
            completion?(image)
        }
    }

    ///
    /// Donwload the UIImage asynchronously and add it to the UIImageView.
    ///
    /// - Parameters:
    ///   - url: absolute url string
    ///   - placeholder: image placeholder
    ///   - completion: RemoteImageCompletion
    ///
    /// - Returns: CancelableTask

    func setImage(url: String?,
                  placeholder: UIImage? = nil,
                  completion: ImageLoaderProtocol.RemoteImageCompletion? = nil) -> CancelableTask? {
        return setImage(url: url,
                        placeholder: placeholder,
                        options: [],
                        completion: completion)
    }
}

// MARK: - RemoteImageProtocol for UIButton

public extension RemoteImageProtocol where Self: UIButton {
    ///
    /// Donwload the UIImage asynchronously  and add the downloaded UIImage to the UIImageView of the UIButton,
    /// in case the value `false' in isBackground is passed to the function the function setImage(xxx, for: [.normal])
    /// will be used otherwise the function setBackgroundImage(xxx, for: [.normal]) will be used.
    ///
    /// - Parameters:
    ///   - url: absolute url string
    ///   - placeholder: image placeholder
    ///   - options: UIView.AnimationOption
    ///   - state: UIControl.State
    ///   - isBackground: Set the UIButton background/foreground image.
    ///   - completion: RemoteImageCompletion
    ///
    /// - Returns: A optional CancelableTask
    func setImage(url: String?,
                  placeholder: UIImage? = nil,
                  options: UIView.AnimationOptions = [],
                  for state: UIControl.State = .normal,
                  isBackground: Bool = true,
                  completion: ImageLoaderProtocol.RemoteImageCompletion? = nil) -> CancelableTask? {
        assert(url != nil)
        guard let url = url, let imageView = self.imageView else {
            completion?(nil)
            return nil
        }
        let strategy = DownloadDefaultImageStrategy(imageView: imageView)
        return strategy.loadImage(urlString: url, placeholder: placeholder, options: []) { image in
            guard let image = image else {
                DispatchQueue.main.async {
                    completion?(nil)
                    UIView.performWithoutAnimation {
                        if isBackground {
                            self.setBackgroundImage(placeholder, for: state)
                        } else {
                            self.setImage(placeholder, for: state)
                        }
                    }
                }
                return
            }
            DispatchQueue.main.async {
                self.imageWithTransition(to: image, options: options) { image in
                    if isBackground {
                        self.setBackgroundImage(image, for: state)
                    } else {
                        self.setImage(image, for: state)
                    }
                    completion?(image)
                }
            }
        }
    }

    ///
    /// Donwload the UIImage asynchronously  and add the downloaded UIImage to the UIImageView of the UIButton,
    ///
    /// - Parameters:
    ///   - url: absolute url string
    ///   - placeholder: image placeholder
    ///   - completion: RemoteImageCompletion
    ///
    /// - Returns: CancelableTask
    func setImage(url: String?, placeholder: UIImage?, completion: ImageLoaderProtocol.RemoteImageCompletion?) -> CancelableTask? {
        return setImage(url: url,
                        placeholder: placeholder,
                        options: [],
                        for: .normal,
                        isBackground: true,
                        completion: completion)
    }
}

private protocol DownloadImageStrategy {
    func loadImage(urlString: String, placeholder: UIImage?, options: UIView.AnimationOptions, completion: @escaping ImageLoaderProtocol.RemoteImageCompletion) -> CancelableTask?
}

private struct DownloadDefaultImageStrategy: DownloadImageStrategy {
    
    let imageView: UIImageView
    
    func loadImage(urlString: String, placeholder: UIImage?, options: UIView.AnimationOptions, completion: @escaping ImageLoaderProtocol.RemoteImageCompletion) -> CancelableTask? {
        guard let url = URL(string: urlString) else { return nil }
        if RemoteImageDownloader.shared.peekCache(fromUrl: url) == nil {
            self.imageView.image = placeholder
        }
        return RemoteImageDownloader.shared.loadImage(url: url) { image in
            guard let currentImage = image else {
                DispatchQueue.main.async {
                    completion(nil)
                    UIView.performWithoutAnimation {
                        self.imageView.image = placeholder
                    }
                }
                return
            }
            DispatchQueue.main.async {
                self.imageView.imageWithTransition(to: currentImage, options: options) { image in
                    self.imageView.image = image
                    completion(image)
                }
            }
        }
    }
}

private struct DownloadGifImageStrategy: DownloadImageStrategy {
    
    let imageView: UIImageView
    
    func loadImage(urlString: String, placeholder: UIImage?, options: UIView.AnimationOptions, completion: @escaping ImageLoaderProtocol.RemoteImageCompletion) -> CancelableTask? {
        guard let url = URL(string: urlString) else { return nil }
        if RemoteImageDownloader.shared.peekCache(fromUrl: url) == nil {
            self.imageView.image = placeholder
        }
        return RemoteImageDownloader.shared.loadImageGif(url: url) { image in
            guard let downloadedImage = image else { return self.imageView.image = placeholder }
            self.imageView.setGifImage(downloadedImage)
        }
    }
}
