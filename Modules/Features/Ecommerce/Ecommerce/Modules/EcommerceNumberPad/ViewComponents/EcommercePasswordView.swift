import UIKit
import UI

public protocol EcommercePasswordViewDelegate: class {
    func didPasswordChange(_ newValue: String)
}

private class PasswordDotView: UIView {
    var isFilled: Bool = false {
        didSet {
            setupView()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = isFilled ? UIColor.darkTorquoise : UIColor.skyGray
        layer.borderColor = (isFilled ? UIColor.darkTorquoise : UIColor.coolGray).cgColor
        layer.borderWidth = 2
        layer.cornerRadius = 5
        self.heightAnchor.constraint(equalToConstant: 10).isActive = true
        self.widthAnchor.constraint(equalToConstant: 10).isActive = true
    }
}

public final class EcommercePasswordView: UIStackView {
    private var decryptedValue: String = ""
    var maxPasswordLength: Int = 8
    public weak var delegate: EcommercePasswordViewDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    public required init(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    public func getDecryptedValue() -> String {
        return decryptedValue
    }
    
    public func addCharacter(_ value: String) {
        guard canAddCharacter() else { return }
        self.decryptedValue.append(value)
        self.fillEncryptedElement()
        self.delegate?.didPasswordChange(decryptedValue)
    }
    
    public func removeLastCharacter() {
        removeDecryptedElement()
        removeEncryptedElement()
        delegate?.didPasswordChange(decryptedValue)
    }
    
    public func clear() {
        self.decryptedValue.removeAll()
        self.removeAllEncryptedElements()
        delegate?.didPasswordChange(decryptedValue)
    }
}

private extension EcommercePasswordView {
    func setupView() {
        self.axis = .horizontal
        self.distribution = .fillEqually
        self.alignment = .center
        self.spacing = 10
        self.createDots()
    }
    
    func createDots() {
        for _ in 0 ..< 8 {
            self.addArrangedSubview(PasswordDotView())
        }
    }
    
    func canAddCharacter() -> Bool {
        return decryptedValue.count < maxPasswordLength
    }
    
    func fillEncryptedElement() {
        guard let view = arrangedSubviews.compactMap({ $0 as? PasswordDotView }).first(where: { !$0.isFilled }) else { return }
        view.isFilled = true
    }
    
    func removeDecryptedElement() {
        guard !decryptedValue.isEmpty else { return }
        self.decryptedValue.removeLast()
    }
    
    func removeEncryptedElement() {
        guard let view = arrangedSubviews.compactMap({ $0 as? PasswordDotView }).last(where: { $0.isFilled }) else { return }
        view.isFilled = false
    }
    
    func removeAllEncryptedElements() {
        arrangedSubviews
            .compactMap { $0 as? PasswordDotView }
            .forEach { $0.isFilled = false }
    }
}
