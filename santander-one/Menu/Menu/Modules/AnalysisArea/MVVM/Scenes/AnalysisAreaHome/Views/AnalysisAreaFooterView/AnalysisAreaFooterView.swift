//
//  AnalysisAreaFooterViewView.swift
//  Pods
//
//  Created by Jose Javier Montes Romero on 19/1/22.
//  

import UI
import Foundation
import OpenCombine
import UIOneComponents
import CoreFoundationLib

enum AnalysisAreaFooterViewState: State {
    case didTapConfigurationButton
    case didTapAddNewBankButton
}

final class AnalysisAreaFooterView: XibView {
    
    @IBOutlet weak var contentView: OneGradientView!
    @IBOutlet private weak var configurationView: UIStackView!
    @IBOutlet private weak var configurationLabel: UILabel!
    @IBOutlet private weak var configurationImage: UIImageView!
    @IBOutlet private weak var addBankView: UIStackView!
    @IBOutlet private weak var addBankLabel: UILabel!
    @IBOutlet private weak var addNewBankImage: UIImageView!
    private var subject = PassthroughSubject<AnalysisAreaFooterViewState, Never>()
    public var publisher: AnyPublisher<AnalysisAreaFooterViewState, Never> {
        return subject.eraseToAnyPublisher()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupUI()
    }
    
    func updateAddOtherBanks(show: Bool) {
        addBankView.isHidden = !show
    }
    
    @IBAction func didTapConfiguration(_ sender: Any) {
        subject.send(.didTapConfigurationButton)
    }
    
    @IBAction func didTapAddBank(_ sender: Any) {
        subject.send(.didTapAddNewBankButton)
    }
}

private extension AnalysisAreaFooterView {
    
    func setupUI() {
        contentView.setupType(.oneGrayGradient(direction: .topToBottom))
        configureView()
        setAccessibility(setViewAccessibility: self.setAccessibilityInfo)
        setAccessibilityInfo()
        setAccessibilityIdentifiers()
    }
    
    func configureView() {
        configurationLabel.text = localized("analysis_button_settings")
        configurationLabel.textColor = .oneDarkTurquoise
        configurationLabel.scaledFont = .typography(fontName: .oneB300Bold)
        addBankLabel.text = localized("analysis_button_addOtherBanks")
        addBankLabel.scaledFont = .typography(fontName: .oneB300Bold)
        addBankLabel.textColor = .oneDarkTurquoise
        configurationImage.image = Assets.image(named: "oneIcnSettings")
        addNewBankImage.image = Assets.image(named: "oneIcnAddCurrency")
    }
    
    func setAccessibilityIdentifiers() {
        self.accessibilityIdentifier = AnalysisAreaAccessibility.analysisFooter
        configurationLabel.accessibilityIdentifier = AnalysisAreaAccessibility.btnAnalysisSettings
        configurationImage.accessibilityIdentifier = AnalysisAreaAccessibility.oneIcnSettings
        addBankLabel.accessibilityIdentifier = AnalysisAreaAccessibility.btnAnalysisAddOtherBanks
        addNewBankImage.accessibilityIdentifier = AnalysisAreaAccessibility.oneIcnAddCurrency
        configurationImage.isAccessibilityElement = !UIAccessibility.isVoiceOverRunning
        addNewBankImage.isAccessibilityElement = !UIAccessibility.isVoiceOverRunning
        configurationView.isAccessibilityElement = false
        addBankView.isAccessibilityElement = false
    }
    
    func setAccessibilityInfo() {
        configurationView.isAccessibilityElement = true
        configurationView.accessibilityLabel = localized("analysis_button_settings")
        configurationView.accessibilityTraits = .button
        addBankView.isAccessibilityElement = true
        addBankView.accessibilityLabel = localized("analysis_button_addOtherBanks")
        addBankView.accessibilityTraits = .button
    }
}

extension AnalysisAreaFooterView: AccessibilityCapable {}
