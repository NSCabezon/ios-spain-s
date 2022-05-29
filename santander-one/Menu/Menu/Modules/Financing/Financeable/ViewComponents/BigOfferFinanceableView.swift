//
//  BifOfferFinanceable.swift
//  Menu
//
//  Created by Cristobal Ramos Laina on 01/07/2020.
//

import Foundation
import UI
import CoreFoundationLib

public enum BigOfferBannerViewType {
    case regular
    case preconceived
}

public protocol BigOfferFinanceableViewDelegate: class {
    func didSelectBigBanner(_ viewModel: OfferEntityViewModel)
    func didSelectPreconceivedBigBanner(_ viewModel: OfferEntityViewModel)
}

public extension BigOfferFinanceableViewDelegate {
    func didSelectPreconceivedBigBanner(_ viewModel: OfferEntityViewModel) { }
}

final class BigOfferFinanceableView: XibView {
  
    @IBOutlet weak var offerImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var bigofferButton: UIButton!
    var viewModel: BigOfferViewModel?
    private weak var delegate: BigOfferFinanceableViewDelegate?
    public var type: BigOfferBannerViewType = .regular
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setViewModel(_ viewModel: BigOfferViewModel, delegate: BigOfferFinanceableViewDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate
        self.setImageWithUrl(viewModel.imageURL, on: self.offerImageView)
    }
    
    func setFinancingHomeLocationAccessibilityIdentifiers() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.bigofferButton.accessibilityIdentifier = AccessibilityFinancingFractionalPurchases.homeLocation
    }
    
    func setSecondBigOfferAccessibilityIdentifiers() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.bigofferButton.accessibilityIdentifier = AccessibilityFinancingFractionalPurchases.secondBigOfferLocation
    }
    
    func setRobinsonOfferAccessibilityIdentifiers() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.bigofferButton.accessibilityIdentifier = AccessibilityFinancingFractionalPurchases.robinsonOffer
    }
    
    @IBAction func didSelectedBanner(_ sender: Any) {
        guard let viewModel = self.viewModel,
        let offerViewModel = viewModel.offerViewModel else { return }
        switch type {
        case .preconceived:
            self.delegate?.didSelectPreconceivedBigBanner(offerViewModel)
        default:
            self.delegate?.didSelectBigBanner(offerViewModel)
        }
    }
}

private extension BigOfferFinanceableView {
    func setImageWithUrl(_ url: String?, on imageView: UIImageView) {
        guard let urlUnwrapped = url else { return }
        imageView.loadImage(urlString: urlUnwrapped) {
            guard let image = imageView.image else {return}
            let ratioWidth = Double(image.size.width)
            let ratioHeight = Double(image.size.height)
            let ratio = ratioHeight / ratioWidth
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: CGFloat(ratio)).isActive = true
        }
    }
}
