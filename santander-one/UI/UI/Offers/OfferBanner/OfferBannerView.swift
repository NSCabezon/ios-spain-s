//
//  OfferBannerView.swift
//  UI
//
//  Created by Laura González on 04/09/2020.
//

import CoreFoundationLib

public enum OfferBannerViewType {
    case regular
    case preconceived
}

public protocol OfferBannerViewProtocol: AnyObject {
    func didSelectBanner(_ viewModel: OfferBannerViewModel?)
    func didSelectPreconceivedBanner(_ viewModel: OfferBannerViewModel?)
}

public extension OfferBannerViewProtocol {
    func didSelectPreconceivedBanner(_ viewModel: OfferBannerViewModel?) {}
}

public class OfferBannerView: UIDesignableView {
    @IBOutlet public weak var imageView: UIImageView!
    @IBOutlet private weak var offerButton: UIButton!
    
    public weak var delegate: OfferBannerViewProtocol?
    public var viewModel: OfferBannerViewModel?
    public var type: OfferBannerViewType = .regular

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.offerButton.backgroundColor = .clear
        self.imageView.backgroundColor = .clear
        self.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setImageSource(_ url: String?) {
        guard let urlUnwrapped = url else {
            self.imageView.image = nil
            return }
        self.imageView.loadImage(urlString: urlUnwrapped)
    }
    
    public func setOfferBannerForLocation(viewModel: OfferBannerViewModel, updateConstraint: NSLayoutConstraint) {
        self.setOfferBannerWithUrl(viewModel.url, updateConstraint: updateConstraint)
        self.viewModel = viewModel
        self.isHidden = false
        self.backgroundColor = .clear
    }
    
    public func updateIdentifier(with identifier: String) {
        self.offerButton.accessibilityIdentifier = identifier
    }
    
    @IBAction func didSelectedBanner(_ sender: UIButton) {
        switch type {
        case .preconceived:
            self.delegate?.didSelectPreconceivedBanner(viewModel)
        default:
            self.delegate?.didSelectBanner(viewModel)
        }
    }
}

private extension OfferBannerView {
    func setOfferBannerWithUrl(_ url: String?, updateConstraint: NSLayoutConstraint) {
        guard let urlUnwrapped = url else {
            self.imageView.image = nil
            return }
        self.imageView.loadImage(urlString: urlUnwrapped) { [weak self] in
            guard let image = self?.imageView.image else { return }
            self?.updateBannerHeight(image, updateConstraint: updateConstraint)
        }
    }
    
    func updateBannerHeight(_ image: UIImage, updateConstraint: NSLayoutConstraint) {
        let aspectRatio = image.size.height / image.size.width
        let imageWidth = self.imageView.frame.width 
        let height = imageWidth * aspectRatio
        UIView.performWithoutAnimation {
            if height > 0 {
                let margins: CGFloat = 25
                updateConstraint.constant = height + margins
                self.setNeedsLayout()
                self.layoutIfNeeded()
            }
        }
    }
}
