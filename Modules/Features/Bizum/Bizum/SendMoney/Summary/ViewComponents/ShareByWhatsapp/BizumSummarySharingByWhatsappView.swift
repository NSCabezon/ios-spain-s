//
//  BizumSummarySharingByWhatsappView.swift
//  Bizum
//
//  Created by Ignacio González Miró on 9/12/20.
//

import UIKit
import UI
import Operative
import CoreFoundationLib
import ESUI

protocol DidTapInSharingByWhatsappDelegate: class {
    func didTapInShareByWhatsapp()
}

final class BizumSummarySharingByWhatsappView: UIDesignableView {
    @IBOutlet private weak var headerTitleLabel: UILabel!
    @IBOutlet private weak var headerDescriptionLabel: UILabel!
    @IBOutlet private weak var whatsappImage: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var stackView: UIStackView!
    
    weak var delegate: DidTapInSharingByWhatsappDelegate?
    
    override func getBundleName() -> String {
        return "Bizum"
    }

    override func commonInit() {
        super.commonInit()
        self.setupView()
    }
    
    func configure(_ viewModel: ShareBizumSummaryViewModel) {
        self.headerTitleLabel.text = localized("summary_label_shareShipment")
        self.headerDescriptionLabel.set(localizedStylableText: localized("summary_label_shareImgGenerated"))
        self.titleLabel.text = localized("generic_label_shareWith")
        self.loadShareByWhatsappPill(viewModel)
    }
}

private extension BizumSummarySharingByWhatsappView {
    func setupView() {
        self.backgroundColor = .clear
        self.whatsappImage.image = ESAssets.image(named: "icnWhatsapp")
        self.setLabels()
        self.setAccessibilityIds()
    }
    
    func setLabels() {
        self.headerTitleLabel.font = UIFont.santander(family: .text, type: .bold, size: 18)
        self.headerTitleLabel.textAlignment = .left
        self.headerTitleLabel.textColor = .lisboaGray
        self.headerDescriptionLabel.font = UIFont.santander(family: .headline, type: .regular, size: 14)
        self.headerDescriptionLabel.textAlignment = .left
        self.headerDescriptionLabel.textColor = .lisboaGray
        self.titleLabel.font = UIFont.santander(family: .text, type: .regular, size: 16)
        self.titleLabel.textAlignment = .left
        self.titleLabel.textColor = .lisboaGray
    }
    
    func setAccessibilityIds() {
        self.headerTitleLabel.accessibilityIdentifier = AccessibilitySharingByWhatsapp.headerTitle
        self.headerDescriptionLabel.accessibilityIdentifier = AccessibilitySharingByWhatsapp.headerSubtitle
        self.whatsappImage.accessibilityIdentifier = AccessibilitySharingByWhatsapp.headerImg
        self.titleLabel.accessibilityIdentifier = AccessibilitySharingByWhatsapp.headerDescription
    }
    
    func hideItems() {
        self.whatsappImage.isHidden = true
        self.titleLabel.isHidden = true
        self.stackView.isHidden = true
    }
    
    func loadShareByWhatsappPill(_ viewModel: ShareBizumSummaryViewModel) {
        guard let type = viewModel.type, let contacts = viewModel.contacts, let contact = contacts.first else {
            self.hideItems()
            return
        }
        switch type {
        case .simple:
            let singlePill = BizumSummarySharingByWhatsappSingleView()
            singlePill.delegate = self
            singlePill.configure(contact)
            self.stackView.addArrangedSubview(singlePill)
        case .multiple:
            let multiplePill = BizumSummarySharingByWhatsappMultipleView()
            multiplePill.delegate = self
            multiplePill.configure(contacts)
            self.stackView.addArrangedSubview(multiplePill)
        }
    }
}

// MARK: - Tap actions
extension BizumSummarySharingByWhatsappView: DidTapInSharingByWhatsappSinglePillDelegate {
    func didTapInSharingByWhatsappSinglePill() {
        delegate?.didTapInShareByWhatsapp()
    }
}

extension BizumSummarySharingByWhatsappView: DidTapInSharingByWhatsappMultiplePillDelegate {
    func didTapInSharingByWhatsappMultiplePill() {
        delegate?.didTapInShareByWhatsapp()
    }
}
