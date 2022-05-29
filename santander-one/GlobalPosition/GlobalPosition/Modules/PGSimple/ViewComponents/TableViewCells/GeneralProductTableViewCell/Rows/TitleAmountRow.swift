//
//  TitleAmountRow.swift
//  GlobalPosition
//
//  Created by Jose Camallonga on 21/10/21.
//

import Foundation
import UIOneComponents

final class TitleAmountRow: UIStackView {
    private lazy var labelTitle: UILabel = {
        let label = UILabel()
        label.textColor = .oneBrownishGray
        label.font = UIFont.typography(fontName: .oneB300Regular)
        return label
    }()
    
    private lazy var labelAmount: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func setInfo(title: String, amount: NSAttributedString?, titleAccessibilityId: String?, amountAccessibilityId: String?) {
        labelTitle.text = title
        labelTitle.accessibilityIdentifier = titleAccessibilityId
        labelAmount.attributedText = amount
        labelAmount.accessibilityIdentifier = amountAccessibilityId
    }
}

extension TitleAmountRow: GeneralProductCellRowProtocol {
    func setDiscreteMode(_ discreteMode: Bool) {
        discreteMode ? labelAmount.blur(5.0) : labelAmount.removeBlur()
    }
}

private extension TitleAmountRow {
    func commonInit() {
        addArrangedSubview(labelTitle)
        addArrangedSubview(labelAmount)
        axis = .horizontal
        alignment = .firstBaseline
        distribution = .fillProportionally
    }
}
