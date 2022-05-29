//
//  SecurityAreaActionView.swift
//  PersonalArea
//
//  Created by Carlos Monfort Gómez on 20/01/2020.
//

import CoreFoundationLib
import UIKit
import UI

protocol SecurityActionProtocol: AnyObject {
    func didSelectAction(_ action: SecurityActionType)
}

final class SecurityAreaActionView: XibView {
    // MARK: - IBOutlets
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var currentValueLabel: UILabel!
    @IBOutlet private weak var arrowImageView: UIImageView!
    @IBOutlet private weak var separatorView: DottedLineView!
    @IBOutlet private weak var tooltipButton: UIButton!
    @IBOutlet private weak var tooltipImageView: UIImageView!
    @IBOutlet private weak var contentView: UIView!
    
    // MARK: - Variables
    weak var delegate: SecurityActionProtocol?
    var viewModel: SecurityActionViewModel?
    private var externalAction: ExternalAction?
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureView()
    }
    
    func setViewModel(_ viewModel: SecurityActionViewModel) {
        self.viewModel = viewModel
        self.nameLabel.configureText(withKey: viewModel.nameKey)
        self.setNewValue(viewModel.value)
        self.currentValueLabel.isHidden = self.currentValueLabel.text?.isEmpty ?? true
        if viewModel.tooltipMessage != nil {
            self.tooltipImageView.isHidden = false
            self.tooltipButton.isHidden = false
            self.tooltipButton.backgroundColor = UIColor.clear
        }
        self.setAccessibilityIdentifiers(viewModel)
        if viewModel.action == .noAction {
            self.arrowImageView.removeFromSuperview()
        }
        self.externalAction = viewModel.externalAction
    }
    
    public func setNewValue(_ value: String?) {
        if let newValue = value {
            self.currentValueLabel.text = newValue
        }
        self.currentValueLabel.isHidden = self.currentValueLabel.text?.isEmpty ?? true
    }
}

private extension SecurityAreaActionView {
    // MARK: - Setup
    func configureView() {
        self.nameLabel.font = UIFont.santander(family: .text, type: .regular, size: 16.0)
        self.nameLabel.textColor = UIColor.lisboaGray
        self.currentValueLabel.font = UIFont.santander(family: .text, type: .regular, size: 16.0)
        self.currentValueLabel.textColor = UIColor.darkTorquoise
        self.tooltipImageView.contentMode = .scaleAspectFit
        self.tooltipImageView.isHidden = true
        self.tooltipImageView.image = Assets.image(named: "icnInfoSmall")
        self.tooltipButton.isHidden = true
        self.tooltipButton.addTarget(self, action: #selector(self.showTooltip), for: .touchDown)
        self.separatorView.backgroundColor = UIColor.clear
        self.separatorView.strokeColor = UIColor.mediumSkyGray
        self.contentView.isUserInteractionEnabled = true
        self.arrowImageView.image = Assets.image(named: "icnArrowRight")
        self.addAction()
    }
    
    func addAction() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapOnView))
        self.contentView.addGestureRecognizer(gesture)
    }
    
    @objc func didTapOnView() {
        guard let viewModel = self.viewModel else { return }
        if viewModel.externalAction != nil {
            self.externalAction?()
        } else if let action = viewModel.action {
            self.delegate?.didSelectAction(action)
        }
    }
    
    @objc func showTooltip() {
        guard let infoText = self.viewModel?.tooltipMessage else { return }
        BubbleLabelView.startWith(associated: self.tooltipImageView, text: infoText, position: .automatic)
    }
    
    func setAccessibilityIdentifiers(_ viewModel: SecurityActionViewModel) {
        self.accessibilityIdentifier = viewModel.accessibilityIdentifiers[.container]
        self.nameLabel.accessibilityIdentifier = viewModel.nameKey
        self.tooltipButton.accessibilityIdentifier = viewModel.accessibilityIdentifiers[.tooltip]
        self.contentView.accessibilityIdentifier = viewModel.accessibilityIdentifiers[.action]
        self.arrowImageView.accessibilityIdentifier = viewModel.accessibilityIdentifiers[.chevron] ?? AccessibilitySecuritySectionPersonalArea.icnArrowRight
        self.currentValueLabel.accessibilityIdentifier = viewModel.accessibilityIdentifiers[.value]
    }
}
