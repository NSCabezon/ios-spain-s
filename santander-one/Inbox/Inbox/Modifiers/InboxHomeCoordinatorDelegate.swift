//
//  InboxHomeCoordinatorDelegate.swift
//  Commons
//
//  Created by Carlos Monfort Gómez on 27/5/21.
//

import Foundation
import CoreFoundationLib

public protocol InboxHomeCoordinatorDelegate: AnyObject {
    func didSelectAction(type: InboxActionType)
}
