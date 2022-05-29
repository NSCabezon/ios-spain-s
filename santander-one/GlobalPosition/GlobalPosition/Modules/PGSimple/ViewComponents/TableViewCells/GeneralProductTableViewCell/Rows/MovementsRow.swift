//
//  MovementsRow.swift
//  GlobalPosition
//
//  Created by Jose Camallonga on 21/10/21.
//

import CoreFoundationLib
import Foundation
import UIOneComponents
import UI


final class MovementsRow: UIStackView {
    private lazy var labelNumber: PaddingLabel = {
        let label = PaddingLabel()
        label.backgroundColor = .oneTurquoise.withAlphaComponent(0.07)
        label.textColor = .oneLisboaGray
        label.font = UIFont.typography(fontName: .oneB300Regular)
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 8
        label.textInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
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
    
    func setInfo(number: Int, numberAccessibilityId: String?) {
        let placeholder = [StringPlaceholder(.number, String(number))]
        let string = localized(number == 1 ? "pg_label_basketMovements_one" : "pg_label_basketMovements_other", placeholder)
        labelNumber.configureText(withLocalizedString: string, andConfiguration: nil)
        labelNumber.accessibilityIdentifier = numberAccessibilityId
    }
}

private extension MovementsRow {
    func commonInit() {
        addArrangedSubview(labelNumber)
        axis = .horizontal
        distribution = .fillProportionally
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
}
