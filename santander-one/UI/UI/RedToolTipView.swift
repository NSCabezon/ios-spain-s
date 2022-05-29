//
//  RedToolTipView.swift
//  UI
//
//  Created by Ignacio González Miró on 20/05/2020.
//

import UIKit

public final class RedToolTipView: UIDesignableView {
    @IBOutlet weak private var bubbleView: UIView!
    @IBOutlet weak private var leftLabel: UILabel!
    @IBOutlet weak private var rightLabel: UILabel!
    @IBOutlet weak private var triangleImage: UIImageView!

    public struct Styles {
        static let cornerRadius: CGFloat = 6.0
        static let backgroundColor = UIColor.lightPink
        static let shadowColor = UIColor.black.cgColor
        static let shadowOffset = CGSize(width: 0.0, height: 2.0)
        static let shadowRadius: CGFloat = 2.0
        static let shadowOpacity: Float = 0.1
    }
    
    public override func commonInit() {
        super.commonInit()
        self.setupUI()
    }
        
    public func textInBubble(leftText: String, rightText: NSAttributedString) {
        self.leftLabel.text = leftText
        self.rightLabel.attributedText = rightText
    }
}

private extension RedToolTipView {
    func setupUI() {
        self.leftLabel.numberOfLines = 0
        self.leftLabel.setSantanderTextFont(type: .regular, size: 12.0, color: .grafite)
        self.rightLabel.setSantanderTextFont(type: .bold, size: 16.2, color: .black)
        self.bubbleView.backgroundColor = Styles.backgroundColor
        self.bubbleView.layer.cornerRadius = Styles.cornerRadius
        self.bubbleView.layer.shadowColor = Styles.shadowColor
        self.bubbleView.layer.shadowOffset = Styles.shadowOffset
        self.bubbleView.layer.shadowRadius = Styles.shadowRadius
        self.bubbleView.layer.shadowOpacity = Styles.shadowOpacity
        
        self.backgroundColor = .clear
        self.triangleImage.image = Assets.image(named: "icnTriangleTooltipPink")
    }
}
