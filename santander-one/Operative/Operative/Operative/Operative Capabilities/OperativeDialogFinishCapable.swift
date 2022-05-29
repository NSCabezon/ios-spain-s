//
//  OperativeDialogFinishCapable.swift
//  Operative
//
//  Created by Luis Escámez Sánchez on 21/6/21.
//

import Foundation
import UI
import CoreFoundationLib

public protocol OperativeDialogFinishCapable {
    var operative: Operative { get }
    func showPopUpDialog(_ view: UIViewController, acceptAction: @escaping () -> Void, cancelAction: @escaping () -> Void)
}

public extension OperativeDialogFinishCapable where Self: Operative {
    var operative: Operative {
        return self
    }
    
    func showPopUpDialog(_ view: UIViewController, acceptAction: @escaping () -> Void, cancelAction: @escaping () -> Void) {
        LisboaDialog(items: [.image(LisboaDialogImageViewItem(image: Assets.image(named: "icnSanRedInfo"), size: (50, 50))),
                                  self.title,
                                  self.subtitle,
                                  .margin(24),
                                  self.createAcceptItem(action: acceptAction),
                                  .margin(16),
                                  self.createCancelItem(action: cancelAction),
                                  .margin(30)],
                          closeButtonAvailable: true,
                          executeCancelActionOnClose: true)
            .showIn(view)
    }
}

// MARK: - Private Methods
private extension OperativeDialogFinishCapable {
    var title: LisboaDialogItem {
        return .styledText(LisboaDialogTextItem(text: localized("modal_title_stopOperation"),
                                                font: .santander(family: .text, type: .regular, size: 27),
                                                color: .lisboaGray,
                                                alignament: .center,
                                                margins: (34, 34),
                                                accesibilityIdentifier: PromptDialogIdentifiers.title.rawValue)
        )
    }
    var subtitle: LisboaDialogItem {
        return .styledText(LisboaDialogTextItem(text: localized("modal_text_stopOperation"),
                                                font: .santander(family: .text, type: .regular, size: 20),
                                                color: .lisboaGray,
                                                alignament: .center,
                                                margins: (16, 16),
                                                accesibilityIdentifier: PromptDialogIdentifiers.subtitle.rawValue)
        )
    }
    
    func createAcceptItem(action: @escaping () -> Void) -> LisboaDialogItem {
        return .verticalAction(VerticalLisboaDialogAction(title: localized("modal_button_yesGoOut"),
                                                          type: .red,
                                                          margins: (14, 14),
                                                          accesibilityIdentifier: PromptDialogIdentifiers.accept.rawValue,
                                                          action: action)
        )
    }
    
    func createCancelItem(action: @escaping () -> Void) -> LisboaDialogItem {
        return .verticalAction(VerticalLisboaDialogAction(title: localized("modal_alert_button_noWantContinue"),
                                                          type: .white,
                                                          margins: (14, 14),
                                                          accesibilityIdentifier: PromptDialogIdentifiers.cancel.rawValue,
                                                          isCancelAction: true,
                                                          action: action)
        )
    }
}

private enum PromptDialogIdentifiers: String {
    case title = "dialog_text_title"
    case subtitle = "dialog_text_subtitle"
    case accept = "dialog_button_accept"
    case cancel = "dialog_button_cancel"
}
