//
//  BizumConfirmationContactView.swift
//  Bizum
//
//  Created by Cristobal Ramos Laina on 09/12/2020.
//

import UI

final class BizumConfirmationContactView: XibView {
    
    @IBOutlet private weak var avatarContainerView: UIView!
    @IBOutlet private weak var pointLine: PointLine!
    @IBOutlet private weak var avatarLabel: UILabel!
    @IBOutlet private weak var stackView: UIStackView! {
        didSet {
            stackView.axis = .vertical
            stackView.spacing = 0.0
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    convenience init(_ viewModel: ConfirmationContactDetailViewModel) {
        self.init(frame: .zero)
        self.setupView()
        self.setupViewModel(viewModel)
    }
    
    func hidePointLine() {
        self.pointLine.isHidden = true
    }
}

private extension BizumConfirmationContactView {
    func setupView() {
        let cornerRadius = self.avatarContainerView.layer.frame.width / 2
        self.avatarContainerView.drawBorder(cornerRadius: cornerRadius, color: .white, width: 1.0)
        self.avatarContainerView.accessibilityIdentifier = AccessibilityBizumConfirmation.contactView
        self.avatarLabel.setSantanderTextFont(type: .bold, size: 15.0, color: .white)
        self.avatarLabel.accessibilityIdentifier = AccessibilityBizumConfirmation.contactLabel
    }
    
    func setupViewModel(_ viewModel: ConfirmationContactDetailViewModel) {
        self.avatarContainerView.backgroundColor = viewModel.colorModel.color
        self.avatarLabel.text = viewModel.initials
        if let alias = viewModel.alias, !alias.isEmpty {
            let label = UILabel()
            label.setSantanderTextFont(type: .bold, size: 16.0, color: .lisboaGray)
            label.text = alias
            label.accessibilityIdentifier = AccessibilityBizumConfirmation.contactName
            self.stackView.addArrangedSubview(label)
        }
        if let name = viewModel.name, !name.isEmpty {
            let label = UILabel()
            label.setSantanderTextFont(type: .bold, size: 16.0, color: .lisboaGray)
            label.text = "(" + name + ")"
            label.accessibilityIdentifier = AccessibilityBizumConfirmation.contactAlias
            self.stackView.addArrangedSubview(label)
        }
        let phoneLabel = UILabel()
        phoneLabel.setSantanderTextFont(type: .regular, size: 14.0, color: .lisboaGray)
        phoneLabel.text = viewModel.phone.tlfFormatted()
        phoneLabel.accessibilityIdentifier = AccessibilityBizumConfirmation.contactPhone
        self.stackView.addArrangedSubview(phoneLabel)
    }
}
