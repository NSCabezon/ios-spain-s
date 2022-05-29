//
//  BiometryDialog.swift
//  Login
//
//  Created by Juan Carlos López Robles on 12/11/20.
//
import UI
import CoreFoundationLib
import Foundation

final class BiometryDialog {
    func makeLisboaDialog(titleKey: String, descriptionKey: String,
                          acceptKey: String,
                          onAccept: @escaping () -> Void, onClose: @escaping () -> Void) -> LisboaDialog {
        let components: [LisboaDialogItem] = [
            .styledText(LisboaDialogTextItem(text: localized(titleKey),
                                             font: .santander(family: .headline, type: .regular, size: 22),
                                             color: .black,
                                             alignament: .center,
                                             margins: (30, 30))),
            .margin(19.0),
            .styledText(LisboaDialogTextItem(text: localized(descriptionKey),
                                             font: .santander(family: .text, type: .regular, size: 16),
                                             color: UIColor.Legacy.lisboaGrayNew,
                                             alignament: .center,
                                             margins: (30, 30))),
            .margin(35.0),
            .verticalAction(VerticalLisboaDialogAction(title: localized(acceptKey), type: .red, margins: (18.0, 19.0), action: onAccept)),
            .closeAction(onClose),
            .margin(23.0)
        ]
        return LisboaDialog(items: components, closeButtonAvailable: true)
    }
}
