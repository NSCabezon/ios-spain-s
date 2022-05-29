import UIKit

final class ImageBannerViewModel {
    
    private let url: String
    private var insertedHeight: CGFloat?
    private let bannerOffer: Offer?
    private let insets: UIEdgeInsets?
    private let isRounded: Bool
    private let isClosable: Bool
    private let dependencies: PresentationComponent
    private weak var actionDelegate: LocationBannerDelegate?
    
    init(url: String, bannerOffer: Offer? = nil, leftInset: CGFloat? = nil, rightInset: CGFloat? = nil, topInset: CGFloat? = nil, bottomInset: CGFloat? = nil, isClosable: Bool, isRounded: Bool, actionDelegate: LocationBannerDelegate?, dependencies: PresentationComponent) {
        self.url = url
        self.bannerOffer = bannerOffer
        self.actionDelegate = actionDelegate
        self.insets = UIEdgeInsets(top: topInset ?? 0, left: leftInset ?? 0, bottom: bottomInset ?? 0, right: rightInset ?? 0)
        self.isRounded = isRounded
        self.isClosable = isClosable
        self.dependencies = dependencies
    }
    
    func configureView(in locationView: UIView, completion: (() -> Void)? = nil) {
        guard let itemView = UINib(nibName: "ImageViewCell", bundle: .module).instantiate(withOwner: nil, options: nil).first as? ImageViewCell else {
            return
        }
        itemView.modelView = self
        itemView.isRounded = isRounded
        itemView.insets = insets
        itemView.isClosable = isClosable
        locationView.addSubview(itemView)
        itemView.translatesAutoresizingMaskIntoConstraints = false
        
        let leftCons = NSLayoutConstraint(item: locationView, attribute: .left, relatedBy: .equal, toItem: itemView, attribute: .left, multiplier: 1, constant: 0)
        leftCons.priority = .required
        leftCons.isActive = true
        locationView.addConstraint(leftCons)
        
        let topCons = NSLayoutConstraint(item: locationView, attribute: .top, relatedBy: .equal, toItem: itemView, attribute: .top, multiplier: 1, constant: 0)
        topCons.priority = .required
        topCons.isActive = true
        locationView.addConstraint(topCons)
        
        let rightCons = NSLayoutConstraint(item: locationView, attribute: .right, relatedBy: .equal, toItem: itemView, attribute: .right, multiplier: 1, constant: 0)
        rightCons.priority = .required
        rightCons.isActive = true
        locationView.addConstraint(rightCons)
        
        let bottomCons = NSLayoutConstraint(item: locationView, attribute: .bottom, relatedBy: .equal, toItem: itemView, attribute: .bottom, multiplier: 1, constant: 0)
        bottomCons.priority = .required
        bottomCons.isActive = true
        locationView.addConstraint(bottomCons)
        
        itemView.setNeedsLayout()
        itemView.layoutIfNeeded()
        itemView.layoutSubviews()
        locationView.layoutSubviews()
        self.dependencies.imageLoader.load(absoluteUrl: url, imageView: itemView.imageURLView, placeholderIfDoesntExist: nil, completion: {
            itemView.onImageLoadFinished()
            guard let completion = completion else { return }
            completion()
        })
    }
    
    public func onDrawFinished(newHeight: CGFloat) {
        insertedHeight = newHeight
        actionDelegate?.finishDownloadImage(newHeight: Float(newHeight))
    }
    
    func selectedBanner() {
        actionDelegate?.selectedBanner()
    }
    
    func didCloseButton() {
        actionDelegate?.closeBanner(bannerOffer: self.bannerOffer)
    }
}
