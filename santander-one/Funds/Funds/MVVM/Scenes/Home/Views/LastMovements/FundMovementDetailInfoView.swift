//
//  FundMovementDetailInfoView.swift
//  Funds
//

import UI
import CoreFoundationLib

final class FundMovementDetailInfoView: XibView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var valueLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func setupView(title: String, value: String, titleId: String? = nil, valueId: String? = nil) {
        self.titleLabel.text = title
        self.valueLabel.text = value
        if let titleId = titleId {
            titleLabel.accessibilityIdentifier = titleId
        }
        if let valueId = valueId {
            valueLabel.accessibilityIdentifier = valueId
        }
        setAccessibility { [weak self] in
            self?.titleLabel.accessibilityLabel = title + " " + value
            self?.valueLabel.isAccessibilityElement = false
        }
    }
}

extension FundMovementDetailInfoView: AccessibilityCapable {}
