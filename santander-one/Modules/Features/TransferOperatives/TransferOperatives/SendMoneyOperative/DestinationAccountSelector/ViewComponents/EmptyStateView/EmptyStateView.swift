//
//  EmptyStateView.swift
//  TransferOperatives
//
//  Created by Juan Diego Vázquez Moreno on 4/10/21.
//

import UI
import UIOneComponents
import CoreFoundationLib

public protocol EmptyStateViewDelegate: AnyObject {
    func didTapActionButton()
}

public final class EmptyStateView: XibView {
    private enum Constants {
        static let heightNoButton: CGFloat = 176.0
        static let heightWithButton: CGFloat = 221.0
    }
    
    @IBOutlet private weak var backgroundImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private weak var actionButton: OneFloatingButton!
    @IBOutlet private weak var bottomInfoLabelConstraint: NSLayoutConstraint!
    @IBOutlet private weak var backgroundImageHeightConstraint: NSLayoutConstraint!
    
    public weak var delegate: EmptyStateViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
}

public extension EmptyStateView {
    func configure(titleKey: String, infoKey: String, buttonTitleKey: String?) {
        self.titleLabel.text = localized(titleKey)
        self.infoLabel.text = localized(infoKey)
        self.actionButton.configureWith(type: .secondary,
                                        size: .medium(
                                            OneFloatingButton.ButtonSize.MediumButtonConfig(title: buttonTitleKey ?? "",
                                                                                         icons: .none,
                                                                                         fullWidth: true)
                                        ),
                                        status: .ready)
        self.updateLabelVisibility()
        self.titleLabel.accessibilityIdentifier = titleKey
        self.infoLabel.accessibilityIdentifier = infoKey
        self.setAccesibilityInfo()
    }

    func setAccessibilitySuffix(_ suffix: String) {
        self.actionButton.setAccessibilitySuffix(suffix)
    }
}

private extension EmptyStateView {
    func setupView() {
        self.isUserInteractionEnabled = true
        self.configureImageViews()
        self.configureLabels()
        self.configureActionButton()
    }

    func configureImageViews() {
        self.backgroundImageView.setLeavesLoader()
        self.backgroundImageView.isUserInteractionEnabled = true
    }

    func configureLabels() {
        self.titleLabel.font = .typography(fontName: .oneH100Bold)
        self.infoLabel.font = .typography(fontName: .oneB400Regular)
        self.titleLabel.textColor = .oneLisboaGray
        self.infoLabel.textColor = .oneLisboaGray
    }
    
    func configureActionButton() {
        self.actionButton.isUserInteractionEnabled = true
        self.actionButton.isEnabled = true
        self.actionButton.addTarget(self, action: #selector(didSelectAction), for: .touchUpInside)
    }

    func updateLabelVisibility() {
        self.titleLabel.isHidden = (self.titleLabel.text?.isEmpty ?? true)
        self.infoLabel.isHidden = (self.infoLabel.text?.isEmpty ?? true)
        self.actionButton.isHidden = (self.actionButton.getTitle()?.isEmpty ?? true)
        if actionButton.isHidden {
            self.actionButton.removeFromSuperview()
            self.bottomInfoLabelConstraint.isActive = true
            self.backgroundImageHeightConstraint.constant = Constants.heightNoButton
        } else {
            self.backgroundImageHeightConstraint.constant = Constants.heightWithButton
        }
    }

    @objc func didSelectAction() {
        self.delegate?.didTapActionButton()
    }
    
    func setAccesibilityInfo() {
        self.setAccessibility {
            self.backgroundImageView?.isAccessibilityElement = true
            self.titleLabel.isAccessibilityElement = false
            self.infoLabel.isAccessibilityElement = false
            self.backgroundImageView?.accessibilityLabel = "\(self.titleLabel.text ?? ""). \(self.infoLabel.text ?? "")"
        }
    }
}

extension EmptyStateView: AccessibilityCapable {}
