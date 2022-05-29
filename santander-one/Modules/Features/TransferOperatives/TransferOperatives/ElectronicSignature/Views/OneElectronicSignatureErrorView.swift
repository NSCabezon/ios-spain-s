//
//  OneElectronicSignatureErrorView.swift
//  TransferOperatives
//
//  Created by Angel Abad Perez on 22/12/21.
//

import UIOneComponents
import UI
import CoreFoundationLib

struct OneElectronicSignatureErrorViewModel {
    let iconName: String
    let titleKey: String
    let subtitleKey: String
    let floatingButtonText: LocalizedStylableText
    let floatingButtonAction: (() -> Void)?
    var gpButtonText: String?
    var gpButtonAction: (() -> Void)?
    let viewAccessibilityIdentifier: String
}

protocol OneElectronicSignatureErrorViewDelegate: AnyObject {
    func didTapFloatingButton(action: (() -> Void)?)
    func didTapGpButton(action: (() -> Void)?)
}

final class OneElectronicSignatureErrorView: XibView {    
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var floatingButton: OneFloatingButton!
    @IBOutlet private weak var gpButton: OneFloatingButton!
    @IBOutlet private weak var labelConstraint: NSLayoutConstraint!
    
    weak var delegate: OneElectronicSignatureErrorViewDelegate?
    private var floatingButtonAction: (() -> Void)?
    private var gpButtonAction: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setViewModel(_ viewModel: OneElectronicSignatureErrorViewModel) {
        self.setIconImage(iconName: viewModel.iconName)
        self.setLabelsText(viewModel)
        self.setFloatingButtonTitle(title: viewModel.floatingButtonText)
        self.floatingButtonAction = viewModel.floatingButtonAction
        if let text = viewModel.gpButtonText,
           let action = viewModel.gpButtonAction {
            self.setGpButtonTitle(title: text)
            self.gpButtonAction = action
        } else {
            self.labelConstraint.constant = 96
            self.gpButton.removeFromSuperview()
        }
        self.setAccessibilityIdentifiers(viewModel)
    }
}

private extension OneElectronicSignatureErrorView {
    func setupView() {
        self.configureLabels()
        self.configureButtons()
    }
    
    func configureLabels() {
        self.titleLabel.font = .typography(fontName: .oneH300Bold)
        self.titleLabel.textColor = .oneLisboaGray
        self.subtitleLabel.font = .typography(fontName: .oneB400Regular)
        self.subtitleLabel.textColor = .oneLisboaGray
    }
    
    func configureButtons() {
        self.floatingButton.isEnabled = true
        self.floatingButton.addTarget(self, action: #selector(didTapFloatingButton), for: .touchUpInside)
        self.gpButton.addTarget(self, action: #selector(didTapGpButton), for: .touchUpInside)
    }
    
    func setLabelsText(_ viewModel: OneElectronicSignatureErrorViewModel) {
        self.titleLabel.text = localized(viewModel.titleKey)
        self.subtitleLabel.text = localized(viewModel.subtitleKey)
    }
    
    func setIconImage(iconName: String) {
        self.iconImageView.image = Assets.image(named: iconName)?.withRenderingMode(.alwaysTemplate)
        self.iconImageView.tintColor = .oneBlack
    }
    
    func setFloatingButtonTitle(title: LocalizedStylableText) {
        self.floatingButton.configureWith(type: .primary,
                                          size: .medium(
                                            OneFloatingButton.ButtonSize.MediumButtonConfig(
                                                title: title.text,
                                                icons: .none,
                                                fullWidth: false
                                            )
                                          ),
                                          status: .ready)
    }
    
    func setGpButtonTitle(title: String) {
        self.gpButton.configureWith(type: .secondary,
                                          size: .medium(
                                            OneFloatingButton.ButtonSize.MediumButtonConfig(
                                                title: title,
                                                icons: .none,
                                                fullWidth: false
                                            )
                                          ),
                                          status: .ready)
    }
    
    func setAccessibilityIdentifiers(_ viewModel: OneElectronicSignatureErrorViewModel) {
        self.view?.accessibilityIdentifier = viewModel.viewAccessibilityIdentifier
        self.iconImageView.accessibilityIdentifier = viewModel.iconName
        self.titleLabel.accessibilityIdentifier = viewModel.titleKey
        self.subtitleLabel.accessibilityIdentifier = viewModel.subtitleKey
    }
    
    @objc func didTapFloatingButton() {
        self.delegate?.didTapFloatingButton(action: self.floatingButtonAction)
    }
    
    @objc func didTapGpButton() {
        self.delegate?.didTapGpButton(action: self.gpButtonAction)
    }
}

