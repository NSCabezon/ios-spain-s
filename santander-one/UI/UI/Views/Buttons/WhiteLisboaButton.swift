//
//  WhiteLisboaButton.swift
//  UI
//
//  Created by Carlos Monfort Gómez on 04/12/2019.
//

import Foundation

public class WhiteLisboaButton: LisboaButton {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }

    public func setIsEnabled(_ isEnabled: Bool) {
        self.isEnabled = isEnabled
        borderColor = isEnabled ? .santanderRed : .coolGray
    }

    private func configure() {
        self.setTitleColor(.santanderRed, for: .normal)
        self.setTitleColor(.brownGray, for: .disabled)
        self.titleLabel?.font = UIFont.santander(family: .text, type: .regular, size: 16)
        self.backgroundNormalColor = .white
        self.backgroundPressedColor = .skyGray
        self.borderWidth = 1
        self.borderColor = .santanderRed
        self.titleLabel?.textAlignment = .center
    }
}
