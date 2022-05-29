//
//  OperativeCoordinatorLauncher.swift
//  RetailLegacy
//
//  Created by Carlos Monfort Gómez on 15/4/21.
//

import Foundation

public protocol OperativeCoordinatorLauncher {
    func showOperativeLoading(completion: @escaping () -> Void)
    func hideOperativeLoading(completion: @escaping () -> Void)
    func showOperativeAlertError(keyTitle: String?, keyDesc: String?, completion: (() -> Void)?)
}
