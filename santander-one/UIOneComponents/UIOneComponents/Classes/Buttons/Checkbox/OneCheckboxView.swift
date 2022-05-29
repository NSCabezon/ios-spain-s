//
//  CkeckboxView.swift
//  UIOneComponents
//
//  Created by Cristobal Ramos Laina on 15/9/21.
//

import UIKit
import UI
import CoreFoundationLib

public protocol OneCheckboxViewDelegate: AnyObject {
    func didSelectOneCheckbox(_ isSelected: Bool)
}

public final class OneCheckboxView: XibView {
    
    @IBOutlet private weak var ticView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet weak var selectedButton: UIButton!
    public var status: OneStatus = .inactive
    private var isSelected: Bool = false
    public weak var delegate: OneCheckboxViewDelegate?
    private var viewModel: OneCheckboxViewModel?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setAppearance()
    }
    
    public func setViewModel(_ viewModel: OneCheckboxViewModel) {
        self.viewModel = viewModel
        self.titleLabel.text = localized(viewModel.titleKey)
        self.isSelected = viewModel.isSelected
        self.setStatus(viewModel.status)
        self.setAccessibilitySuffix(viewModel.accessibilitySuffix ?? "")
    }
    
    public func setStatus(_ status: OneStatus) {
        self.status = status
        self.setCheckboxByStatus()
    }

    public func setAccessibilitySuffix(_ suffix: String) {
        self.setAccessibilityIdentifiers(suffix)
    }
    
    @IBAction func didTapOnNormalCheckbox(_ sender: Any) {
        self.didTapOnCheckBox()
    }
}

private extension OneCheckboxView {
    func setAppearance() {
        self.ticView.setOneCornerRadius(type: .oneShRadius4)
        self.titleLabel.font = .typography(fontName: .oneB300Regular)
        self.ticView.setOneShadows(type: .oneShadowSmall)
        self.setAccessibilityIdentifiers()
    }
    
    func setCheckboxByStatus() {
        switch self.status {
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
        self.setAccessibility(setViewAccessibility: self.setAccessibilityInfo)
    }
    
    func didTapOnCheckBox() {
        switch self.status {
        case .inactive:
            self.tapChangeStatus(to: .activated)
        case .activated:
            self.tapChangeStatus(to: .inactive)
        case .disabled, .focused, .error:
            break
        }
    }
    
    func tapChangeStatus(to newStatus: OneStatus) {
        self.status = newStatus
        self.setCheckboxByStatus()
        self.delegate?.didSelectOneCheckbox(self.isSelected)
        self.setAccessibility(setViewAccessibility: self.setAccessibilityInfo)
    }
    
    func setInactiveStatus() {
        self.isSelected = false
        self.ticView.backgroundColor = .white
        self.imageView.isHidden = true
        self.ticView.layer.borderColor = UIColor.oneBrownGray.cgColor
        self.ticView.layer.borderWidth = 1
        self.titleLabel.textColor = .oneLisboaGray
    }
    
    func setActivatedStatus() {
        self.isSelected = true
        self.ticView.backgroundColor = .oneDarkTurquoise
        self.imageView.isHidden = false
        self.imageView.image = Assets.image(named: "icnCheckboxTick")
        self.titleLabel.textColor = .oneLisboaGray
    }
    
    func setDisabledStatus() {
        if self.isSelected {
            self.setDisabledSelectedStatus()
        } else {
            self.setDisabledNotSelectedStatus()
        }
    }
    
    func setDisabledNotSelectedStatus() {
        self.isSelected = false
        self.ticView.backgroundColor = .oneLightGray40
        self.imageView.isHidden = true
        self.titleLabel.textColor = .oneBrownishGray
    }
    
    func setDisabledSelectedStatus() {
        self.isSelected = true
        self.ticView.backgroundColor = .oneMediumSkyGray
        self.imageView.isHidden = false
        self.imageView.image = Assets.image(named: "icnCheckboxTickBlack")
        self.titleLabel.textColor = .oneBrownishGray
    }
    
    func setAccessibilityIdentifiers(_ suffix: String? = nil) {
        self.view?.accessibilityIdentifier = AccessibilityOneComponents.oneCheckboxView + (suffix ?? "")
        self.selectedButton.accessibilityIdentifier = AccessibilityOneComponents.oneCheckboxCheckbox + (suffix ?? "")
        self.titleLabel.accessibilityIdentifier = AccessibilityOneComponents.oneCheckBoxTitle + (suffix ?? "")
        self.imageView.accessibilityIdentifier = AccessibilityOneComponents.oneCheckBoxTickImg + (suffix ?? "")
    }
    
    func setAccessibilityInfo() {
        self.titleLabel.isAccessibilityElement = false
        self.selectedButton.accessibilityValue = self.isSelected ? localized("voiceover_selected") : localized("voiceover_unselected")
        self.selectedButton.accessibilityLabel = self.isSelected ? self.viewModel?.accessibilityActivatedLabel : self.viewModel?.accessibilityNoActivatedLabel
    }
}

extension OneCheckboxView: AccessibilityCapable {}
