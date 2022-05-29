//
//  NeedMoneyView.swift
//  Menu
//
//  Created by Cristobal Ramos Laina on 25/06/2020.
//

import Foundation
import UI
import CoreFoundationLib

protocol NeedMoneyViewDelegate: AnyObject {
    func didSelectedBanner(_ viewModel: OfferEntityViewModel)
}

final class NeedMoneyView: XibView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var offerImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var pregrantedView: UIView!
    @IBOutlet weak var offerView: UIView!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var offerButton: UIButton!
    var viewModel: NeedMoneyViewModel?
    weak var delegate: NeedMoneyViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setViewModel(_ viewModel: NeedMoneyViewModel) {
        self.viewModel = viewModel
        self.offerView.isHidden = viewModel.isOfferViewHidden
        if viewModel.isOfferViewHidden == false {
            self.pregrantedView.isHidden = viewModel.isAmountViewHidden
        } else {
            self.isHidden = true
        }
        guard !self.isHidden else { return }
        self.setImageWithUrl(viewModel.imageURL, on: self.offerImageView)
        guard let amount = viewModel.amount else { return }
        self.amountLabel.configureText(withLocalizedString: localized("financing_title_untilAmount", [StringPlaceholder(.value, amount)]))
    }
    
    @IBAction func didSelectedBanner(_ sender: Any) {
        guard let viewModel = self.viewModel,
            let offerViewModel = viewModel.offerViewModel else { return }
        self.delegate?.didSelectedBanner(offerViewModel)
    }
}

private extension NeedMoneyView {
    func setupView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.subtitleLabel?.text = localized("financing_title_preLoan")
        self.titleLabel?.textColor = .lisboaGray
        self.titleLabel?.configureText(withKey: "financing_title_needMoneyTo",
                                       andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 18)))
        self.subtitleLabel?.font = .santander(family: .text, type: .bold, size: 14)
        self.subtitleLabel?.textColor = .mediumSanGray
        self.amountLabel?.font = .santander(family: .text, type: .bold, size: 14)
        self.amountLabel?.textColor = .lisboaGray
        self.separatorView.backgroundColor = UIColor.mediumSkyGray
        self.pregrantedView.isHidden = true
        self.offerView.isHidden = true
        self.setAccessibilityIdentifiers()
    }
    
    func setAccessibilityIdentifiers() {
        self.titleLabel.accessibilityIdentifier = AccessibilityFinancingNeedMoney.title
        self.subtitleLabel.accessibilityIdentifier = AccessibilityFinancingNeedMoney.subtitle
        self.amountLabel.accessibilityIdentifier = AccessibilityFinancingNeedMoney.amount
        self.offerImageView.accessibilityIdentifier = AccessibilityFinancingNeedMoney.offerImageView
        self.offerButton.accessibilityIdentifier = AccessibilityFinancingFractionalPurchases.needMoneyLocation
    }
    
    func setImageWithUrl(_ url: String?, on imageView: UIImageView) {
        guard let urlUnwrapped = url else {return}
        imageView.loadImage(urlString: urlUnwrapped) {
            guard let image = imageView.image else {return}
            let ratioWidth = Double(image.size.width)
            let ratioHeight = Double(image.size.height)
            let ratio = ratioHeight / ratioWidth
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: CGFloat(ratio)).isActive = true
        }
    }
}
