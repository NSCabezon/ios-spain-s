//
//  PromptAnalysisAreaBottomSheetView.swift
//  Menu
//
//  Created by Miguel Ferrer Fornali on 23/3/22.
//

import UI
import UIKit
import UIOneComponents
import CoreFoundationLib
import OpenCombine

final class PromptAnalysisAreaBottomSheetView: XibView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var acceptButton: OneFloatingButton!
    private var acceptSubject = PassthroughSubject<Void, Never>()
    public var publisher: AnyPublisher<Void, Never> {
        return acceptSubject.eraseToAnyPublisher()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func setTitle(titleKey: String, subtitleKey: String) {
        titleLabel.text = localized(titleKey)
        subtitleLabel.text = localized(subtitleKey)
    }
    
    func enableButton(_ isEnable: Bool) {
        acceptButton.isHidden = isEnable.isFalse
        layoutIfNeeded()
    }
}

private extension PromptAnalysisAreaBottomSheetView {
    func setupView() {
        setupLabels()
        setupButton()
        setAccessibilityIdentifiers()
        setAccessibility(setViewAccessibility: setAccessibilityInfo)
    }
    
    func setupLabels() {
        titleLabel.text = localized("analysis_title_activatedProduct")
        titleLabel.font = .typography(fontName: .oneH300Bold)
        titleLabel.textColor = .oneLisboaGray
        subtitleLabel.text = localized("analysis_text_activatedProduct")
        subtitleLabel.font = .typography(fontName: .oneB400Regular)
        subtitleLabel.textColor = .oneLisboaGray
    }
    
    func setupButton() {
        acceptButton.configureWith(type: .primary,
                                   size: .medium(OneFloatingButton.ButtonSize.MediumButtonConfig(title: localized("generic_button_accept"), icons: .none, fullWidth: false)),
                                   status: .ready)
    }
    
    func setAccessibilityIdentifiers() {
        titleLabel.accessibilityIdentifier = AnalysisAreaAccessibility.analysisTitleActivatedProduct
        subtitleLabel.accessibilityIdentifier = AnalysisAreaAccessibility.analysisTextActivatedProduct
        acceptButton.setAccessibilitySuffix("_\(AnalysisAreaAccessibility.btnGenericAccept)")
    }
    
    func setAccessibilityInfo() {
        acceptButton.accessibilityLabel = localized("generic_button_accept")
    }
    
    @IBAction func didTapAcceptButton(_ sender: Any) {
        acceptSubject.send()
    }
}

extension PromptAnalysisAreaBottomSheetView: AccessibilityCapable {}
