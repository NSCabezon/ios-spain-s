//
//  CardTransactionCollectionDetailsView.swift
//  Pods
//
//  Created by Hernán Villamil on 7/4/22.
//

import CoreFoundationLib
import OpenCombine
import CoreDomain
import UIKit
import UI
import UIOneComponents

final class CardTransactionCollectionDetailsView: XibView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var cardAliasLabel: UILabel!
    @IBOutlet private weak var amountLabelView: OneLabelHighlightedView!
    @IBOutlet private weak var fractionateButton: RightArrowButtton!
    @IBOutlet private weak var pointLaneView: PointLine!
    let didSelecFractionatedSubject = PassthroughSubject<Void, Never>()
    let verticalSpace: CGFloat = 94.0
    var item: CardTransactionViewItemRepresentable? {
        didSet { configureView(item,
                               showFractionateButton: item?.shouldPresentFractionatedButton ?? false)}
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
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
        didSelecFractionatedSubject.send()
    }
}

private extension CardTransactionCollectionDetailsView {
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

    func showFractionateButtonIfNeeded(_ item: CardTransactionViewItemRepresentable?, showFractionateButton: Bool = false) {
        var fractionatedButtonText: String?
        let isFractioned = item?.isFractioned ?? false
        if isFractioned {
            fractionatedButtonText = localized("transaction_button_fractional").uppercased()
        } else {
            fractionatedButtonText = localized("transaction_buttom_installments").uppercased()
        }
        self.fractionateButton.isUserInteractionEnabled = !isFractioned
        self.fractionateButton.showArrow = !isFractioned
        self.fractionateButton.setTitle(fractionatedButtonText, for: .normal)
        self.fractionateButton.sizeToFit()
        if showFractionateButton && isEasyPayEnabled(item), self.fractionateButton.isHidden {
            self.showFractionateButton()
        }
    }
    
    func showPositiveAmountBackgroundViewIfNeeded(_ item: CardTransactionViewItemRepresentable?) {
        if let value = item?.transaction.amountRepresentable?.value, value > 0 {
            self.amountLabelView?.style = .lightGreen
        } else {
            self.amountLabelView?.style = .clear
        }
    }
    
    func configureView(_ item: CardTransactionViewItemRepresentable?, showFractionateButton: Bool = false) {
        setTiteLabel(item?.transaction.description?.capitalized ?? "")
        setCardAliasLabel(item?.card.alias ?? "")
        setAmountLabel(getFormattedAmount(item?.transaction.amountRepresentable))
        showPositiveAmountBackgroundViewIfNeeded(item)
        showFractionateButtonIfNeeded(item, showFractionateButton: showFractionateButton)
        if !(item?.showAmountBackground ?? false) {
            amountLabelView?.style = .clear
        }
    }
}

private extension CardTransactionCollectionDetailsView {
    func getFormattedAmount(_ amount: AmountRepresentable?) -> NSAttributedString? {
        guard let unwrappedAmount = amount else { return nil }
        let font = UIFont.santander(family: .text, type: .bold, size: 32)
        return AmountRepresentableDecorator(unwrappedAmount,
                                            font: font)
            .getFormatedCurrency()
    }
    
    func isEasyPayEnabled(_ item: CardTransactionViewItemRepresentable?) -> Bool {
        guard let configuration =  item?.configuration,
                configuration.isEasyPayClassicEnabled else { return false }
        guard let card = item?.card,
                card.isCreditCard,
                !card.isBeneficiary else { return false }
        guard let minEasyPayAmount = item?.minEasyPayAmount else { return false }
        let value = NSDecimalNumber(decimal: item?.transaction.amountRepresentable?.value ?? 0)
        return abs(value.doubleValue) >= minEasyPayAmount
    }
}
