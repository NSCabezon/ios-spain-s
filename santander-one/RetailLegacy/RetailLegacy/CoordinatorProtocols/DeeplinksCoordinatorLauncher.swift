//
//  File.swift
//  RetailLegacy
//
//  Created by Erik Nascimento on 09/06/21.
//

import CoreFoundationLib

public protocol DeeplinksCoordinatorLauncher {
    func goToAccountsHome(with selected: AccountEntity)
    func goToTransfersHome()
    func goToTransfersHistory()
}
