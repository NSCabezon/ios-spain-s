//
//  BottomDividerView.swift
//  Bills
//
//  Created by Juan Carlos López Robles on 4/7/20.
//

import Foundation

final class BottomTransmitterDividerView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addHeightConstraint()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.addHeightConstraint()
    }
}

private extension BottomTransmitterDividerView {
    func addHeightConstraint() {
        self.heightAnchor.constraint(equalToConstant: 12).isActive = true
    }
}
