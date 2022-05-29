//
//  AccessPasswordView.swift
//  RetailClean
//
//  Created by Juan Carlos López Robles on 9/27/19.
//  Copyright © 2019 Ciber. All rights reserved.
//

import UIKit

public protocol AccessPasswordViewDelegate: AnyObject {
    func didPasswordChange(_ newValue: String)
}

public final class AccessPasswordView: UIStackView {
    private var decryptedValue: String = ""
    private let encrypteCharacter: String = "\u{2022}"
    var maxPasswordLength: Int = 8
    weak var delegate: AccessPasswordViewDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    public required init(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func setupView() {
        self.axis = .horizontal
        self.distribution = .fillProportionally
        self.alignment = .center
        self.spacing = 4.0
    }
    
    func getDecryptedValue() -> String {
        return decryptedValue
    }
    
    func addCharacter(_ value: String) {
        guard canAddCharacter() else { return }
        self.decryptedValue.append(value)
        self.addEncryptedElement()
        self.delegate?.didPasswordChange(decryptedValue)
    }
    
    func canAddCharacter() -> Bool {
        guard decryptedValue.count < maxPasswordLength else {
            return false
        }
        return true
    }
    
    func addEncryptedElement() {
        let element = makeEncryptedElement()
        self.addArrangedSubview(element)
    }
    
    func makeEncryptedElement() -> UIView {
        let label = UILabel()
        label.text = encrypteCharacter
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 30)
        return label
    }
    
    func removeLastCharacter() {
        removeDepcryptedElement()
        removeEncryptedElement()
        delegate?.didPasswordChange(decryptedValue)
    }
    
    func removeDepcryptedElement() {
        if !decryptedValue.isEmpty {
            self.decryptedValue.removeLast()
        }
    }
    
    func removeEncryptedElement() {
        if let element = self.arrangedSubviews.last {
            element.removeFromSuperview()
        }
    }
    
    func clear() {
        self.decryptedValue.removeAll()
        self.safelyRemoveArrangedSubviews()
        delegate?.didPasswordChange(decryptedValue)
    }
    
    func requireUserAtencion() {
        Animations.requireUserAtencion(on: self)
    }
    
    private func safelyRemoveArrangedSubviews() {
        let removedSubviews: [UIView] = arrangedSubviews.reduce([]) { sum, next in
            self.removeArrangedSubview(next)
            return sum + [next]
        }
        NSLayoutConstraint.deactivate(removedSubviews.flatMap({ $0.constraints }))
        removedSubviews.forEach({ $0.removeFromSuperview() })
    }
}
