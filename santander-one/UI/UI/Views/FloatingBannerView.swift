//
//  FloatingBannerView.swift
//  UI
//
//  Created by Juan Carlos López Robles on 4/24/20.
//

import Foundation

public protocol FloatingBannerCloseDelegate: AnyObject {
    func didCloseFloatingBanner()
}

public final class FloatingBannerView: XibView {
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var bannerButton: UIButton!
    @IBOutlet weak var closeImageView: UIImageView!
    @IBOutlet weak var closeButton: UIButton!
    private let animationDuration = TimeInterval(0.5)
    @IBOutlet private weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var widthConstraint: NSLayoutConstraint!
    private var closeTimeInterval = TimeInterval(4)
    private var action: (() -> Void)?
    private var timer: Timer?
    public weak var delegate: FloatingBannerCloseDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAccessibilityIdentifiers()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAccessibilityIdentifiers()
    }
    
    @IBAction func didSelectBannerAction(_ sender: Any) {
        self.action?()
        self.closeWithAnimation()
    }
    
    @IBAction func didSelectClose(_ sender: Any) {
        self.closeWithAnimation()
    }
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.addConstraints()
    }
    
    public func addAction(_ action : (() -> Void)?) {
        self.action = action
    }
    
    public func setAutomaticallyCloseInterval(_ value: Int) {
        self.closeTimeInterval = TimeInterval(value)
    }
    
    public func setTransparentClosure(_ transparentClosure: Bool) {
        closeImageView.image = !transparentClosure ? Assets.image(named: "icnXOffer") : nil
    }
    
    public func setImageUrl(_ url: String) {
        self.bannerImageView.loadImage(urlString: url, placeholder: nil) {
            guard let image = self.bannerImageView.image else {
                self.isHidden = true
                return
            }
            self.closeImageView.isHidden = false
            let ratioWidth = image.size.width / UIScreen.main.scale
            let ratioHeight = image.size.height / UIScreen.main.scale
            self.heightConstraint.constant = ratioHeight
            self.widthConstraint.constant = ratioWidth
            let ratio = (ratioHeight / ratioWidth)
            self.bannerImageView.heightAnchor.constraint(equalTo: self.bannerImageView.widthAnchor, multiplier: CGFloat(ratio)).isActive = true
        }
    }
    
    public func startAnimation() {
        guard let parentView = self.superview else { return }
        self.scheduleAutomaticallyClose()
        UIView.animate(
            withDuration: animationDuration,
            delay: 0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 1.0,
            options: .curveEaseInOut,
            animations: { [weak self] in
                self?.frame.origin = CGPoint(x: 0, y: -parentView.frame.height)
            }, completion: nil)
    }
    
    @objc
    func closeWithAnimation() {
        guard let parentView = self.superview else { return }
        UIView.animate(
            withDuration: animationDuration,
            delay: 0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 1.0,
            options: .curveEaseInOut,
            animations: { [weak self] in
                self?.frame.origin = CGPoint(x: 0, y: parentView.frame.height)
            }, completion: { [weak self] completed in
                guard let self = self, completed else { return }
                self.removeFromSuperview()
                self.delegate?.didCloseFloatingBanner()
        })
    }
}

private extension FloatingBannerView {
    private func addConstraints() {
        guard let parentView = self.superview else { return }
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.rightAnchor.constraint(lessThanOrEqualTo: parentView.rightAnchor, constant: 0),
            self.leftAnchor.constraint(greaterThanOrEqualTo: parentView.leftAnchor, constant: 0),
            self.topAnchor.constraint(greaterThanOrEqualTo: parentView.topAnchor, constant: 0),
            self.centerXAnchor.constraint(equalTo: parentView.centerXAnchor),
            self.bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: -26)
        ])
    }
    
    private func scheduleAutomaticallyClose() {
         self.timer = Timer.scheduledTimer(
             timeInterval: closeTimeInterval, target: self, selector: #selector(closeWithAnimation), userInfo: nil, repeats: false)
    }
    
    func setAccessibilityIdentifiers() {
        self.bannerImageView.accessibilityIdentifier = "bannerImageView"
        self.bannerButton.accessibilityIdentifier = "bannerButton"
        self.closeImageView.accessibilityIdentifier = "closeBannerImageView"
        self.closeButton.accessibilityIdentifier = "closeBannerButton"
    }
}
