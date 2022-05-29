//
//  PressedButton.swift
//  UI
//
//  Created by Juan Carlos López Robles on 10/24/19.
//

import UIKit

@available(*, deprecated, message: "Use PressableButton instead")
public typealias PresedButton = PressableButton

public struct PressableButtonStyle {
    let titleColor: UIColor?
    let titleFont: UIFont?
    let normalColor: UIColor?
    let pressedColor: UIColor?
    let cornerRadius: CGFloat?
    let borderWidth: CGFloat?
    let borderColor: UIColor?
    
    public init(
        titleColor: UIColor? = nil,
        titleFont: UIFont? = nil,
        normalColor: UIColor? = nil,
        pressedColor: UIColor? = nil,
        cornerRadius: CGFloat? = nil,
        borderWidth: CGFloat? = nil,
        borderColor: UIColor? = nil
    ) {
        self.titleColor = titleColor
        self.titleFont = titleFont
        self.normalColor = normalColor
        self.pressedColor = pressedColor
        self.cornerRadius = cornerRadius
        self.borderWidth = borderWidth
        self.borderColor = borderColor
    }
    
    public static let redButton: PressableButtonStyle = PressableButtonStyle(titleColor: .white, titleFont: UIFont.santander(family: .text, type: .bold, size: 16), normalColor: .santanderRed, pressedColor: .bostonRed, cornerRadius: 24, borderWidth: 0, borderColor: nil)
    
    public static let whiteButton: PressableButtonStyle = PressableButtonStyle(titleColor: .santanderRed, titleFont: UIFont.santander(family: .text, type: .regular, size: 16), normalColor: .white, pressedColor: .sky, cornerRadius: 24, borderWidth: 1, borderColor: .santanderRed)
}

public class PressableButton: UIButton {
    
    @IBInspectable public var pressedColor: UIColor?
    @IBInspectable public var normalColor: UIColor? {
        willSet { self.superview?.backgroundColor = newValue }
    }
    
    @IBInspectable var radius: CGFloat = 0.0 {
        willSet {
            self.superview?.layer.cornerRadius = newValue
            self.layer.cornerRadius = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    public func setup(style: PressableButtonStyle) {
        if let titleColor = style.titleColor {
            self.setTitleColor(titleColor, for: .normal)
        }
        if let titleFont = style.titleFont {
            self.titleLabel?.font = titleFont
        }
        if let color = style.normalColor {
            self.normalColor = color
        }
        if let color = style.pressedColor {
            self.pressedColor = color
        }
        if let cornerRadius = style.cornerRadius {
            self.radius = cornerRadius
        }
        if let borderWidth = style.borderWidth {
            self.layer.borderWidth = borderWidth
        }
        if let borderColor = style.borderColor {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    func setupView() {
        addLongPressGesture()
    }
    
    func addLongPressGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(didPressButton))
        longPressGesture.minimumPressDuration = 0.0
        longPressGesture.allowableMovement = 0.0
        longPressGesture.delegate = self
        self.addGestureRecognizer(longPressGesture)
    }
    
    @objc
    func didPressButton(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            self.superview?.backgroundColor = pressedColor
        } else if gestureRecognizer.state == .ended {
            self.superview?.backgroundColor = normalColor
        }
    }
}

extension PressableButton: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)
        -> Bool {
        return true
    }
}
