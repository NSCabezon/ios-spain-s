//
//  BizumHistoricInitialsView.swift
//  Bizum
//
//  Created by Jose Ignacio de Juan Díaz on 30/10/2020.
//

import Foundation
import UI

final class BizumHistoricInitialsView: XibView {
    
    @IBOutlet private weak var bgView: UIView!
    @IBOutlet private weak var initialsLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configView()
        self.setAccessibilityIdentifiers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configView()
    }
    
    func set(_ initials: String, color: UIColor) {
        initialsLabel.text = initials
        bgView?.backgroundColor = color
    }
    
}

private extension BizumHistoricInitialsView {
    func configView() {
        initialsLabel.setSantanderTextFont(type: .bold, size: 15, color: .white)
        bgView.layer.cornerRadius = frame.width / 2
    }
    
    func setAccessibilityIdentifiers() {
        self.initialsLabel.accessibilityIdentifier = AccessibilityBizumHistoric.bizumHistoricInitialsLabel
        self.bgView.accessibilityIdentifier = AccessibilityBizumHistoric.bizumHistoricInitialsBgView
    }
}
