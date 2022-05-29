//
//  InputCodeTextField.swift
//  UI
//
//  Created by Angel Abad Perez on 20/12/21.
//

import UIKit

protocol InputCodeTextFieldDelegate: UITextFieldDelegate {
    func didDeleteTextField(_ textField: InputCodeTextField, goToPrevious: Bool)
}

class InputCodeTextField: UITextField {
    private enum Constants {
        static let enabledBackgroundColor = UIColor(white: 1.0, alpha: 0.35)
        enum Constraints {
            static let padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        enum DisabledView {
            static let backgroundColor: UIColor = UIColor(red: 114.0 / 255.0, green: 114.0 / 255.0, blue: 114.0 / 255.0, alpha: 1.0)
            enum Constraints {
                static let cornerRadius: CGFloat = 2.0
                static let width: CGFloat = 12.0
                static let height: CGFloat = 12.0
            }
        }
        enum Cursor {
            static let width: CGFloat = 1.0
        }
    }

    private let isSecureEntry: Bool
    private let cursorTintColor: UIColor
    private let selectedFont: UIFont
    private let cursorHeight: CGFloat?
    override var isEnabled: Bool {
        didSet {
            self.disabledIndicatorView.isHidden = isEnabled
            self.backgroundColor = isEnabled ? Constants.enabledBackgroundColor : UIColor.clear
        }
    }
    weak var inputCodeDelegate: InputCodeTextFieldDelegate?
    private lazy var disabledIndicatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = Constants.DisabledView.Constraints.cornerRadius
        view.backgroundColor = Constants.DisabledView.backgroundColor
        view.heightAnchor.constraint(equalToConstant: Constants.DisabledView.Constraints.height).isActive = true
        view.widthAnchor.constraint(equalToConstant: Constants.DisabledView.Constraints.width).isActive = true
        self.addSubview(view)
        view.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        return view
    }()

    init(delegate: InputCodeTextFieldDelegate?,
         font: UIFont,
         isSecureEntry: Bool = true,
         cursorTintColor: UIColor,
         cursorHeight: CGFloat? = nil,
         textColor: UIColor) {
        self.inputCodeDelegate = delegate
        self.isSecureEntry = isSecureEntry
        self.cursorTintColor = cursorTintColor
        self.cursorHeight = cursorHeight
        self.selectedFont = font
        super.init(frame: .zero)
        self.textColor = textColor
        self.delegate = delegate
        self.translatesAutoresizingMaskIntoConstraints = false
        self.configureView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func deleteBackward() {
        let wasEmpty = self.text == ""
        super.deleteBackward()
        self.inputCodeDelegate?.didDeleteTextField(self, goToPrevious: wasEmpty)
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: Constants.Constraints.padding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: Constants.Constraints.padding)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: Constants.Constraints.padding)
    }

    override func caretRect(for position: UITextPosition) -> CGRect {
        var rect = super.caretRect(for: position)
        rect.size.height = self.cursorHeight ?? self.selectedFont.lineHeight
        rect.size.width = Constants.Cursor.width
        rect.origin.y = (self.frame.height - rect.size.height) / 2
        return rect
    }
}

private extension InputCodeTextField {
    func configureView() {
        self.borderStyle = .none
        self.isSecureTextEntry = self.isSecureEntry
        self.textAlignment = .center
        self.font = self.selectedFont
        self.tintColor = self.cursorTintColor
    }
}
