import UIKit
import UI

protocol SecureTextFieldProtocol: class {
    func toggleSeePassword(isShowPass: Bool)
}

class SecureTextField: KeyboardTextField {
    var actionClosure: ((Bool) -> Void)?
    
    override var isSecureTextEntry: Bool {
        didSet {
            updateIconMode()
        }
    }
    
    //The input clears because iOS does it here by default when isSecureTextEntry is true
    override func becomeFirstResponder() -> Bool {
        let success = super.becomeFirstResponder()
        if isSecureTextEntry, let text = self.text {
            self.text?.removeAll(keepingCapacity: true)
            self.text = text
        }
        return success
    }
    
    lazy var modeButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(toggleMode), for: .touchUpInside)
        return button
    }()
    
    private var formatHandler = SecureTextFieldDelegate()
    
    var characterSet: CharacterSet? {
        didSet {
            guard let newCharacterSet = characterSet else { return }
            formatHandler.characterSet = newCharacterSet
        }
    }
    
    var padType: UIKeyboardType? {
        didSet {
            guard let newKeyboardType = padType else { return }
            keyboardType = newKeyboardType
        }
    }
    
    var maxLength: Int? {
        didSet {
            formatHandler.maxLength = maxLength
        }
    }
    
    var customDelegate: ChangeTextFieldDelegate? {
        get {
            return formatHandler.customDelegate
        }
        set {
            formatHandler.customDelegate = newValue
        }
    }
    
    override var delegate: UITextFieldDelegate? {
        get {
            return formatHandler.delegate
        }
        set {
            formatHandler.delegate = newValue
            if let customDelegate = newValue as? ChangeTextFieldDelegate {
                formatHandler.customDelegate = customDelegate
            }
            super.delegate = formatHandler
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        isSecureTextEntry = true
        if #available(iOS 11, *) {
            textContentType = .password
        }
        autocapitalizationType = .none
        autocorrectionType = .no
        spellCheckingType = .no
        rightView = modeButton
        rightViewMode = .whileEditing
    }
    
    @objc func toggleMode() {
        isSecureTextEntry = !isSecureTextEntry
        actionClosure?(isSecureTextEntry)
    }
    
    private func updateIconMode() {
        let image: UIImage?
        if isSecureTextEntry == true {
            image = Assets.image(named: "icnOpenedEye")
        } else {
            image = Assets.image(named: "icnClosedEye")
        }
        modeButton.setImage(image, for: .normal)
        modeButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
        modeButton.sizeToFit()
    }
    
}

class SecureTextFieldDelegate: FormattedCustomTextField {

    override func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        let result = delegate?.textFieldShouldEndEditing?(textField) ?? true
        if result {
            textField.isSecureTextEntry = true
        }
        return result
    }
    
}
