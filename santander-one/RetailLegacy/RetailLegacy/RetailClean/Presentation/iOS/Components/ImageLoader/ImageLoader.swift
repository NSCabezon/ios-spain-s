//
// Created by SYS_CIBER_ADMIN on 1/3/18.
// Copyright (c) 2018 Ciber. All rights reserved.
//

import UIKit
import UI
import CoreFoundationLib

protocol ImageLoader {
    func load(relativeUrl: String, imageView: UIImageView, placeholderIfDoesntExist: String?)
    func load(relativeUrl: String, button: UIButton, placeholder: String)
    func load(absoluteUrl: String, button: UIButton)
    func load(absoluteUrl: String, button: UIButton, placeholder: String)
    func load(absoluteUrl: String, imageView: UIImageView, placeholderIfDoesntExist: String?)
    func load(relativeUrl: String, imageView: UIImageView, placeholder: String)
    func load(absoluteUrl: String, imageView: UIImageView, placeholder: String)
    func load(absoluteUrl: String, imageView: UIImageView, placeholderIfDoesntExist: String?, completion: (() -> Void)?)
    func loadWithAspectRatio(relativeUrl: String, imageView: UIImageView, placeholderIfDoesntExist: String?, completion: ((Float) -> Void)?)
    @discardableResult
    func loadWithAspectRatio(absoluteUrl: String, imageView: UIImageView, placeholderIfDoesntExist: String?, completion: ((Float) -> Void)?) -> CancelableTask?
    @discardableResult
    func loadWithAspectRatioGIF(absoluteUrl: String, imageView: UIImageView, placeholderIfDoesntExist: String?, completion: ((Float) -> Void)?) -> CancelableTask?
    func loadWithAspectRatio(absoluteUrl: String, button: UIButton, completion: ((Float) -> Void)?)
    @discardableResult
    func loadTask(absoluteUrl: String, imageView: UIImageView, placeholderIfDoesntExist: String?, completion: (() -> Void)?) -> CancelableTask?
    func buildImageAbsoluteURL(relativeUrl: String) -> URL?
}
