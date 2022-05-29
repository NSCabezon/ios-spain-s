//
//  CardTransactionCollectionDetailsView.swift
//  Cards
//
//  Created by Oscar R. Garrucho.
//  Linkedin: https://www.linkedin.com/in/oscar-garrucho/
//  Copyright © 2022 Oscar R. Garrucho. All rights reserved.
//

import CoreFoundationLib
import UIKit
import UI
import UIOneComponents

protocol CardTransactionCollectionDetailsViewDelegate: AnyObject {
    func didTapOnFractionate()
}

final class OldCardTransactionCollectionDetailsView: XibView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var cardAliasLabel: UILabel!
    @IBOutlet private weak var amountLabelView: OneLabelHighlightedView!
    @IBOutlet private weak var fractionateButton: RightArrowButtton!
    @IBOutlet private weak var pointLaneView: PointLine!
    
    let verticalSpace: CGFloat = 94.0
    private weak var delegate: CardTransactionCollectionDetailsViewDelegate?
    private var viewModel: OldCardTransactionDetailViewModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setDelegate(delegate: CardTransactionCollectionDetailsViewDelegate) {
        self.delegate = delegate
    }
    
    func configureView(_ viewModel: OldCardTransactionDetailViewModel, showFractionateButton: Bool = false) {
        self.viewModel = viewModel
        setTiteLabel(viewModel.description)
        setCardAliasLabel(viewModel.cardAlias)
        setAmountLabel(viewModel.formattedAmount)
        showPositiveAmountBackgroundViewIfNeeded(viewModel)
        showFractionateButtonIfNeeded(viewModel, showFractionateButton: showFractionateButton)
        if !viewModel.showPossitiveAmountBackground {
            amountLabelView?.style = .clear
        }
    }
    
    func getHeight() -> CGFloat {
        let text = titleLabel.text ?? ""
        let width = bounds.width - ExpandableConfig.margin
        let font = titleLabel.font ?? UIFont.santander(family: .text, type: .bold, size: 18)
        return text.height(withConstrainedWidth: width, font: font) + verticalSpace
    }
    
    func hideFractionateButton() {
        fractionateButton.isHidden = true
        fractionateButton.alpha = 0
    }
    
    private func showFractionateButton() {
        fractionateButton.isHidden = false
        self.fractionateButton.alpha = 1
    }
    
    @IBAction func didTapOnFractionate(_ sender: RightArrowButtton) {
        delegate?.didTapOnFractionate()
    }
}

private extension OldCardTransactionCollectionDetailsView {
    func setupView() {
        backgroundColor = .clear
        pointLaneView.pointColor = .mediumSkyGray
        fractionateButton.titleLabel?.font = .santander(family: .text, type: .bold, size: 11)
        fractionateButton.setTitleColor(.darkTorquoise, for: .normal)
        fractionateButton.isHidden = true
    }
    
    func setTiteLabel(_ text: String) {
        let localizedConfig = LocalizedStylableTextConfiguration(
            font: .santander(family: .micro, type: .bold, size: 18),
            alignment: .none,
            lineBreakMode: .none
        )
        titleLabel.configureText(
            withKey: text,
            andConfiguration: localizedConfig
        )
        titleLabel.numberOfLines = 1

    }

    func setCardAliasLabel(_ text: String) {
        let localizedConfig = LocalizedStylableTextConfiguration(
            font: .santander(family: .micro, type: .regular, size: 14),
            alignment: .none,
            lineBreakMode: .none
        )
        cardAliasLabel.configureText(
            withKey: text,
            andConfiguration: localizedConfig
        )
        cardAliasLabel.numberOfLines = 1
    }

    func setAmountLabel(_ attributedText: NSAttributedString?) {
        amountLabelView.attributedText = attributedText
    }

    func showFractionateButtonIfNeeded(_ viewModel: OldCardTransactionDetailViewModel, showFractionateButton: Bool = false) {
        var fractionatedButtonText: String?
        if viewModel.isAlreadyFractionated {
            fractionatedButtonText = localized("transaction_button_fractional").uppercased()
        } else {
            fractionatedButtonText = localized("transaction_buttom_installments").uppercased()
        }
        self.fractionateButton.isUserInteractionEnabled = !viewModel.isAlreadyFractionated
        self.fractionateButton.showArrow = !viewModel.isAlreadyFractionated
        self.fractionateButton.setTitle(fractionatedButtonText, for: .normal)
        self.fractionateButton.sizeToFit()
        if showFractionateButton && viewModel.isEasyPayEnabled, self.fractionateButton.isHidden {
            self.showFractionateButton()
        }
    }
    
    func showPositiveAmountBackgroundViewIfNeeded(_ viewModel: OldCardTransactionDetailViewModel) {
        if let value = viewModel.amount.value, value > 0 {
            self.amountLabelView?.style = .lightGreen
        } else {
            self.amountLabelView?.style = .clear
        }
    }
}
