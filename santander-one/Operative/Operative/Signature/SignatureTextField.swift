//
//  SignatureTextfield.swift
//  Operative
//
//  Created by Jose Carlos Estela Anguita on 31/12/2019.
//

import UIKit
import UI

protocol SignatureTextFieldDelegate: AnyObject {
    func textFieldDidDelete(_ textField: SignatureTextField)
}

class SignatureTextField: UITextField {
    enum Style {
        case editable
        case disabled
        case editing
        case edited
    }
    
    enum Position {
        case first
        case last
        case unknown
    }
    
    var signatureText: String? {
        didSet {
            self.accessibilityValue = signatureText
        }
    }
    var position: Position = .unknown
    private var borderLayer: CAShapeLayer?
    weak var signatureDelegate: SignatureTextFieldDelegate?
    private let padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    private lazy var disabledIndicatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 2.0
        view.backgroundColor = UIColor(white: 0.84, alpha: 1.0)
        view.heightAnchor.constraint(equalToConstant: 12).isActive = true
        view.widthAnchor.constraint(equalToConstant: 12).isActive = true
        self.addSubview(view)
        view.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    override func deleteBackward() {
        super.deleteBackward()
        self.signatureDelegate?.textFieldDidDelete(self)
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        var rect = super.caretRect(for: position)
        rect.size.height = 17.0
        rect.size.width = 1.0
        rect.origin.y = (self.frame.height - rect.size.height) / 2
        return rect
    }
    
    func set(style: Style) {
        switch style {
        case .editable:
            self.setupBorders(color: .mediumSkyGray, width: 1.0)
            self.font = .santander(family: .text, size: 20.0)
            self.backgroundColor = .white
            self.textColor = .lisboaGray
            self.disabledIndicatorView.isHidden = true
            self.isEnabled = true
            self.isAccessibilityElement = true
        case .disabled:
            self.setupBorders(color: .mediumSkyGray, width: 1.0)
            self.backgroundColor = .white
            self.disabledIndicatorView.isHidden = false
            self.isEnabled = false
            self.isAccessibilityElement = false
        case .editing:
            self.setupBorders(color: .botonRedLight, width: 2.0)
            self.font = .santander(family: .text, size: 30.0)
            self.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
            self.disabledIndicatorView.isHidden = true
            self.textColor = .darkTorquoise
            self.isEnabled = true
            self.isAccessibilityElement = true
        case .edited:
            self.setupBorders(color: .mediumSkyGray, width: 1.0)
            self.font = .santander(family: .text, size: 30.0)
            self.backgroundColor = .white
            self.disabledIndicatorView.isHidden = true
            self.textColor = .darkTorquoise
            self.isEnabled = true
            self.isAccessibilityElement = true
        }
    }
}

private extension SignatureTextField {
    
    func setup() {
        self.font = .santander(family: .text, size: 20.0)
        self.borderStyle = .none
        self.isSecureTextEntry = true
        self.textAlignment = .center
        self.tintColor = .lisboaGray
    }
    
    func newBorderLayer(in maskRoundedCorners: CAShapeLayer, color: UIColor, width: CGFloat) -> CAShapeLayer {
        let borderLayer = CAShapeLayer()
        borderLayer.path = maskRoundedCorners.path
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = color.cgColor
        borderLayer.lineWidth = width
        borderLayer.frame = bounds
        return borderLayer
    }
    
    func setupBorders(color: UIColor, width: CGFloat) {
        self.borderLayer?.removeFromSuperlayer()
        switch position {
        case .first:
            let maskRoundedCorners = roundCorners(corners: [.topLeft, .bottomLeft], radius: 5.0)
            let borderLayer = self.newBorderLayer(in: maskRoundedCorners, color: color, width: width)
            self.layer.addSublayer(borderLayer)
            self.borderLayer = borderLayer
        case .last:
            let maskRoundedCorners = roundCorners(corners: [.topRight, .bottomRight], radius: 5.0)
            let borderLayer = self.newBorderLayer(in: maskRoundedCorners, color: color, width: width)
            self.layer.addSublayer(borderLayer)
            self.borderLayer = borderLayer
        case .unknown:
            let maskRoundedCorners = roundCorners(corners: [], radius: 0.0)
            let borderLayer = self.newBorderLayer(in: maskRoundedCorners, color: color, width: width)
            self.layer.addSublayer(borderLayer)
            self.borderLayer = borderLayer
        }
    }
}
