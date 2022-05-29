//
//  PTOperativeShortcutsModifierProtocol.swift
//  GlobalPosition
//
//  Created by Pedro Meira on 22/03/2021.
//

import CoreFoundationLib

public protocol PTOperativeShortcutsModifierProtocol: AnyObject {
    func valuesPT() -> [AccountOperativeActionType: (title: String, imageName: String)]
}
