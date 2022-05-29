//
//  PreconceivedBannerView.swift
//  Account
//
//  Created by Ignacio González Miró on 21/12/21.
//

import UIKit
import UI
import CoreFoundationLib

protocol PreconceivedBannerViewDelegate: AnyObject {
    func didSelectedBanner(_ viewModel: OfferEntityViewModel)
}

final class PreconceivedBannerView: XibView {
    @IBOutlet private weak var baseView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var detailView: PreconceivedBannerDetailView!
    @IBOutlet private weak var bannerImageView: UIImageView!
    
    var viewModel: NeedMoneyViewModel?
    private weak var delegate: PreconceivedBannerViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setViewModel(_ viewModel: NeedMoneyViewModel, delegate: PreconceivedBannerViewDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate
        setDescriptionLabel(viewModel)
    }
}

private extension PreconceivedBannerView {
    func setupView() {
        backgroundColor = .skyGray
        layer.masksToBounds = false
        setBaseView()
        setTitleLabel()
        bannerImageView.image = Assets.image(named: "imgPayImentmethods")
        addTapGesture()
        setAccessibilityIds()
    }
    
    func setBaseView() {
        baseView.backgroundColor = .white
        let shadowConfiguration = ShadowConfiguration(
            color: UIColor.lisboaGray.withAlphaComponent(0.33),
            opacity: 0.7,
            radius: 3.0,
            withOffset: 1,
            heightOffset: 2
        )
        baseView.drawRoundedBorderAndShadow(
            with: shadowConfiguration,
            cornerRadius: 6.0,
            borderColor: .white,
            borderWith: 0
        )
    }
    
    func setTitleLabel() {
        let localizedConfig = LocalizedStylableTextConfiguration(
            font: .santander(family: .micro, type: .bold, size: 18),
            alignment: .left,
            lineBreakMode: .none
        )
        titleLabel.configureText(
            withKey: "financing_title_preLoan",
            andConfiguration: localizedConfig
        )
        titleLabel.numberOfLines = 1
        titleLabel.textColor = .lisboaGray
    }
    
    func setDescriptionLabel(_ viewModel: NeedMoneyViewModel) {
        guard let amount = viewModel.amountWithCurrency else {
            return
        }
        let localizedString = localized(
            "financing_text_preLoan",
            [StringPlaceholder(.value, amount)]
        )
        let localizedConfig = LocalizedStylableTextConfiguration(
            font: .santander(family: .micro, type: .regular, size: 14),
            alignment: .left,
            lineHeightMultiple: 0.85,
            lineBreakMode: .none
        )
        descriptionLabel.configureText(
            withLocalizedString: localizedString,
            andConfiguration: localizedConfig
        )
        descriptionLabel.numberOfLines = 2
        descriptionLabel.textColor = .brownishGray
    }
    
    func addTapGesture() {
        if let gestures = gestureRecognizers, !gestures.isEmpty {
            gestureRecognizers?.removeAll()
        }
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapInLocation)
        )
        baseView.addGestureRecognizer(tap)
    }
    
    @objc func didTapInLocation() {
        guard let viewModel = self.viewModel,
              let offerViewModel = viewModel.offerViewModel
        else {
            return
        }
        delegate?.didSelectedBanner(offerViewModel)
    }
    
    func setAccessibilityIds() {
        baseView.accessibilityIdentifier = AccessibilityPreconceivedBannerView.baseView
        titleLabel.accessibilityIdentifier = AccessibilityPreconceivedBannerView.titleLabel
        descriptionLabel.accessibilityIdentifier = AccessibilityPreconceivedBannerView.descriptionLabel
        bannerImageView.accessibilityIdentifier = AccessibilityPreconceivedBannerView.bannerImageView
    }
}
