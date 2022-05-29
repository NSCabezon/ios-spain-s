//
//  NavigateToSettingsDialogCapable.swift
//  PersonalArea
//
//  Created by alvola on 12/4/22.
//

import Foundation
import UI
import CoreFoundationLib

protocol NavigateToSettingsDialogCapable {
    var associatedViewController: UIViewController { get }
    func openSettings(for permission: String)
}

extension NavigateToSettingsDialogCapable {
    func openSettings(for permission: String) {
        let text = LisboaDialogTextItem(text: localized(permission),
                                        font: .santander(family: .headline, size: 14.0),
                                        color: .mediumSanGray,
                                        alignament: .center,
                                        margins: (0.0, 0.0))
        let leftAction = LisboaDialogAction(title: localized("generic_button_cancel"),
                                            type: LisboaDialogActionType.white,
                                            margins: (0.0, 0.0),
                                            isCancelAction: true) { }
        let rightAction = LisboaDialogAction(title: localized("genericAlert_buttom_settings"),
                                             type: LisboaDialogActionType.red,
                                             margins: (0.0, 0.0)) {
            navigateToSettings()
        }
        let dialog = LisboaDialog(items: [.margin(22.0),
                                          .styledText(text),
                                          .horizontalActions(HorizontalLisboaDialogActions(left: leftAction,
                                                                                           right: rightAction))],
                                  closeButtonAvailable: false)
        dialog.showIn(associatedViewController)
    }
    
    func navigateToSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}
