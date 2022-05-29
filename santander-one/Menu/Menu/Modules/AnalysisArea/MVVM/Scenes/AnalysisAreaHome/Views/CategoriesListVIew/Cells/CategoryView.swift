//
//  CategoryView.swift
//  Menu
//
//  Created by Luis Escámez Sánchez on 14/1/22.
//

import UIKit
import UI
import UIOneComponents
import CoreFoundationLib
import CoreDomain

protocol CategoryViewRepresentable {
    var titleKey: String { get }
    var movementsText: String { get }
    var amount: AmountEntity { get }
    var imageKey: String { get }
    var categorization: AnalysisAreaCategorization { get }
    var totalMovements: Int { get }
    var totalPercentage: Double { get }
}

class CategoryView: XibView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var amountContentView: UIView!
    @IBOutlet private weak var iconImageView: UIImageView!
    private var representable: CategoryViewRepresentable?
    private var typeOfCategories: AnalysisAreaCategorization = .expenses
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupUI()
    }
    
    func setInfo(_ info: CategoryRepresentable, positiveAmounHighlighted: Bool? = true) {
        let infoRepresentable =  CategoryViewRepresented(categoryData: info)
        self.representable = infoRepresentable
        self.typeOfCategories = infoRepresentable.categorization
        self.titleLabel.text = infoRepresentable.titleText
        self.subtitleLabel.text = infoRepresentable.movementsText
        self.amountLabel.attributedText = setAmount(infoRepresentable.amount)
        self.iconImageView.image = Assets.image(named: infoRepresentable.imageKey)
        self.setAccessibilityIdentifiers(representable?.titleKey ?? "")
        self.setAccessibility(setViewAccessibility: setAccessibilityInfo)
        self.amountContentView.setOneCornerRadius(type: .oneShRadius4)
        let highlighted = positiveAmounHighlighted ?? true
        self.amountContentView.backgroundColor = (info.amount.value ?? 0.0 >= 0) && highlighted ? UIColor.greenIce : UIColor.clear
    }
}

private extension CategoryView {
    
    func setupUI() {
        self.titleLabel.font = .typography(fontName: .oneH100Bold)
        self.subtitleLabel.font = .typography(fontName: .oneB300Regular)
        self.amountLabel.font = .typography(fontName: .oneH300Regular)
    }
    
    func setAccessibilityIdentifiers(_ titleKey: String) {
        self.titleLabel.accessibilityIdentifier = "\(AnalysisAreaAccessibility.categorizationLabel)_\(titleKey)"
        self.subtitleLabel.accessibilityIdentifier = "\(AnalysisAreaAccessibility.analysisLabelMovement)_\(titleKey)"
        self.amountLabel.accessibilityIdentifier = "\(AnalysisAreaAccessibility.analysisCardCategoriesListAmount)_\(titleKey)"
        self.iconImageView.accessibilityIdentifier = "\(AnalysisAreaAccessibility.icnCategoryCat)_\(titleKey)"
        self.iconImageView.isAccessibilityElement = !UIAccessibility.isVoiceOverRunning
        self.accessibilityElements = [self.subviews]
    }

    func setAmount(_ amount: AmountEntity) -> NSAttributedString {
        let moneyDecorator = MoneyDecorator(amount, font: .typography(fontName: .oneH300Regular), decimalFontSize: 16)
        return moneyDecorator.getFormattedStringWithoutMillion() ?? NSAttributedString(string: "")
    }
    
    func setAccessibilityInfo() {
        guard let representable = representable else { return }
        self.titleLabel.accessibilityLabel = localized("voiceover_tapAccessCategory", [StringPlaceholder(.value, representable.titleKey)]).text
        self.subtitleLabel.accessibilityLabel = representable.movementsText
        self.amountLabel.accessibilityLabel = setAmount(representable.amount).string
    }
}

extension CategoryView: AccessibilityCapable {}
