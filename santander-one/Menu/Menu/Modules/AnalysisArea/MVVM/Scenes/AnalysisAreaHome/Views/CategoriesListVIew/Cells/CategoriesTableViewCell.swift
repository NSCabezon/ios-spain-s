//
//  CategoriesTableViewCell.swift
//  Menu
//
//  Created by Jose Javier Montes Romero on 23/1/22.
//

import UIKit
import UIOneComponents
import CoreFoundationLib

protocol CategoriesTableViewCellRepresentable {
    var titleKey: String { get }
    var movementsKey: String { get }
    var amount: Decimal { get }
    var imageKey: String { get }
}

class CategoriesTableViewCell: UITableViewCell {

    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var categoryView: CategoryView!
    private var representable: CategoryRepresentable?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setAppearance()
    }

    func setCellInfo(_ info: CategoryRepresentable) {
        representable = info
        categoryView.setInfo(info)
        setAccessibilityIdentifiers(info)
        setAccessibility(setViewAccessibility: setAccessibilityInfo)
    }
    
}

private extension CategoriesTableViewCell {
    func setAppearance() {
        containerView.backgroundColor = .oneWhite
        containerView.setOneCornerRadius(type: .oneShRadius4)
        containerView.clipsToBounds = true
        containerView.setOneShadows(type: .oneShadowSmall)
        containerView.layer.masksToBounds = false
    }
    
    func setAccessibilityIdentifiers(_ info: CategoryRepresentable) {
        self.accessibilityIdentifier = "\(AnalysisAreaAccessibility.analysisCardCategoriesList)_\(info.categorization.categorieKey)_\(info.type.rawValue)"
    }
    
    func setAccessibilityInfo() {
        accessibilityElements = [categoryView].compactMap {$0}
    }
}

extension CategoriesTableViewCell: AccessibilityCapable {}
