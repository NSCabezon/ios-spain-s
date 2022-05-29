//
//  URLImageView.swift
//  FinantialTimeline
//
//  Created by José Carlos Estela Anguita on 04/07/2019.
//

import UIKit
/// Represents an image vie with url attribute
class URLImageView: UIImageView {
    
    /// The url of the image
    private var url: String?
    /// Load an image into the imageview
    ///
    /// - Parameter url: the url of the image
    func setImage(fromUrl url: String, placeholder: UIImage? = nil, completion: ((UIImage?) -> Void)? = nil) {
        self.image = placeholder
        URLImageView.getImage(from: url) { (image) in
            guard let url = URL(string: url) else { return }
            self.url = url.absoluteString
            
            guard let downloadedImg = image else {
                DispatchQueue.main.async {
                    completion?(nil)
                }
                return
            }
            if self.url == url.absoluteString {
                self.image = downloadedImg
                completion?(downloadedImg)
            }
        }
    }
}

extension URLImageView {
    class func getImage(from url: String, completion: ((UIImage?) -> Void)? = nil) {
        let cache = NSCache<NSString, UIImage>()
        if let image = cache.object(forKey: url as NSString) {
            completion?(image)
        } else {
            guard let url = URL(string: url) else { return }
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: url)
                guard let image = data.flatMap(UIImage.init) else {
                    DispatchQueue.main.async {
                        completion?(nil)
                    }
                    return
                }
                DispatchQueue.main.async {
                    completion?(image)
                    cache.setObject(image, forKey: url.absoluteString as NSString)
                }
            }
        }
    }
}
