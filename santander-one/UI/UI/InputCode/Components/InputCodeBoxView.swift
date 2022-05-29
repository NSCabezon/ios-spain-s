//
//  InputCodeBoxView.swift
//  UI
//
//  Created by Angel Abad Perez on 20/12/21.
//

import UIKit

protocol InputCodeBoxViewDelegate: AnyObject {
    func codeBoxViewShouldChangeString (_ codeBoxView: InputCodeBoxView, replacementString string: String) -> Bool
    func codeBoxViewDidBeginEditing (_ codeBoxView: InputCodeBoxView)
    func codeBoxViewDidEndEditing (_ codeBoxView: InputCodeBoxView)
    func codeBoxViewDidDelete (_ codeBoxView: InputCodeBoxView, goToPrevious: Bool)
}

public class InputCodeBoxView: UIView {
    private enum Constants {
        static let positionLabelHeight: CGFloat = 24.0
        static let positionLabelFontColor = UIColor.white
        static let positionLabelFont = UIFont.systemFont(ofSize: 14.0)
    }
    
    public enum PositionBox: Int {
        case first
        case middle
        case last
    }

    private lazy var codeTextField: InputCodeTextField = {
        return InputCodeTextField(delegate: self,
                                      font: self.font,
                                      isSecureEntry: self.isSecureEntry,
                                      cursorTintColor: self.cursorTintColor,
                                      cursorHeight: self.cursorHeight,
                                      textColor: self.textColor)
    }()
    private let elementsNumber: NSInteger
    let position: NSInteger
    let showPosition: Bool
    let requested: Bool
    private let isSecureEntry: Bool
    private let size: CGSize
    private let positionLabel = UILabel()
    private let font: UIFont
    private let textColor: UIColor
    private let cursorTintColor: UIColor
    private let cursorHeight: CGFloat?
    private var roundCorners: UIRectCorner?
    private var cornerRadius: CGFloat?
    private let borderColor: UIColor
    private let borderWidth: CGFloat
    private lazy var numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .spellOut
        numberFormatter.locale = Locale(identifier: "en")
        return numberFormatter
    }()
    weak var delegate: InputCodeBoxViewDelegate?
    public var isEmpty: Bool {
        return self.text?.count ?? .zero == .zero
    }

    init(position: NSInteger,
         showPosition: Bool = false,
         elementsNumber: NSInteger,
         delegate: InputCodeBoxViewDelegate? = nil,
         requested: Bool,
         isSecureEntry: Bool = true,
         size: CGSize,
         font: UIFont,
         textColor: UIColor = .white,
         cursorTintColor: UIColor,
         cursorHeight: CGFloat? = nil,
         borderColor: UIColor,
         borderWidth: CGFloat) {
        self.showPosition = showPosition
        self.elementsNumber = elementsNumber
        self.position = position
        self.requested = requested
        self.isSecureEntry = isSecureEntry
        self.size = size
        self.font = font
        self.textColor = textColor
        self.cursorTintColor = cursorTintColor
        self.cursorHeight = cursorHeight
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.delegate = delegate
        self.configureView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @discardableResult public override func becomeFirstResponder() -> Bool {
        return self.codeTextField.becomeFirstResponder()
    }

    @discardableResult public override func resignFirstResponder() -> Bool {
        return self.codeTextField.resignFirstResponder()
    }

    public override var isFirstResponder: Bool {
        return self.codeTextField.isFirstResponder
    }

    func setKeyboardType(_ keyboardType: UIKeyboardType) {
        self.codeTextField.keyboardType = keyboardType
    }

    var text: String? {
        get {
            return self.codeTextField.text
        }
        set {
            self.codeTextField.text = newValue
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        if let corners = self.roundCorners, let radius = self.cornerRadius {
            self.roundCorners(corners: corners, radius: radius)
            self.clipsToBounds = true
        }
        if borderWidth > .zero {
            self.addBorder(width: borderWidth, color: borderColor)
        }
    }

    func configureCorners(corners: UIRectCorner, radius: CGFloat) {
        self.cornerRadius = radius
        self.roundCorners = corners
        self.clipsToBounds = true
        setNeedsDisplay()
    }
    
    public func getPosition() -> PositionBox {
        switch self.position {
        case 1: return .first
        case self.elementsNumber: return .last
        default: return .middle
        }
    }
}

private extension InputCodeBoxView {
    func configureView() {
        self.addSubviews()
        self.configureSubviews()
        self.configureConstraints()
        self.codeTextField.accessibilityIdentifier = "oneInputSignatureView_position" + (numberFormatter.string(from: NSNumber(value: Int(self.position))) ?? "").capitalized
    }

    func addSubviews() {
        self.addSubview(self.codeTextField)
        self.addSubview(self.positionLabel)
    }

    func configureSubviews() {
        self.codeTextField.translatesAutoresizingMaskIntoConstraints = false
        self.codeTextField.isEnabled = self.requested
        self.codeTextField.textColor = self.textColor
        self.positionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.positionLabel.text = String(self.position)
        self.positionLabel.backgroundColor = .clear
        self.positionLabel.textAlignment = .center
        self.positionLabel.textColor = Constants.positionLabelFontColor
    }

    func configureConstraints() {
        let widthConstraint = self.codeTextField.widthAnchor.constraint(equalToConstant: self.size.width)
        widthConstraint.priority = .defaultHigh
        NSLayoutConstraint.activate([
            widthConstraint,
            self.codeTextField.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.codeTextField.topAnchor.constraint(equalTo: self.topAnchor),
            self.codeTextField.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.codeTextField.heightAnchor.constraint(equalToConstant: self.size.height),
            self.positionLabel.topAnchor.constraint(equalTo: self.codeTextField.bottomAnchor),
            self.positionLabel.heightAnchor.constraint(equalToConstant: self.showPosition ? Constants.positionLabelHeight : .zero),
            self.positionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.positionLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.positionLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }

    func addBorder(width: CGFloat, color: UIColor) {
        if let corners = self.roundCorners, let radius = self.cornerRadius {
            let borderPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let borderLayer = CAShapeLayer()
            borderLayer.path = borderPath.cgPath
            borderLayer.lineWidth = width + 1
            borderLayer.strokeColor = color.cgColor
            borderLayer.fillColor = UIColor.clear.cgColor
            borderLayer.frame = self.bounds
            self.layer.addSublayer(borderLayer)
        } else {
            self.layer.borderWidth = width
            self.layer.borderColor = color.cgColor
        }
    }
}

extension InputCodeBoxView: InputCodeTextFieldDelegate {
    func didDeleteTextField(_ textField: InputCodeTextField, goToPrevious: Bool) {
        self.delegate?.codeBoxViewDidDelete(self, goToPrevious: goToPrevious)
    }

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        self.delegate?.codeBoxViewDidBeginEditing(self)
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        self.delegate?.codeBoxViewDidEndEditing(self)
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return self.delegate?.codeBoxViewShouldChangeString(self, replacementString: string) ?? false
    }
}
