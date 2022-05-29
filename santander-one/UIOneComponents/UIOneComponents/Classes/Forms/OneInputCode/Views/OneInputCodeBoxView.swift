//
//  OneInputCodeBoxView.swift
//  UIOneComponents
//
//  Created by Angel Abad Perez on 25/2/22.
//

import CoreGraphics
import UIKit
import CoreFoundationLib

protocol OneInputCodeBoxViewDelegate: AnyObject {
    func codeBoxViewShouldChangeString (_ codeBoxView: OneInputCodeBoxView, replacementString string: String) -> Bool
    func codeBoxViewDidBeginEditing (_ codeBoxView: OneInputCodeBoxView)
    func codeBoxViewDidEndEditing (_ codeBoxView: OneInputCodeBoxView)
    func codeBoxViewDidDelete (_ codeBoxView: OneInputCodeBoxView, goToPrevious: Bool)
}

final class OneInputCodeBoxView: UIView {
    enum Constants {
        static let cornerRadius: CGFloat = 8.0
        static let spacing: CGFloat = .zero
        static let size: CGSize = CGSize(width: 43.0, height: 48.0)
        static let selectedBackground: UIColor = UIColor.oneTurquoise.withAlphaComponent(0.07)
        static let deselectedBackground: UIColor = .clear
    }
    weak var delegate: OneInputCodeBoxViewDelegate?
    var requested: Bool {
        return self.viewModel?.requested ?? false
    }
    var position: Int {
        return self.viewModel?.position ?? .zero
    }
    var isEmpty: Bool {
        return self.text?.isEmpty ?? true
    }
    var text: String? {
        get {
            return self.codeTextField.text
        }
        set {
            self.codeTextField.text = newValue
        }
    }
    var isSecureText: Bool {
        get {
            return self.codeTextField.isSecureTextEntry
        }
        set {
            self.codeTextField.isSecureTextEntry = newValue
        }
    }
    var status: OneInputCodeBoxViewStatus = .deselected {
        didSet {
            self.setNeedsLayout()
        }
    }
    var keyboardType: UIKeyboardType {
        get {
            return self.codeTextField.keyboardType
        }
        set {
            self.codeTextField.keyboardType = newValue
        }
    }
    private lazy var codeTextField: OneInputCodeTextField = {
        return OneInputCodeTextField(delegate: self)
    }()
    private var viewModel: OneInputCodeBoxViewModel? {
        didSet {
            self.codeTextField.isEnabled = viewModel?.requested ?? false
            self.isSecureText = viewModel?.hidden ?? false
            self.setNeedsDisplay()
        }
    }
    
    public init(with viewModel: OneInputCodeBoxViewModel, delegate: OneInputCodeBoxViewDelegate?) {
        super.init(frame: .zero)
        self.setViewModel(viewModel)
        self.delegate = delegate
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    override func becomeFirstResponder() -> Bool {
        self.status = .selected
        return self.codeTextField.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        self.status = .deselected
        return self.codeTextField.resignFirstResponder()
    }
    
    override var isFirstResponder: Bool {
        return self.codeTextField.isFirstResponder
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.codeTextField.backgroundColor = self.isFirstResponder ? Constants.selectedBackground : Constants.deselectedBackground
        if let roundedCorners = self.getRoundedCorners() {
            self.roundCorners(corners: roundedCorners, radius: Constants.cornerRadius)
            self.clipsToBounds = true
        }
        OneInputCodeBoxViewBorderBuilder.configureBorder(for: self, position: self.getPosition(), status: self.status)
    }
    
    func setViewModel(_ viewModel: OneInputCodeBoxViewModel) {
        self.viewModel = viewModel
    }
}

private extension OneInputCodeBoxView {
    func setupView() {
        self.addSubviews()
        self.configureSubviews()
        self.configureConstraints()
        self.setAccessibilityIdentifiers()
    }
    
    func addSubviews() {
        self.clipsToBounds = true
        self.addSubview(self.codeTextField)
    }
    
    func configureSubviews() {
        self.codeTextField.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configureConstraints() {
        let widthConstraint = self.codeTextField.widthAnchor.constraint(equalToConstant: Constants.size.width)
        widthConstraint.priority = .defaultHigh
        NSLayoutConstraint.activate([
            widthConstraint,
            self.codeTextField.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.codeTextField.topAnchor.constraint(equalTo: self.topAnchor),
            self.codeTextField.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.codeTextField.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    func setAccessibilityIdentifiers(_ suffix: String = "") {
        self.accessibilityIdentifier = AccessibilityOneComponents.oneInputCodePosition + String(self.position + 1) +  suffix
    }
    
    func getRoundedCorners() -> UIRectCorner? {
        switch self.getPosition() {
        case .first:
            return [.topLeft, .bottomLeft]
        case .last:
            return [.topRight, .bottomRight]
        case .middle:
            return nil
        }
    }
    
    func getPosition() -> OneInputCodeBoxViewPosition {
        guard let viewModel = self.viewModel else { return .first }
        switch viewModel.position {
        case .zero: return .first
        case viewModel.itemsCount - 1: return .last
        default: return .middle
        }
    }
}

extension OneInputCodeBoxView: OneInputCodeTextFieldDelegate {
    func didDelete(_ textField: OneInputCodeTextField, goToPrevious: Bool) {
        self.delegate?.codeBoxViewDidDelete(self, goToPrevious: goToPrevious)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.delegate?.codeBoxViewDidBeginEditing(self)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.delegate?.codeBoxViewDidEndEditing(self)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return self.delegate?.codeBoxViewShouldChangeString(self, replacementString: string) ?? false
    }
}
