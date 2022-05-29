//
// Created by SYS_CIBER_ADMIN on 1/3/18.
// Copyright (c) 2018 Ciber. All rights reserved.
//

import UIKit
import CoreFoundationLib
import UI

class ImageManager: ImageLoader {

    private let appRepository: AppRepository
    private var publicEnvironmentDTO: PublicFilesEnvironmentDTO?

    init(appRepository: AppRepository) {
        self.appRepository = appRepository
    }

    func load(relativeUrl: String, imageView: UIImageView, placeholderIfDoesntExist: String?) {
        let absoluteUrl = buildAbsoluteUrl(relativeUrl: relativeUrl)
        load(absoluteUrl: absoluteUrl, imageView: imageView, placeholderIfDoesntExist: placeholderIfDoesntExist)
    }

    func load(absoluteUrl: String, imageView: UIImageView, placeholderIfDoesntExist: String?) {
        let url = URL(string: absoluteUrl)
        imageView.setImage(url: absoluteUrl, completion:  { img in
            if img == nil, let placeholderImage = placeholderIfDoesntExist, !placeholderImage.isEmpty {
                imageView.image = Assets.image(named: placeholderImage)
            }
        })
    }
    
    func load(absoluteUrl: String, button: UIButton) {
        let url = URL(string: absoluteUrl)
        button.setImage(url: absoluteUrl, for: .normal)
    }

    func load(relativeUrl: String, button: UIButton, placeholder: String) {
        let url = buildAbsoluteUrl(relativeUrl: relativeUrl)
        load(absoluteUrl: url, button: button, placeholder: placeholder)
    }
    
    func load(absoluteUrl: String, button: UIButton, placeholder: String) {
        let url = URL(string: absoluteUrl)
        button.setImage(url: absoluteUrl, placeholder: Assets.image(named: placeholder), for: .normal)
    }
    
    func loadTask(absoluteUrl: String, imageView: UIImageView, placeholderIfDoesntExist: String?, completion: (() -> Void)?) -> CancelableTask? {
        let url = URL(string: absoluteUrl)
        let task = imageView.setImage(url: absoluteUrl, placeholder: nil, options: [], completion: {img in
            if img == nil, let placeholderImage = placeholderIfDoesntExist, !placeholderImage.isEmpty {
                imageView.image = Assets.image(named: placeholderImage)
            }
            if let completion = completion {
                completion()
            }
        })
        return task
    }
    
    func load(absoluteUrl: String, imageView: UIImageView, placeholderIfDoesntExist: String?, completion: (() -> Void)? = nil) {
        let url = URL(string: absoluteUrl)
        imageView.setImage(url: absoluteUrl, placeholder: nil, options:[], completion: { img in
            if img == nil, let placeholderImage = placeholderIfDoesntExist, !placeholderImage.isEmpty {
                imageView.image = Assets.image(named: placeholderImage)
            }
            if let completion = completion {
                completion()
            }
        })
    }
    
    @discardableResult
    func loadWithAspectRatio(absoluteUrl: String, imageView: UIImageView, placeholderIfDoesntExist: String?, completion: ((Float) -> Void)? = nil) -> CancelableTask? {
        let url = URL(string: absoluteUrl)
        let task = imageView.setImage(url: absoluteUrl, placeholder: nil, options: [], completion: { img in
            if img == nil, let placeholderImage = placeholderIfDoesntExist, !placeholderImage.isEmpty {
                imageView.image = Assets.image(named: placeholderImage)
            }
            guard let img = imageView.image else { return }
            let imageHeight = img.size.height
            let imageWidth = img.size.width
            let imageViewWidth = imageView.frame.width
            let originalHeight = Float(imageHeight)
            let originalWidth = Float(imageWidth)
            let newHeight = (originalHeight / originalWidth) * Float(imageViewWidth)
            if let completion = completion {
                completion(newHeight)
            }
        })
        return task
    }
    
    @discardableResult
    func loadWithAspectRatioGIF(absoluteUrl: String, imageView: UIImageView, placeholderIfDoesntExist: String?, completion: ((Float) -> Void)? = nil) -> CancelableTask? {
        let url = URL(string: absoluteUrl)
        let task = imageView.setImage(url: absoluteUrl, placeholder: nil, options: [], completion: { img in
            if img == nil, let placeholderImage = placeholderIfDoesntExist, !placeholderImage.isEmpty {
                imageView.image = Assets.image(named: placeholderImage)
            }
            guard let img = imageView.image else { return }
            let imageHeight = img.size.height
            let imageWidth = img.size.width
            let imageViewWidth = imageView.frame.width
            let originalHeight = Float(imageHeight)
            let originalWidth = Float(imageWidth)
            let newHeight = (originalHeight / originalWidth) * Float(imageViewWidth)
            if let completion = completion {
                completion(newHeight)
            }
        })
        return task
    }
    
    func loadWithAspectRatio(relativeUrl: String, imageView: UIImageView, placeholderIfDoesntExist: String?, completion: ((Float) -> Void)? = nil) {
        let absoluteUrl = buildAbsoluteUrl(relativeUrl: relativeUrl)
        self.loadWithAspectRatio(absoluteUrl: absoluteUrl, imageView: imageView, placeholderIfDoesntExist: placeholderIfDoesntExist, completion: completion)
    }
    
    func loadWithAspectRatio(absoluteUrl: String, button: UIButton, completion: ((Float) -> Void)? = nil) {
        let url = URL(string: absoluteUrl)
        _ = button.setImage(url: absoluteUrl, for: .normal, completion: { img in
            //load with aspect ratio
            guard let imageHeight = img?.size.height,
                let imageWidth = img?.size.width else { return }
            
            let imageViewWidth = button.frame.width
            let originalHeight = Float(imageHeight)
            let originalWidth = Float(imageWidth)
            
            let newHeight = (originalHeight / originalWidth) * Float(imageViewWidth)
            
            if let completion = completion {
                completion(newHeight)
            }
        })
    }

    func load(relativeUrl: String, imageView: UIImageView, placeholder: String) {
        let absoluteUrl = buildAbsoluteUrl(relativeUrl: relativeUrl)
        load(absoluteUrl: absoluteUrl, imageView: imageView, placeholder: placeholder)
    }

    func load(absoluteUrl: String, imageView: UIImageView, placeholder: String) {
        let url = URL(string: absoluteUrl)
        imageView.setImage(url: absoluteUrl, placeholder: Assets.image(named: placeholder))
    }
    
    func buildImageAbsoluteURL(relativeUrl: String) -> URL? {
        return URL(string: buildAbsoluteUrl(relativeUrl: relativeUrl))
    }

    private func buildAbsoluteUrl(relativeUrl: String) -> String {
        if let urlBase = getPublicUrl()?.urlBase {
            return urlBase + relativeUrl
        }
        return relativeUrl
    }

    private func getPublicUrl() -> PublicFilesEnvironmentDTO? {
        do {
            return try appRepository.getCurrentPublicFilesEnvironment().getResponseData()
        } catch {
            return nil
        }
    }
}
