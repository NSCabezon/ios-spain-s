//
//  FractionableItemView.swift
//  UI
//

import Foundation
import CoreFoundationLib

public final class FractionableItemView: XibView {
    @IBOutlet private weak var percentageImageView: UIImageView!
    @IBOutlet private weak var arrowImageView: UIImageView!
    @IBOutlet private weak var fractionateLabel: UILabel!
    @IBOutlet private weak var fractionateHeightConstraint: NSLayoutConstraint!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }

    public func setViewModel(_ viewModel: FractionableItemViewModel) {
        self.fractionateLabel.configureText(withLocalizedString: viewModel.styledTitle)
    }
}

private extension FractionableItemView {
    func setupView() {
        self.fractionateLabel.textColor = .darkTorquoise
        self.fractionateLabel.font = UIFont.santander(size: 16.0)
        self.arrowImageView.image = Assets.image(named: "icnArrowRightG")
        self.percentageImageView.image = Assets.image(named: "icnOptionsTagPay")
        self.setAccessibilityIdentifiers()
    }
    
    func setAccessibilityIdentifiers() {
        self.accessibilityIdentifier = AccessibilityOthers.fractionateView.rawValue
        self.fractionateLabel.accessibilityIdentifier = AccessibilityOthers.fractionateTitle.rawValue
        self.percentageImageView.isAccessibilityElement = true
        self.arrowImageView.isAccessibilityElement = true
        setAccessibility {
            self.percentageImageView.isAccessibilityElement = false
            self.arrowImageView.isAccessibilityElement = false
        }
        self.percentageImageView.accessibilityIdentifier = AccessibilityOthers.fractionatePercentage.rawValue
        self.arrowImageView.accessibilityIdentifier = AccessibilityOthers.fractionateArrow.rawValue
    }
}

extension FractionableItemView: AccessibilityCapable { }

public struct FractionableItemViewModel {
    let styledTitle: LocalizedStylableText
    
    public init(styledTitle: LocalizedStylableText) {
        self.styledTitle = styledTitle
    }
}
