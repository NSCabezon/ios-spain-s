//
//  OneInputCodeTextFieldView.swift
//  UIOneComponents
//
//  Created by Angel Abad Perez on 25/2/22.
//

import UI
import CoreGraphics

protocol OneInputCodeTextFieldDelegate: UITextFieldDelegate {
    func didDelete(_ textField: OneInputCodeTextField, goToPrevious: Bool)
}

final class OneInputCodeTextField: UITextField {
    private enum Constants {
        static let visibleTintColor: UIColor = .oneLisboaGray
        static let hiddenTintColor: UIColor = .oneDarkTurquoise
        enum Fonts {
            static let visible: UIFont = .typography(fontName: .oneH500Regular)
            static let hidden: UIFont = UIFont.systemFont(ofSize: 30)
        }
        enum Constraints {
            static let padding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            static let cursorSize: CGSize = CGSize(width: 1.0, height: 17.0)
        }
        enum DisabledView {
            static let backgroundColor: UIColor = .oneBrownishGray
            enum Constraints {
                static let cornerRadius: CGFloat = 2.0
                static let size: CGSize = CGSize(width: 12.0, height: 12.0)
            }
        }
    }
    
    weak var inputCodeDelegate: OneInputCodeTextFieldDelegate?
    private lazy var disabledView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = Constants.DisabledView.Constraints.cornerRadius
        view.backgroundColor = Constants.DisabledView.backgroundColor
        view.heightAnchor.constraint(equalToConstant: Constants.DisabledView.Constraints.size.height).isActive = true
        view.widthAnchor.constraint(equalToConstant: Constants.DisabledView.Constraints.size.width).isActive = true
        self.addSubview(view)
        view.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        return view
    }()
    override var isEnabled: Bool {
        didSet {
            self.disabledView.isHidden = isEnabled
        }
    }
    override var isSecureTextEntry: Bool {
        didSet {
            self.font = isSecureTextEntry ? Constants.Fonts.hidden : Constants.Fonts.visible
            self.textColor = isSecureTextEntry ? Constants.hiddenTintColor : Constants.visibleTintColor
        }
    }
    
    init(delegate: OneInputCodeTextFieldDelegate?) {
        super.init(frame: .zero)
        self.inputCodeDelegate = delegate
        self.delegate = delegate
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }
        
    override func deleteBackward() {
        super.deleteBackward()
        self.inputCodeDelegate?.didDelete(self, goToPrevious: self.text?.isEmpty ?? true)
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
        rect.size.height = Constants.Constraints.cursorSize.height
        rect.size.width = Constants.Constraints.cursorSize.width
        rect.origin.y = (self.frame.height - rect.size.height) / 2
        return rect
    }
}

private extension OneInputCodeTextField {
    func setupView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.borderStyle = .none
        self.textAlignment = .center
        self.tintColor = Constants.visibleTintColor
    }
}
