//
//  BizumHomeOperationMultipleCollectionViewCell.swift
//  Bizum
//
//  Created by Carlos Monfort Gómez on 27/01/2021.
//

import UIKit
import UI
import CoreFoundationLib
import ESUI

final class BizumHomeOperationMultipleCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak private var containerView: UIView!
    @IBOutlet weak private var typeImage: UIImageView!
    @IBOutlet weak private var stateImage: UIImageView!
    @IBOutlet weak private var dateLabel: UILabel!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var amountLabel: UILabel!
    @IBOutlet weak private var stateLabel: UILabel!
    @IBOutlet weak private var separatorView: UIView!
    @IBOutlet weak private var stateView: UIView!
    @IBOutlet weak private var multipleImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
        self.setAccessibilityIdentifiers()
    }

    func setViewModel(_ viewModel: BizumHomeOperationViewModel) {
        self.stateLabel.textColor = .darkTorquoise
        self.dateLabel.text = viewModel.date
        self.titleLabel.text = viewModel.title
        self.textLabel.text = self.getOperationConcept(viewModel.subtitle)
        self.amountLabel.attributedText = viewModel.moneyDecorated(.santander(family: .text, type: .bold, size: 16)).formatAsMillions()
        self.stateLabel.text = viewModel.state
        switch viewModel.transactionType {
        case .donation:
            self.typeImage.image = ESAssets.image(named: "icnDonationHistory")
        case .emittedSend, .purchase, .receiverRequest:
            self.typeImage.image = ESAssets.image(named: "icnSendRedHistory")
        case .emittedRequest, .receiverSend:
            self.typeImage.image = ESAssets.image(named: "icnReceivedGreenHistory")
        }
        self.stateImage.image = viewModel.stateType?.homeImage
    }

}

private extension BizumHomeOperationMultipleCollectionViewCell {
    func setupView() {
        self.containerView.backgroundColor = .white
        let shadowConfiguration = ShadowConfiguration(color: .mediumSkyGray,
                                                opacity: 0.7,
                                                radius: 2,
                                                withOffset: 1,
                                                heightOffset: 2)
        self.containerView.drawRoundedBorderAndShadow(with: shadowConfiguration,
                                        cornerRadius: 4,
                                        borderColor: .lightSkyBlue,
                                        borderWith: 1)
        self.separatorView.backgroundColor = .lightSkyBlue
        self.stateView.backgroundColor = .skyGray
        self.dateLabel.textColor = .bostonRed
        self.dateLabel.font = .santander(type: .bold, size: 12.0)
        self.titleLabel.textColor = .lisboaGray
        self.titleLabel.font = .santander(type: .bold, size: 16.0)
        self.textLabel.textColor = .lisboaGray
        self.textLabel.font = .santander(size: 12.0)
        self.textLabel.numberOfLines = 0
        self.amountLabel.textColor = .lisboaGray
        self.amountLabel.font = .santander(type: .bold, size: 16.0)
        self.stateLabel.textColor = .darkTorquoise
        self.stateLabel.font = .santander(type: .bold, size: 12.0)
        self.multipleImageView.image = ESAssets.image(named: "icnMultiplyBizum")
    }
    
    func getOperationConcept(_ concept: String?) -> String {
        guard let concept = concept, !concept.isEmpty else {
            return localized("bizum_label_notConcept")
        }
        return concept
    }
    
    func setAccessibilityIdentifiers() {
        containerView.accessibilityIdentifier = AccessibilityBizum.bizumViewRecentOperationContainerView
        dateLabel.accessibilityIdentifier = AccessibilityBizum.bizumLabelRecentOperationDate
        titleLabel.accessibilityIdentifier = AccessibilityBizum.bizumLabelRecentOperationTitle
        textLabel.accessibilityIdentifier = AccessibilityBizum.bizumLabelRecentOperationText
        amountLabel.accessibilityIdentifier = AccessibilityBizum.bizumLabelRecentOperationAmount
        stateLabel.accessibilityIdentifier = AccessibilityBizum.bizumLabelRecentOperationState
    }
}
