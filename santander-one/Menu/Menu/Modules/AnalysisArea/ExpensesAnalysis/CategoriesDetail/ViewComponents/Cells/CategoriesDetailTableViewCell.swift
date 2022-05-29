//
//  CategoriesDetailTableViewCell.swift
//  Menu
//
//  Created by David Gálvez Alonso on 29/06/2021.
//

import UIKit
import UI
import CoreFoundationLib

final class CategoriesDetailTableViewCell: UITableViewCell {

    @IBOutlet private weak var aliasLabel: UILabel!
    @IBOutlet private weak var idLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var detailImageView: UIImageView!
    @IBOutlet private weak var productAliasLabel: UILabel!
    @IBOutlet private weak var subcategoryLabel: UILabel!
    @IBOutlet private weak var roundedView: UIView!
    @IBOutlet private weak var dottedLineView: DottedLineView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupLabels()
        self.setupViews()
        self.setAccessibilityIdentifiers()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        subcategoryLabel.text = ""
        productAliasLabel.text = ""
        amountLabel.text = ""
        idLabel.text = ""
        aliasLabel.text = ""
    }
    
    func setViewModel(_ viewModel: CategoryDetailViewModel) {
        self.aliasLabel.text = viewModel.aliasDetail
        self.idLabel.text = viewModel.idDetail
        self.amountLabel.attributedText = viewModel.amountDetail
        self.productAliasLabel.text = viewModel.productAliasDetail
        self.subcategoryLabel.text = viewModel.subcategory
        self.detailImageView.image = Assets.image(named: viewModel.iconDetail)
        self.roundedView.backgroundColor = viewModel.subcategoryColor.sector.withAlphaComponent(0.2)
        self.subcategoryLabel.textColor = viewModel.subcategoryColor.textColor
    }
    
    func hideDottedLine() {
        dottedLineView.isHidden = true
    }
}

private extension CategoriesDetailTableViewCell {
    
    func setupLabels() {
        self.aliasLabel.font = .santander(family: .text, type: .regular, size: 16)
        self.aliasLabel.textColor = .lisboaGray
        self.idLabel.font = .santander(family: .text, type: .regular, size: 16)
        self.idLabel.textColor = .lisboaGray
        self.amountLabel.font = .santander(family: .text, type: .bold, size: 20)
        self.amountLabel.textColor = .lisboaGray
        self.productAliasLabel.font = .santander(family: .text, type: .light, size: 13)
        self.productAliasLabel.textColor = .lisboaGray
        self.subcategoryLabel.font = .santander(family: .text, type: .bold, size: 11)
    }
    
    func setupViews() {
        self.roundedView.layer.cornerRadius = 9.5
        self.roundedView.layer.masksToBounds = true
    }
    
    func setAccessibilityIdentifiers() {
        self.aliasLabel.accessibilityIdentifier = AccesibilityCategoryDetailType.alias
        self.idLabel.accessibilityIdentifier = AccesibilityCategoryDetailType.idDetail
        self.amountLabel.accessibilityIdentifier = AccesibilityCategoryDetailType.amount
        self.productAliasLabel.accessibilityIdentifier = AccesibilityCategoryDetailType.productAlias
        self.roundedView.accessibilityIdentifier = AccesibilityCategoryDetailType.subcategory
        self.accessibilityIdentifier = AccesibilityCategoryDetailType.detailCell
    }
}
