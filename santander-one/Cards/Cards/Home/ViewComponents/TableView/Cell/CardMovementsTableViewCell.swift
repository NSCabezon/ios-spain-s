//
//  MovementsTableViewCell.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 10/25/19.
//

import UIKit
import UI
import UIOneComponents
import CoreFoundationLib

protocol CardMovementsTableViewCellDelegate: AnyObject {
    func didTapLoadOfferOnCell(atIndexPath indexPath: IndexPath)
}

final class CardMovementsTableViewCell: UITableViewCell {
    @IBOutlet private weak var discontinueLineView: DottedLineView!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var highlightView: UIView!
    @IBOutlet private weak var bottomStackView: UIStackView!
    @IBOutlet private weak var amountLabelView: OneLabelHighlightedView!
    private var indexPath: IndexPath?
    weak var delegate: CardMovementsTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.discontinueLineView.strokeColor = UIColor.mediumSkyGray
        self.descriptionLabel.textColor = .lisboaGray
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        let subViews = bottomStackView.arrangedSubviews
        for subview in subViews {
            bottomStackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
    }
    
    func configure(withViewModel viewModel: CardTransactionViewModel, index: IndexPath) {
        self.indexPath = index
        self.descriptionLabel.configureText(withLocalizedString: LocalizedStylableText(text: viewModel.title ?? "", styles: nil),
                                            andConfiguration: LocalizedStylableTextConfiguration(font: .santander(family: .text, type: .regular, size: 16),
                                                                                                 lineHeightMultiple: 0.75))
        self.amountLabelView.attributedText = viewModel.amountAttributeString
        let isFractionLabelEnabled = viewModel.isFractionLabelEnabled
        let isCrossSellingEnabled = viewModel.isCrossSellingEnabled
        if isFractionLabelEnabled && isCrossSellingEnabled {
            self.addFractionateView()
            self.addCrossSellingView(viewModel: viewModel)
        } else if isCrossSellingEnabled && !isFractionLabelEnabled {
            self.addCrossSellingView(viewModel: viewModel)
        } else if !isCrossSellingEnabled && isFractionLabelEnabled {
            self.addFractionateView()
        }
        
        if let value = viewModel.transaction.amount?.value, value > 0 {
            amountLabelView.style = .lightGreen
        } else {
            amountLabelView.style = .clear
        }
        self.setAccessibilityIdentifiers()
    }
    
    func setupHighlightBackgroundColor(_ color: UIColor) {
        highlightView.backgroundColor = color
    }
    
    func setupDiscontinueViewVisilibity(_ hidden: Bool) {
        discontinueLineView.isHidden = hidden
    }
}

private extension CardMovementsTableViewCell {
    func addFractionateView() {
        let customFractionateView = FractionableItemView(frame: .zero)
        customFractionateView.translatesAutoresizingMaskIntoConstraints = false
        customFractionateView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        let customViewModel = FractionableItemViewModel(styledTitle: localized("cards_tag_optionsFractionatePay"))
        customFractionateView.setViewModel(customViewModel)
        bottomStackView.addArrangedSubview(customFractionateView)
    }

    func addCrossSellingView(viewModel: CardTransactionViewModel) {
        let customCrossSellingView = CrossSellingButton()
        customCrossSellingView.translatesAutoresizingMaskIntoConstraints = false
        customCrossSellingView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        let buttonViewModel = CrossSellingButtonViewModel(title: viewModel.titleForCrossSellingLabel ?? "")
        customCrossSellingView.configureView(buttonViewModel)
        bottomStackView.addArrangedSubview(customCrossSellingView)
        customCrossSellingView.delegate = self
    }
    
    func didTapLoadOffers() {
        guard let indexPath = self.indexPath else { return }
        self.delegate?.didTapLoadOfferOnCell(atIndexPath: indexPath)
    }
    
    func setAccessibilityIdentifiers() {
        self.accessibilityIdentifier = AccessibilityCardMovement.movementView
        descriptionLabel.accessibilityIdentifier = AccessibilityCardMovement.movementDesc
        amountLabelView.accessibilityIdentifier = AccessibilityCardMovement.movementAmount
    }
}

extension CardMovementsTableViewCell: CrossSellingPressableButtonDelegate {
    func didTapCrossSellingButton() {
        didTapLoadOffers()
    }
}
