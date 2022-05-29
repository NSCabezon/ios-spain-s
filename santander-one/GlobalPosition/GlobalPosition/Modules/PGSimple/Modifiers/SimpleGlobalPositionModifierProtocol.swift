//
//  SimpleGlobalPositionModifierProtocol.swift
//  GlobalPosition
//
//  Created by Jose Camallonga on 14/10/21.
//

import Foundation
import CoreFoundationLib

public protocol SimpleGlobalPositionModifierProtocol: AnyObject {
    var areShortcutsVisible: Bool { get }
    var isConfigureWhatYouSeeVisible: Bool { get }
    var isHomeAccountAvailable: Bool { get }
    var isHomeFundAvailable: Bool { get }
    var isHomePortfolioAvailable: Bool { get }
    var isHomeProtectionInsuranceAvailable: Bool { get }
    var isHomeSavingInsuranceAvailable: Bool { get }
    var isHomeStockAccountAvailable: Bool { get }
    var isYourMoneyVisible: Bool { get }
    var showIbanAccountOnSubtitle: Bool { get }
    var showCreditCardAvailableAmount: Bool { get }
    var isInterventionFilterEnabled: Bool { get }
    func displayInfo(for saving: SavingProductEntity) -> (subtitle: String?, descriptionKey: String?)
}

public extension SimpleGlobalPositionModifierProtocol {
    var areShortcutsVisible: Bool {
        return true
    }
    
    var isConfigureWhatYouSeeVisible: Bool {
        return true
    }
    
    var isYourMoneyVisible: Bool {
        return true
    }
    
    var isHomeAccountAvailable: Bool {
        return true
    }
    
    var isHomePortfolioAvailable: Bool {
        return true
    }
    
    var isHomeProtectionInsuranceAvailable: Bool {
        return true
    }
    
    var isHomeSavingInsuranceAvailable: Bool {
        return true
    }
    
    var isHomeStockAccountAvailable: Bool {
        return true
    }
    
    var showIbanAccountOnSubtitle: Bool {
        return true
    }
    
    var showCreditCardAvailableAmount: Bool {
        return false
    }
    
    var isInterventionFilterEnabled: Bool {
        return true
    }
 
    func displayInfo(for saving: SavingProductEntity) -> (subtitle: String?, descriptionKey: String?) {
        return(saving.productIdentifier, "pg_label_investment")
    }
}
