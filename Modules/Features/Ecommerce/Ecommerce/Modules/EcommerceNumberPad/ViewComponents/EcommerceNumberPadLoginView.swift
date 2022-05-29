import CoreFoundationLib
import UIKit
import UI

public protocol EcommerceNumberPadLoginViewDelegate: class {
    func didTapOnOK(withMagic magic: String)
}

public final class EcommerceNumberPadLoginView: XibView {
    private var minPasswordLength: Int = 4
    private var maxPasswordLength: Int = 8
    @IBOutlet private weak var passwordView: EcommercePasswordView!
    @IBOutlet private weak var numberPad: NumberPadView!
    public weak var delegate: EcommerceNumberPadLoginViewDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    public func autocompletePasswordWith(_ password: String?) {
        password?.forEach { self.passwordView.addCharacter("\($0)") }
    }
    
    public func clear() {
        self.passwordView.clear()
    }
}

extension EcommerceNumberPadLoginView: NumberPadViewDelegate {
    public func didTapOnNumber(number: Int) {
        passwordView.addCharacter("\(number)")
    }
    
    public func didTapOnErase() {
        passwordView.removeLastCharacter()
    }
    
    public func didTapOnOK() {
        let magic = passwordView.getDecryptedValue()
        delegate?.didTapOnOK(withMagic: magic)
    }
}

extension EcommerceNumberPadLoginView: EcommercePasswordViewDelegate {
    public func didPasswordChange(_ newValue: String) {
        if newValue.isEmpty {
            numberPad.hideEraseButton()
            numberPad.hideOkButton()
        } else if newValue.count < minPasswordLength {
            numberPad.showEraseButton()
            numberPad.hideOkButton()
        } else if newValue.count >= minPasswordLength {
            numberPad.showEraseButton()
            numberPad.showOkButton()
        }
    }
}

private extension EcommerceNumberPadLoginView {
    func setupView() {
        numberPad.delegate = self
        passwordView.maxPasswordLength = self.maxPasswordLength
        passwordView.delegate = self
        view?.backgroundColor = .skyGray
        numberPad.setStyle(.ecommerce)
    }
}
