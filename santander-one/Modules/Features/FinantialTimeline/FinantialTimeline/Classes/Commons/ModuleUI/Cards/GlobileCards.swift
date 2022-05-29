//
//  GlobileCards.swift
//  FinantialTimeline
//
//  Created by Hernán Villamil on 22/9/21.
//

import Foundation

import UIKit
import CoreGraphics

class GlobileCards: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
}
    
extension GlobileCards {
    func setup() {
        layer.borderColor = UIColor.brownGray.cgColor
        layer.borderWidth = 1.0
        layer.cornerRadius = 5.0
        backgroundColor = .white
        addShadow()
    }
    
    private func addShadow() {
        clipsToBounds = false
        layer.masksToBounds = false
        layer.shadowColor = UIColor.LightSanGray.cgColor
        layer.shadowOpacity = 0.7
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 3
    }
}
