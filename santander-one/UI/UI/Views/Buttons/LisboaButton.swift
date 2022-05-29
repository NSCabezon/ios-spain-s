//
//  RedButton.swift
//  UI
//
//  Created by Juan Carlos López Robles on 11/11/19.
//

import UIKit

@IBDesignable public class LisboaButton: UIButton {
    
    @IBInspectable public var backgroundPressedColor: UIColor?
    @IBInspectable public var backgroundNormalColor: UIColor? {
        willSet { self.backgroundColor = newValue }
    }
    
    @IBInspectable public var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            } else {
                return nil
            }
        }
        set {
            if let newValue = newValue {
                layer.borderColor = newValue.cgColor
            }
        }
    }
    
    @IBInspectable public var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable public var contentInsets: UIEdgeInsets {
        get {
            return self.contentEdgeInsets
        }
        set {
            self.contentEdgeInsets = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = self.bounds.size.height / 2
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.layer.cornerRadius = self.bounds.size.height / 2
        setupView()
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = self.bounds.size.height / 2
        setupView()
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        configureDraw()
    }
    
    func setupView() {
        addLongPressGesture()
        self.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        self.clipsToBounds = true
    }
    
    func addLongPressGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(didPressButton))
        longPressGesture.minimumPressDuration = 0.0
        longPressGesture.allowableMovement = 0.0
        longPressGesture.delegate = self
        self.addGestureRecognizer(longPressGesture)
    }
    
    func configureDraw () {
        layer.cornerRadius = frame.height / 2.0
    }
    
    @objc
    func didPressButton(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            self.backgroundColor = backgroundPressedColor
        } else if gestureRecognizer.state == .ended {
            self.backgroundColor = backgroundNormalColor
        }
    }
    
    private var action: (() -> Void)?
    
    @IBAction func customAction() {
        self.action?()
    }
    
    public func addAction(_ action: @escaping () -> Void) {
        self.action = action
        let gesture = UITapGestureRecognizer(target: self, action: #selector(customAction))
        self.addGestureRecognizer(gesture)
    }
    
    public func addSelectorAction(target: Any?, _ action: Selector) {
        let gesture = UITapGestureRecognizer(target: target, action: action)
        self.addGestureRecognizer(gesture)
    }
    
    public func configureAsWhiteButton() {
        self.setTitleColor(.santanderRed, for: .normal)
        self.titleLabel?.font = UIFont.santander(family: .text, type: .regular, size: 16)
        self.titleLabel?.textAlignment = .center
        self.backgroundNormalColor = .white
        self.backgroundPressedColor = .sky
        self.borderWidth = 1
        self.borderColor = .santanderRed
    }
    
    public func configureAsRedButton() {
        self.setTitleColor(.white, for: .normal)
        self.titleLabel?.font = UIFont.santander(family: .text, type: .bold, size: 16)
        self.titleLabel?.textAlignment = .center
        self.backgroundNormalColor = .santanderRed
        self.backgroundPressedColor = .bostonRed
        self.borderWidth = 1
        self.borderColor = .santanderRed
    }
}

extension LisboaButton: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)
        -> Bool {
        return true
    }
}
