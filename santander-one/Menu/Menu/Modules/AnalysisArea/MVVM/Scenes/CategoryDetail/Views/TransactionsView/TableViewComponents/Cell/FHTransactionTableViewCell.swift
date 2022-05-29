//
//  FHTransactionTableViewCell.swift
//  Menu
//
//  Created by Jose Javier Montes Romero on 30/3/22.
//

import UIKit
import UI
import CoreFoundationLib
import CoreDomain
import UIOneComponents

class FHTransactionTableViewCell: UITableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var logoImage: UIImageView!
    @IBOutlet private weak var moreInfoLabel: UILabel!
    @IBOutlet private weak var separator: DashedLineView!
    @IBOutlet private weak var logoWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var amountContentView: UIView!
    var representable: FHTransactionListItemRepresentable?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
        setAccesibilityIdentifiers()
    }
    
    override func prepareForReuse() {
        titleLabel.text = ""
        amountLabel.text = ""
        descriptionLabel.text = ""
        moreInfoLabel.text = ""
    }

    func setupCell(with model: FHTransactionListItemRepresentable) {
        representable = model
        configureCell()
    }
    
}

private extension FHTransactionTableViewCell {
    func setupView() {
        titleLabel.font = .typography(fontName: .oneB300Regular)
        titleLabel.textColor = .oneLisboaGray
        descriptionLabel.font = .typography(fontName: .oneB200Regular)
        descriptionLabel.textColor = .oneBrownishGray
        moreInfoLabel.font = .typography(fontName: .oneB200Regular)
        moreInfoLabel.textColor = .oneBrownishGray
        amountLabel.textColor = .oneLisboaGray
    }
    
    func configureCell() {
        guard let model = representable else { return }
        titleLabel.text = model.title
        descriptionLabel.text = model.description
        moreInfoLabel.text = model.moreInfo
        let decorator = AmountRepresentableDecorator(model.amount, font: .typography(fontName: .oneB400Bold), decimalFontSize: 14)
        amountLabel.attributedText = decorator.formattedCurrencyWithoutMillion
        configureLogo()
        amountContentView.setOneCornerRadius(type: .oneShRadius4)
        amountContentView.backgroundColor = (model.amount.value ?? 0) > 0  ? UIColor.greenIce : UIColor.clear
    }
    
    func configureLogo() {
        guard let model = representable else { return }
        if let defaultImageName = model.defatultImageName,
            let defaultImage = Assets.image(named: defaultImageName) {
            self.logoImage.image = defaultImage
            self.checkImageSize()
        }
        if let urlImage = model.urlImage {
            self.logoImage.loadImage(urlString: urlImage,
                                     placeholder: Assets.image(named: model.defatultImageName ?? ""),
                                     completion: {
                self.checkImageSize()
            })
        }
    }
    
    func checkImageSize() {
        if !self.logoImage.isRightAspectRatio() {
            guard let image = self.logoImage.image else { return }
            let ratio = image.size.width / image.size.height
            self.updateImageAspecRatio(ratio)
        }
    }
    
    func updateImageAspecRatio(_ ratio: CGFloat) {
        logoWidthConstraint.constant = 16 * ratio
        layoutIfNeeded()
    }
    
    func setAccesibilityIdentifiers() {
        self.titleLabel?.accessibilityIdentifier = AnalysisAreaAccessibility.analysisTransactionLabelConcept
        self.amountLabel?.accessibilityIdentifier = AnalysisAreaAccessibility.analysisTransactionLabelAmount
        self.descriptionLabel?.accessibilityIdentifier = AnalysisAreaAccessibility.analysisTransactionLabelSubcategory
        self.logoImage?.accessibilityIdentifier = AnalysisAreaAccessibility.analysisTransactionLabelImg
        self.moreInfoLabel?.accessibilityIdentifier = AnalysisAreaAccessibility.analysisTransactionLabelNumber
    }
}
