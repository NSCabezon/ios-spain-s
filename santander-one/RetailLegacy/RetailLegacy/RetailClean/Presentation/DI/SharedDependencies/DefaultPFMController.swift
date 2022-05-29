//
//  DefaultPFMController.swift
//  CoreFoundationLib
//
//  Created by José Carlos Estela Anguita on 3/2/22.
//

import Foundation
import CoreFoundationLib
import CoreDomain

public final class DefaultPFMController: PfmControllerProtocol {
    
    public init() {
        
    }
    
    public var monthsHistory: [MonthlyBalanceRepresentable]? = nil
    
    public var isFinish: Bool {
        return true
    }
    
    public func isPFMAccountReady(account: AccountEntity) -> Bool {
        return true
    }
    
    public func isPFMCardReady(card: CardEntity) -> Bool {
        return true
    }
    
    public func registerPFMSubscriber(with subscriber: PfmControllerSubscriber) {
        subscriber.finishedPFM(months: [])
    }
    
    public func removePFMSubscriber(_ subscriber: PfmControllerSubscriber) {
        
    }
    
    public func cancelAll() {
        
    }
}
