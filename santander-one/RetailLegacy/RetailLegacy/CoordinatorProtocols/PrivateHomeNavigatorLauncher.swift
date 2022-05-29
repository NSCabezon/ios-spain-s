//
//  PrivateHomeNavigatorLauncher.swift
//  RetailLegacy
//
//  Created by Carlos Monfort Gómez on 14/4/21.
//

import Transfer

public protocol PrivateHomeNavigatorLauncher {
    func goToGlobalSearch()
    func goToGPCustomization()
    func goToGPProductsCustomization()
    func goToTransfers(section: TransferModuleCoordinator.TransferSection)
    func goToAppPermissions()
}

extension PrivateHomeNavigatorLauncher {
    func goToGPProductsCustomization() { }
}
