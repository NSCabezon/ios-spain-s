//
//  OneLabelView.swift
//  Account
//
//  Created by Angel Abad Perez on 20/9/21.
//

import CoreFoundationLib
import UIKit
import UI

// MARK: - One Label

public final class OneLabelView: XibView {
    
    // MARK: - Constants
    
    private enum Constants {
        static let helperIcon: String = "icnHelp"
    }
    
    // MARK: - IB Outlets
    @IBOutlet private weak var mainTextLabel: UILabel!
    @IBOutlet private weak var helperImageView: UIImageView!
    @IBOutlet private weak var actionButton: UIButton!
    @IBOutlet private weak var actualCounterLabel: UILabel!
    @IBOutlet private weak var maxCounterLabel: UILabel!
    @IBOutlet private weak var separatorCounterLabel: UILabel!
    @IBOutlet private weak var counterLabelsView: UIStackView!
    
    // MARK: - Private vars
    
    private var viewModel: OneLabelViewModel = OneLabelViewModel(type: .normal, mainTextKey: "") {
        didSet {
            self.setLabelTexts()
            self.setAppearance()
            self.setAccessibilitySuffix(viewModel.accessibilitySuffix ?? "")
            self.setAccessibility(setViewAccessibility: self.setAccessibilityInfo)
        }
    }
    
    // MARK: - Init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }
}

// MARK: - Public functions

public extension OneLabelView {
    func setupViewModel(_ viewModel: OneLabelViewModel) {
        self.viewModel = viewModel
        self.setAccessibilitySuffix(viewModel.accessibilitySuffix ?? "")
    }

    func setAccessibilitySuffix(_ suffix: String) {
        self.setAccessibilityIdentifiers(suffix)
    }

    func setActualCounterLabel(_ total: String) {
        self.actualCounterLabel.text = total
    }
    
    func setAccessibilityLabel(accessibilityLabel: String) {
        self.mainTextLabel.accessibilityLabel = accessibilityLabel
    }
}

// MARK: - Private methods

private extension OneLabelView {
    func setupView() {
        self.backgroundColor = .clear
        self.configureLabels()
        self.configureHelperImageView()
        self.configureActionButton()
        self.setAccessibility(setViewAccessibility: self.setAccessibilityInfo)
    }
    
    func configureLabels() {
        self.mainTextLabel.font = .typography(fontName: .oneB300Regular)
        self.mainTextLabel.textColor = .oneLisboaGray
        self.actualCounterLabel.font = .typography(fontName: .oneB200Regular)
        self.actualCounterLabel.textColor = .oneLisboaGray
        self.separatorCounterLabel.font = .typography(fontName: .oneB200Regular)
        self.separatorCounterLabel.textColor = .oneLisboaGray
        self.maxCounterLabel.font = .typography(fontName: .oneB200Regular)
        self.maxCounterLabel.textColor = .oneLisboaGray
    }
    
    func configureHelperImageView() {
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(didSelectHelper))
        self.helperImageView.isUserInteractionEnabled = true
        self.helperImageView.addGestureRecognizer(imageTap)
        self.helperImageView.image = Assets.image(named: Constants.helperIcon)
    }
    
    func configureActionButton() {
        self.actionButton.titleLabel?.font = .typography(fontName: .oneB200Bold)
        self.actionButton.addTarget(self, action: #selector(didSelectAction), for: .touchUpInside)
        self.actionButton.isUserInteractionEnabled = true
    }
    
    func setLabelTexts() {
        self.mainTextLabel.configureText(withKey: self.viewModel.mainTextKey)
        if let actionTextKey = self.viewModel.actionTextKey {
            self.actionButton.setTitle(localized(actionTextKey), for: .normal)
        }
        self.maxCounterLabel.text = self.viewModel.maxCounterLabel
        self.actualCounterLabel.text = self.viewModel.actualCounterLabel
        self.separatorCounterLabel.text = "/"
    }

    func setAppearance() {
        self.hideAllItems()
        self.mainTextLabel.isHidden = false
        switch self.viewModel.type {
        case .helper:
            self.helperImageView.isHidden = false
        case .action:
            self.actionButton.setTitleColor(self.viewModel.action != nil ? .oneDarkTurquoise : .oneLightSanGray, for: .normal)
            self.actionButton.isHidden = false
        case .helperAndAction:
            self.actionButton.setTitleColor(self.viewModel.action != nil ? .oneDarkTurquoise : .oneLightSanGray, for: .normal)
            self.helperImageView.isHidden = false
            self.actionButton.isHidden = false
        case .counter:
            self.actualCounterLabel.isHidden = false
            self.separatorCounterLabel.isHidden = false
            self.maxCounterLabel.isHidden = false
        default:
            break
        }
    }
    
    func hideAllItems() {
        self.mainTextLabel.isHidden = true
        self.helperImageView.isHidden = true
        self.actionButton.isHidden = true
        self.actualCounterLabel.isHidden = true
        self.maxCounterLabel.isHidden = true
        self.separatorCounterLabel.isHidden = true
    }
    
    func setAccessibilityIdentifiers(_ suffix: String? = nil) {
        self.accessibilityIdentifier = AccessibilityOneComponents.oneLabelView + (suffix ?? "")
        self.mainTextLabel.accessibilityIdentifier = AccessibilityOneComponents.oneLabelTitle + (suffix ?? "")
        self.helperImageView.accessibilityIdentifier = AccessibilityOneComponents.oneLabelHelpIcn + (suffix ?? "")
        self.actionButton.accessibilityIdentifier = AccessibilityOneComponents.oneLabelInfoAction + (suffix ?? "")
        self.actualCounterLabel.accessibilityIdentifier = AccessibilityOneComponents.oneLabelInfoCurrentCounter + (suffix ?? "")
        self.separatorCounterLabel.accessibilityIdentifier = AccessibilityOneComponents.oneLabelInfoSeparator + (suffix ?? "")
        self.maxCounterLabel.accessibilityIdentifier = AccessibilityOneComponents.oneLabelInfoMaxCounter + (suffix ?? "")
    }
    
    func setAccessibilityInfo() {
        self.helperImageView.accessibilityLabel = localized("voiceover_helpIcon")
        self.helperImageView.accessibilityTraits = .button
        self.actionButton.accessibilityLabel = self.viewModel.actionTextLabelKey ?? self.viewModel.actionTextKey
        self.actionButton.accessibilityValue = self.actionButton.isEnabled ? nil : "Disabled"
        self.counterLabelsView.isAccessibilityElement = true
        self.counterLabelsView.accessibilityLabel = self.viewModel.counterLabelsAccessibilityText
        self.maxCounterLabel.isAccessibilityElement = false
        self.actualCounterLabel.isAccessibilityElement = false
    }

    @objc func didSelectAction() {
        self.viewModel.action?()
    }
    
    @objc func didSelectHelper() {
        self.viewModel.helperAction?()
    }
}

extension OneLabelView: AccessibilityCapable {}
