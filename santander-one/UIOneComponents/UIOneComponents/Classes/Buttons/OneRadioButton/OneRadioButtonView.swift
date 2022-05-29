//
//  OneRadioButtonView.swift
//  UIOneComponents
//
//  Created by Cristobal Ramos Laina on 20/9/21.
//

import UIKit
import UI
import CoreFoundationLib

public protocol OneRadioButtonViewDelegate: AnyObject {
    func didSelectOneRadioButton(_ index: Int)
    func didTapTooltip()
}

public extension OneRadioButtonViewDelegate {
    func didTapTooltip() { }
}

public final class OneRadioButtonView: XibView {
    
    @IBOutlet private weak var radioLargeButton: UIButton!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var tooltipImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var additionalInfoLabel: UILabel!
    @IBOutlet private weak var infoStackView: UIStackView!
    @IBOutlet private weak var tooltipButton: UIButton!
    @IBOutlet private weak var tooltipContainerView: UIView!
    private var viewModel: OneRadioButtonViewModel?
    private var status: OneStatus = .inactive
    public weak var delegate: OneRadioButtonViewDelegate?
    private var isSelected = false
    public var index: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppearance()
    }
    
    public func setViewModel(_ viewModel: OneRadioButtonViewModel, index: Int) {
        self.viewModel = viewModel
        self.index = index
        self.status = viewModel.status
        self.isSelected = viewModel.isSelected
        self.tooltipContainerView.isHidden = viewModel.isTooltipHidden
        self.tooltipButton.isHidden = viewModel.isTooltipHidden
        self.setLabels(viewModel)
        self.setInfoStackView()
        self.setByStatus(viewModel.status)
        self.setAccessibility(setViewAccessibility: self.setAccessibilityInfo)
        self.setAccessibilitySuffix(viewModel.accessibilitySuffix ?? "")
    }

    public func setAccessibilitySuffix(_ suffix: String) {
        self.setAccessibilityIdentifiers(suffix)
    }

    public func getStatus() -> OneStatus {
        return self.status
    }
    
    public func setByStatus(_ status: OneStatus) {
        switch status {
        case .inactive:
            self.setInactiveStatus()
        case .activated:
            self.setActivatedStatus()
        case .disabled:
            self.setDisabledStatus()
        case .focused:
            break
        case .error:
            break
        }
        self.titleLabel.accessibilityValue = self.isSelected ? localized("voiceover_selected") : localized("voiceover_unselected")
    }
    
    public func appendToTitle(string: String) {
        self.titleLabel.text = "\(self.titleLabel.text ?? "") \(string)"
    }
    
    @IBAction private func didTapOnTooltip(_ sender: Any) {
        self.showBottomSheet()
        self.delegate?.didTapTooltip()
    }
}

private extension OneRadioButtonView {
    func setAppearance() {
        self.setLabelsConfiguration()
        self.setTooltipImageView()
        self.setAccessibilityIdentifiers()
    }
    
    func setLabelsConfiguration() {
        self.titleLabel.font = .typography(fontName: .oneH100Bold)
        self.subtitleLabel.font = .typography(fontName: .oneB300Regular)
        self.additionalInfoLabel.font = .typography(fontName: .oneB100Regular)
        self.subtitleLabel.text = nil
        self.additionalInfoLabel.text = nil
    }
    
    func setTooltipImageView() {
        self.tooltipImageView.image = Assets.image(named: "icnHelp")
        self.tooltipContainerView.isHidden = true
        self.tooltipButton.isHidden = true
    }
    
    func setLabels(_ viewModel: OneRadioButtonViewModel) {
        self.titleLabel.text = localized(viewModel.titleKey)
        if let subtitleText = viewModel.subtitleKey {
            self.subtitleLabel.text = localized(subtitleText)
        }
        if let addtionalInfoText = viewModel.additionalInfoKey {
            self.additionalInfoLabel.text = localized(addtionalInfoText)
        }
    }
    
    func setInfoStackView() {
        guard self.subtitleLabel.text == nil && self.additionalInfoLabel.text == nil else { return }
        self.infoStackView.isHidden = true
    }
    
    func setInactiveStatus() {
        self.titleLabel.textColor = .oneLisboaGray
        self.subtitleLabel.textColor = .oneLisboaGray
        self.additionalInfoLabel.textColor = .oneLisboaGray
        self.imageView.image = Assets.image(named: "icnRadioButtonInactive")
        self.isSelected = false
        self.status = .inactive
    }
    
    func setActivatedStatus() {
        self.imageView.image = Assets.image(named: "icnRadioButtonActivated")
        self.titleLabel.textColor = .oneDarkTurquoise
        self.subtitleLabel.textColor = .oneDarkTurquoise
        self.additionalInfoLabel.textColor = .oneLisboaGray
        self.isSelected = true
        self.status = .activated
    }
    
    func setDisabledStatus() {
        self.titleLabel.textColor = .oneBrownishGray
        self.subtitleLabel.textColor = .oneBrownishGray
        self.additionalInfoLabel.textColor = .oneBrownishGray
        self.imageView.image = self.isSelected ? Assets.image(named: "icnRadioButtonDisabledSelected") : Assets.image(named: "icnRadioButtonDisabled")
        self.radioLargeButton.isEnabled = false
    }
    
    @IBAction func didTapOnRadioButton(_ sender: Any) {
        guard self.status == .inactive else { return }
        self.setByStatus(self.isSelected ? .inactive : .activated)
        self.delegate?.didSelectOneRadioButton(self.index)
    }
    
    func showBottomSheet() {
        guard let viewModel = self.viewModel,
              let bottomSheetView = viewModel.bottomSheetView,
              let topController = UIApplication.shared.keyWindow?.rootViewController else { return }
        let bottomSheet = BottomSheet()
        bottomSheet.show(in: topController, type: .custom(isPan: true), component: .all, view: bottomSheetView)
    }
    
    func setAccessibilityIdentifiers(_ suffix: String? = nil) {
        self.radioLargeButton.accessibilityIdentifier = AccessibilityOneComponents.oneRadioButton + (suffix ?? "")
        self.tooltipButton.accessibilityIdentifier = AccessibilityOneComponents.oneRadioButtonHelp + (suffix ?? "")
        self.titleLabel.accessibilityIdentifier = AccessibilityOneComponents.oneRadioButtonTitle + (suffix ?? "")
        self.subtitleLabel.accessibilityIdentifier = AccessibilityOneComponents.oneRadioButtonText + (suffix ?? "")
        self.additionalInfoLabel.accessibilityIdentifier = AccessibilityOneComponents.oneRadioButtonInfo + (suffix ?? "")
        self.imageView.accessibilityIdentifier = AccessibilityOneComponents.oneRadioButtonSelection + (suffix ?? "")
        self.accessibilityElements = [self.radioLargeButton, self.tooltipButton, self.titleLabel, self.subtitleLabel, self.additionalInfoLabel, self.imageView]
    }
    
    func defaultAccessibility() {
        self.radioLargeButton.isAccessibilityElement = false
    }
    
    func setAccessibilityInfo() {
        self.titleLabel.accessibilityLabel = viewModel?.titleAccessibilityLabel
        self.titleLabel.accessibilityTraits = .button
        self.titleLabel.accessibilityValue = self.isSelected ? localized("voiceover_selected") : localized("voiceover_unselected")
        self.tooltipButton.accessibilityLabel = viewModel?.tooltipAccessibilityLabel
        self.accessibilityElements = [self.titleLabel, self.tooltipButton, self.subtitleLabel].compactMap{$0}
    }
}

extension OneRadioButtonView: AccessibilityCapable {}
