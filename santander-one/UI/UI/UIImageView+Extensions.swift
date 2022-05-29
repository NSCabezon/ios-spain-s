//
//  UIImageView+Extensions.swift
//  UI
//
//  Created by Jose Carlos Estela Anguita on 14/10/2019.
//

import UIKit
import CoreFoundationLib
import Lottie

extension UIImageView {
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        guard let animationView = (subviews.first { $0 is AnimationView }) as? AnimationView else { return }
        if animationView.transform != CGAffineTransform.identity {
            animationView.bounds = CGRect(origin: .zero, size: self.bounds.size)
            animationView.transform = animationView.transform
        } else {
            animationView.frame = CGRect(origin: .zero, size: self.bounds.size)
        }
    }
    
    public func restartIfNecessary() {
        guard let animationView = (subviews.first { $0 is AnimationView }) as? AnimationView else { return }
        animationView.play()
    }
    
    public func removeLoader() {
        subviews.forEach {
            if $0 is AnimationView {
                ($0 as? AnimationView)?.stop()
                $0.removeFromSuperview()
            }
        }
    }
    
    public func setPrimaryLoader(accessibilityIdentifier: String? = nil) {
        self.setAnimationImagesWith(
            prefixName: "BS_",
            range: 1...154,
            format: "%03d",
            scale: 1.0,
            accessibilityIdentifier: accessibilityIdentifier
        )
        self.startAnimating()
    }
    
    @available(*, deprecated, message: "Use setPointsLoader instead")
    public func setSecondaryLoader(scale: CGFloat = 1.0, tintColor color: UIColor? = nil, autolayout: Bool = false, accessibilityIdentifier: String? = nil) {
        var animationView = subviews.first { $0 is AnimationView } as? AnimationView
        if animationView == nil {
            animationView = AnimationView(name: "bolas-sf05", bundle: Bundle.module!)
            animationView?.backgroundBehavior = .pauseAndRestore
            self.addSubview(animationView!)
        }
        if autolayout {
            animationView?.translatesAutoresizingMaskIntoConstraints = false
            animationView?.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            animationView?.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            animationView?.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: scale).isActive = true
            animationView?.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: scale).isActive = true
        } else {
            animationView?.frame = CGRect(origin: .zero, size: self.bounds.size)
            if scale != 1.0 {
                animationView?.transform = CGAffineTransform.identity.scaledBy(x: scale, y: scale)
            }
        }
        
        if let tintColor = tintColor {
            animationView?.tintColor = tintColor
        }
        animationView?.accessibilityIdentifier = accessibilityIdentifier
        animationView?.loopMode = .loop
        animationView?.play()
    }
    
    public func setJumpingLoader(accessibilityIdentifier: String? = nil) {
        setLottieAnimationLoader(fileName: "saltos-sf05", accessibilityIdentifier: accessibilityIdentifier)
    }
    
    public func setNewJumpingLoader(accessibilityIdentifier: String? = nil) {
        setLottieAnimationLoader(fileName: "jumping", accessibilityIdentifier: accessibilityIdentifier)
    }

    public func setWhiteJumpingLoader(accessibilityIdentifier: String? = nil) {
        setLottieAnimationLoader(fileName: "jumping-white-sf12", accessibilityIdentifier: accessibilityIdentifier)
    }

    public func setRedJumpingLoader(accessibilityIdentifier: String? = nil) {
        setLottieAnimationLoader(fileName: "jumping-red-sf13", accessibilityIdentifier: accessibilityIdentifier)
    }
    
    public func setPointsLoader(accessibilityIdentifier: String? = nil) {
        setLottieAnimationLoader(fileName: "bolas-sf05", accessibilityIdentifier: accessibilityIdentifier)
    }

    public func setLeavesLoader(accessibilityIdentifier: String? = nil) {
        setLottieAnimationLoader(fileName: "leaves-sf09", accessibilityIdentifier: accessibilityIdentifier)
    }

    public func setRocketAnimation() {
        var animationView = subviews.first { $0 is AnimationView } as? AnimationView
        if animationView == nil {
            animationView = AnimationView(name: "Anim_cohete-sf05", bundle: Bundle.module ?? Bundle.main)
            animationView?.backgroundBehavior = .pauseAndRestore
            self.addSubview(animationView ?? UIView())
            animationView?.fullFit()
        }
        animationView?.loopMode = .playOnce
        animationView?.play()
    }

    public func setSmileysAnimation() {
        var animationView = subviews.first { $0 is AnimationView } as? AnimationView
        if animationView == nil {
            animationView = AnimationView(name: "Smileys", bundle: Bundle.module ?? Bundle.main)
            animationView?.backgroundBehavior = .pauseAndRestore
            self.addSubview(animationView ?? UIView())
            animationView?.fullFit()
        }
        animationView?.loopMode = .loop
        animationView?.play()
    }

    private func setLottieAnimationLoader(fileName: String, accessibilityIdentifier: String? = nil) {
        var animationView = subviews.first { $0 is AnimationView } as? AnimationView
        if animationView == nil {
            animationView = AnimationView(name: fileName, bundle: Bundle.module ?? Bundle())
            animationView?.backgroundBehavior = .pauseAndRestore
            self.addSubview(animationView ?? UIView())
            animationView?.fullFit()
        }
        animationView?.accessibilityIdentifier = accessibilityIdentifier
        animationView?.loopMode = .loop
        animationView?.play()
    }
    
    public func setAnimationImagesWith(prefixName: String,
                                       range: CountableClosedRange<Int>,
                                       format: String = "%d",
                                       tintColor: UIColor? = nil,
                                       scale: CGFloat = 1.0,
                                       accessibilityIdentifier: String? = nil) {
        let images: [UIImage] = range.compactMap {
            guard let image = Assets.image(named: prefixName + String(format: format, $0)) else { return nil }
            guard let tintedColor = tintColor else { return image.resize(factor: scale) }
            return image.tinted(WithColor: tintedColor, scale: scale)
        }
        self.animationImages = images
        self.accessibilityIdentifier = accessibilityIdentifier
    }

    public func isRightAspectRatio() -> Bool {
        guard let image = self.image else { return false }
        let imageAspectRatio = image.size.height / image.size.width
        let imageViewAspectRatio = self.frame.size.height / self.frame.size.width
        return abs(imageAspectRatio.distance(to: imageViewAspectRatio)) == 0
    }
    
    @discardableResult
    public func loadImage(urlString: String, placeholder: UIImage? = nil, completion:(() -> Void)? = nil) -> CancelableTask? {
        let task = self.setImage(url: urlString, placeholder: placeholder, completion: { [weak self] image in
            guard let image = image else {
                DispatchQueue.main.async { completion?() }
                return
            }
            DispatchQueue.main.async { self?.image = image; completion?() }
        })
        return  task
    }
    
    public func loadGifImage(urlString: String, placeholder: UIImage? = nil, completion:(() -> Void)? = nil) -> CancelableTask? {
        let task = self.setImage(url: urlString, placeholder: placeholder, completion: { [weak self] image in
            guard let image = image else {
                DispatchQueue.main.async { completion?() }
                return
            }
            DispatchQueue.main.async { self?.image = image; completion?() }
        })
        return task
    }
    
    public func changeImageTintColor(tintedWith color: UIColor) {
        self.image = self.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        self.tintColor = color
    }
}
  
