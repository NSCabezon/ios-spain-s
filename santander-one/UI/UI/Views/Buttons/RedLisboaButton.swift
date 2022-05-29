//
//  RedLisboaButton.swift
//  UI
//
//  Created by Carlos Monfort Gómez on 04/12/2019.
//

import Foundation

public class RedLisboaButton: LisboaButton {
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    func configure() {
        self.setTitleColor(.white, for: .normal)
        self.titleLabel?.font = UIFont.santander(family: .text, type: .bold, size: 16)
        self.backgroundNormalColor = .santanderRed
        self.backgroundPressedColor = .bostonRed
        self.borderWidth = 1
        self.borderColor = .santanderRed
    }
    
    @objc
    override func didPressButton(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            self.backgroundColor = backgroundPressedColor
            self.borderColor = backgroundPressedColor
        } else if gestureRecognizer.state == .ended {
            self.backgroundColor = backgroundNormalColor
            self.borderColor = backgroundNormalColor
        }
    }
}
