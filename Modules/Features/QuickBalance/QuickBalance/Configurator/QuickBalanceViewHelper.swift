//
//  QuickBalanceViewProtocol.swift
//  QuickBalance
//
//  Created by Rubén Márquez Fernández on 23/4/21.
//

import CoreFoundationLib
import UI

class QuickBalanceViewHelper {
    
    private var view: ViewControllerProxy?
    
    init(view: ViewControllerProxy?) {
        self.view = view
    }
    
    func showQuickBalanceAlert(biometryType: BiometryTypeEntity, acceptAction: @escaping () -> Void, cancelAction: @escaping () -> Void) {
        guard let viewController = self.view?.viewController else {return}
        let info = createItemsInfo(biometryType: biometryType, acceptAction: acceptAction, cancelAction: cancelAction)
        let identifiers = createItemsIdentifiers()
        let builder = PromptDialogBuilder(info: info, identifiers: identifiers)
        LisboaDialog(
            items: builder.build(),
            closeButtonAvailable: false
        ).showIn(viewController)
    }
    
    private func createItemsInfo(biometryType: BiometryTypeEntity, acceptAction: @escaping () -> Void, cancelAction: @escaping () -> Void) -> PromptDialogInfo {
        let keys = getKeys(for: biometryType)
        return PromptDialogInfo(title: localized("security_alertTitle_quickBalance"),
                                            description: localized(keys.description),
                                            questionText: localized("security_alertText_activateTouchId", [StringPlaceholder(.value, biometryType.biometryText)]),
        acceptButtonText: localized(keys.acceptButton),
        acceptAction: acceptAction,
        cancelButtonText: localized("generic_buttom_noThanks"),
        cancelAction: cancelAction)
    }
    
    private func createItemsIdentifiers() -> PromptDialogInfoIdentifiers {
        return PromptDialogInfoIdentifiers(title: "security_alertTitle_quickBalance",
                                                body: "security_alertText_quickBalance_body",
                                                question: "security_alertText_activateQuickBalance_question",
                                                acceptButton: "securityBtnActivate",
                                                cancelButton: "generic_buttom_noThanks")
    }
    
    private func getKeys(for biometryType: BiometryTypeEntity) -> (description: String, acceptButton: String) {
        switch biometryType {
        case .faceId:
            return ("security_alertText_quickBalanceFace", "security_button_activateFaceId")
        case .touchId:
            return ("security_alertText_quickBalance", "security_button_activateTouchId")
        case .none:
            return ("security_alertText_quickBalance", "security_button_activateTouchId")
        case .error(biometry: let biometry, error: let error):
            if biometry.isFaceId {
                return ("security_alertText_quickBalanceFace", "security_button_activateFaceId")
            } else {
                return ("security_alertText_quickBalance", "security_button_activateTouchId")
            }
        }
    }
}
