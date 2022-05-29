//
//  CategoriesListCell.swift
//  Menu
//
//  Created by José María Jiménez Pérez on 29/6/21.
//

import UIKit
import UI
import CoreFoundationLib

final class CategoriesListCell: UITableViewCell {

    @IBOutlet private weak var separator: UIView!
    @IBOutlet private weak var categoryIcon: UIImageView!
    @IBOutlet private weak var categoryLabel: UILabel!
    @IBOutlet private weak var percentageLabel: UILabel!
    @IBOutlet private weak var movementsCountLabel: UILabel!
    @IBOutlet private weak var movementsLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var arrowIcon: UIImageView!
    @IBOutlet private weak var iconLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var separatorLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var separatorTrailingConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.separator.backgroundColor = .mediumSkyGray
        self.categoryLabel.font = .santander(family: .text, type: .bold, size: 16)
        self.categoryLabel.textColor = .lisboaGray
        self.percentageLabel.font = .santander(family: .text, type: .regular, size: 14)
        self.percentageLabel.textColor = .lisboaGray
        self.amountLabel.font = .santander(family: .text, type: .bold, size: 18)
        self.amountLabel.textColor = .lisboaGray
        self.movementsCountLabel.font = .santander(family: .text, type: .bold, size: 12)
        self.movementsCountLabel.textColor = .lisboaGray
        self.movementsLabel.font = .santander(family: .text, type: .regular, size: 12)
        self.movementsLabel.textColor = .grafite
    }
    
    func setupWith(viewModel: ExpenseIncomeCategoriesCellViewModel) {
        self.categoryIcon.image = Assets.image(named: viewModel.category.iconKey)
        self.categoryLabel.text = localized(viewModel.category.localizedKey)
        self.categoryLabel.accessibilityIdentifier = viewModel.category.accessibilityIdentifier
        self.percentageLabel.text = "(\(viewModel.percentage)%)"
        let amountDecorator = MoneyDecorator(AmountEntity(value: viewModel.amount, currency: CoreCurrencyDefault.default), font: .santander(family: .text, type: .bold, size: 18), decimalFontSize: 14)
        self.amountLabel.attributedText = amountDecorator.getFormatedCurrency()
        self.movementsCountLabel.text = "\(viewModel.numberOfMovements) "
        self.movementsLabel.text = localized("analysis_label_movement_other")
        if viewModel.shouldExpand {
            self.arrowIcon.image = viewModel.isExpanded ? Assets.image(named: "icnArrowUp") : Assets.image(named: "icnArrowDown")
        } else {
            self.arrowIcon.image = Assets.image(named: "icnArrowRight")
        }
        self.backgroundColor = viewModel.type == .normal ? .white : .skyGray
        self.iconLeadingConstraint.constant = viewModel.type == .normal ? 17 : 26
        self.separatorLeadingConstraint.constant = self.determineSeparatorConstraintsFor(viewModel: viewModel)
        self.separatorTrailingConstraint.constant = self.determineSeparatorConstraintsFor(viewModel: viewModel)
    }
}

private extension CategoriesListCell {
    func determineSeparatorConstraintsFor(viewModel: ExpenseIncomeCategoriesCellViewModel) -> CGFloat {
        return viewModel.type == .normal || viewModel.type == .otherExpanded && viewModel.isFirstOther ? 0 : 15
    }
}
