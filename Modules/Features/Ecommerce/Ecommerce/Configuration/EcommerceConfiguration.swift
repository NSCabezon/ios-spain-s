//
//  EcommerceConfiguration.swift
//  Ecommerce
//
//  Created by Tania Castellano Brasero on 11/03/2021.
//

import CoreFoundationLib

public struct EcommerceConfiguration {
    let accessKeyCode: String?
    let section: EcommerceModuleCoordinator.EcommerceSection
    
    public init(accessKeyCode: String? = nil, section: EcommerceModuleCoordinator.EcommerceSection = .mainDefault) {
        self.accessKeyCode = accessKeyCode
        self.section = section
    }
}

public struct EcommerceInput {
    let lastPurchaseCode: String?
    
    public init(lastPurchaseCode: String?) {
        self.lastPurchaseCode = lastPurchaseCode
    }
}
