//
//  CardProductConfigTableViewCell.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 1/7/21.
//

import UI
import CoreFoundationLib

protocol CardProductConfigCellDelegate: AnyObject {
    func didPressCardCheckBox(_ viewModel: CardProductConfigCellViewModel)
}

final class CardProductConfigTableViewCell: UITableViewCell {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var cardImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var shortPANLabel: UILabel!
    @IBOutlet private weak var bankImageView: UIImageView!
    @IBOutlet private weak var availableStackView: UIStackView!
    @IBOutlet private weak var availableLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var checkBoxImageView: UIImageView!
    @IBOutlet private weak var dotsSeparatorView: DottedLineView!
    @IBOutlet private weak var lastCellTopSeparatorView: UIView!
    weak var delegate: CardProductConfigCellDelegate?
    private var viewModel: CardProductConfigCellViewModel?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }
    
    func setViewModel(_ viewModel: CardProductConfigCellViewModel) {
        self.viewModel = viewModel
        self.setLabelsText(viewModel)
        self.setCardImage(viewModel)
        self.setBankImage(viewModel)
        self.setAvailableView()
        self.setCheckBoxImage()
        self.setLastCell(viewModel.isLastCell)
    }
    
    @IBAction private func didPressCheckBox(_ sender: Any) {
        guard var viewModel = self.viewModel else { return }
        viewModel.setIsCellSelected(isSelected: !viewModel.isSelected)
        self.delegate?.didPressCardCheckBox(viewModel)
    }
}

private extension CardProductConfigTableViewCell {
    func setupView() {
        self.dotsSeparatorView.strokeColor = .lightSkyBlue
        self.lastCellTopSeparatorView.backgroundColor = self.containerView.backgroundColor
        self.lastCellTopSeparatorView.isHidden = true
        self.containerView.borders(for: [.left, .right], width: 1, color: .lightSkyBlue)
        self.setAvailableView()
        self.setLabelsStyle()
        self.setAccessibilityIdentifiers()
    }
    
    func setLabelsStyle() {
        self.nameLabel.setSantanderTextFont(type: .bold, size: 16, color: .lisboaGray)
        self.shortPANLabel.setSantanderTextFont(type: .light, size: 14, color: .lisboaGray)
        self.availableLabel.setSantanderTextFont(type: .regular, size: 11, color: .brownGray)
        self.availableLabel.textAlignment = .right
        self.amountLabel.setSantanderTextFont(color: .lisboaGray)
    }
    
    func setLabelsText(_ viewModel: CardProductConfigCellViewModel) {
        self.nameLabel.text = viewModel.name
        self.shortPANLabel.text = viewModel.pan
    }
    
    func setCardImage(_ viewModel: CardProductConfigCellViewModel) {
        guard viewModel.isSantanderCard else {
            self.cardImageView.image = Assets.image(named: "imgGenericCard")
            return
        }
        if let cardIconUrl = viewModel.cardIconURL {
            // TODO: - Remove default images when service is working
            self.cardImageView.loadImage(urlString: cardIconUrl,
                                         placeholder: Assets.image(named: "imgSantanderRedCard"))
        } else {
            self.cardImageView.image = Assets.image(named: "imgSantanderRedCard")
        }
    }
    
    func setBankImage(_ viewModel: CardProductConfigCellViewModel) {
        if let bankIconUrl = viewModel.bankIconUrl {
            // TODO: - Remove default images when service is working
            self.bankImageView.loadImage(urlString: bankIconUrl,
                                         placeholder: Assets.image(named: "icnSantander"))
        } else {
            // TODO: - Remove default image when service is working
            self.bankImageView.image = Assets.image(named: "icnSantander")
        }
    }
    
    func setCheckBoxImage() {
        let isSelected = self.viewModel?.isSelected ?? true
        self.checkBoxImageView.image = isSelected ? Assets.image(named: "icnCheckBoxSelectedGreen") : Assets.image(named: "icnCheckBoxUnSelectedGreen")
    }
    
    func setAvailableView() {
        guard let viewModel = self.viewModel, viewModel.showAvalaibleView else {
            self.availableStackView.isHidden = true
            return
        }
        self.availableStackView.isHidden = false
        self.availableLabel.text = localized("pg_label_outstandingBalanceDots")
        self.amountLabel.attributedText = viewModel.availableAmount
    }
    
    func setLastCell(_ isLastCell: Bool) {
        guard isLastCell else { return }
        self.dotsSeparatorView.isHidden = true
        self.lastCellTopSeparatorView.isHidden = false
        self.containerView.drawBorder(cornerRadius: 6, color: .lightSkyBlue, width: 1)
        self.containerView.layer.masksToBounds = true
        if #available(iOS 11.0, *) {
            self.containerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            self.containerView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 10)
        }
    }
    
    func setAccessibilityIdentifiers() {
        self.nameLabel.accessibilityIdentifier = AccessibilityExpensesAnalysisConfig.cardNameLabel
        self.shortPANLabel.accessibilityIdentifier = AccessibilityExpensesAnalysisConfig.cardShortPanLabel
        self.cardImageView.accessibilityIdentifier = AccessibilityExpensesAnalysisConfig.cardImageView
        self.bankImageView.accessibilityIdentifier = AccessibilityExpensesAnalysisConfig.cardBankImageView
        self.availableLabel.accessibilityIdentifier = AccessibilityExpensesAnalysisConfig.cardAvailableLabel
        self.amountLabel.accessibilityIdentifier = AccessibilityExpensesAnalysisConfig.cardAmountLabel
        self.checkBoxImageView.accessibilityIdentifier = AccessibilityExpensesAnalysisConfig.cardCheckBox
    }
}
