//
//  BottomSheetOtherBanksView.swift
//  Account
//
//  Created by Adrian Arcalá Ocón on 18/3/22.
//

import UI
import UIKit
import UIOneComponents
import CoreFoundationLib
import OpenCombine

enum OtherBanksBottomSheetViewState: State {
    case idle
    case didTapUpdateButton
    case didTapDeleteBank
}

final class OtherBanksBottomSheetView: XibView {
    @IBOutlet private weak var updateBankButton: OneFloatingButton!
    @IBOutlet private weak var deleteBankButton: OneFloatingButton!
    private var eventSubject = PassthroughSubject<OtherBanksBottomSheetViewState, Never>()
    public var publisher: AnyPublisher<OtherBanksBottomSheetViewState, Never> {
        return eventSubject.eraseToAnyPublisher()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    func updateUpdateBankButton(show: Bool) {
        updateBankButton.isHidden = !show
    }
}

private extension OtherBanksBottomSheetView {
    func setupView() {
        setupButtons()
        setAccessibilityIdentifiers()
        setAccessibility(setViewAccessibility: setAccessibilityInfo)
    }
    
    func setupButtons() {
        updateBankButton.configureWith(type: .primary,
                                       size: .medium(OneFloatingButton.ButtonSize.MediumButtonConfig(
                                        title: localized("analysis_button_updatePermissions"),
                                        icons: .right,
                                        fullWidth: true)),
                                       status: .ready)
        updateBankButton.setRightImage(image: "oneIcnUpdate")
        
        deleteBankButton.configureWith(type: .secondary,
                                       size: .medium(OneFloatingButton.ButtonSize.MediumButtonConfig(
                                        title: localized("analysis_button_removeConnection"),
                                        icons: .right,
                                        fullWidth: true)),
                                       status: .ready)
        deleteBankButton.setRightImage(image: "oneIcnCloseOval")
    }
    
    func setAccessibilityIdentifiers() {
        updateBankButton.setAccessibilitySuffix("_\(AnalysisAreaAccessibility.updatePermissionsButton)")
        deleteBankButton.setAccessibilitySuffix("_\(AnalysisAreaAccessibility.removeConnectionButton)")
    }
    
    func setAccessibilityInfo() {
        updateBankButton.accessibilityLabel = localized("analysis_button_updatePermissions")
        deleteBankButton.accessibilityLabel = localized("analysis_button_removeConnection")
    }
    
    @IBAction func didTapUpdatePermissions(_ sender: Any) {
        eventSubject.send(.didTapUpdateButton)
    }
    @IBAction func didTapDeleteBank(_ sender: Any) {
        eventSubject.send(.didTapDeleteBank)
    }
}

extension OtherBanksBottomSheetView: AccessibilityCapable {}
