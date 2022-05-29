//
//  UpdatedSteps.swift
//  Cards
//
//  Created by Boris Chirino Fernandez on 15/10/2020.
//

import Foundation
import CoreFoundationLib

public final class StepTracker {
    private var aliasStep: AliasTracker
    private var applePayTracker: ApplePayTracker
    private var paymentMethodTracker: PaymentMethodTracker
    
    public init(aliasStep: AliasTracker, applePayTracker: ApplePayTracker, paymentMethodTracker: PaymentMethodTracker) {
        self.aliasStep = aliasStep
        self.applePayTracker = applePayTracker
        self.paymentMethodTracker = paymentMethodTracker
    }
    
    public var currentAlias: String {
        aliasStep.alias
    }
    
    public func updateAlias(_ alias: String) {
        self.aliasStep.alias = alias
    }
    
    public func updateApplePayState(applePayState: CardApplePayState) {
        self.applePayTracker.applePayState = applePayState
    }
    
    public var applePayState: CardApplePayState? {
        return self.applePayTracker.applePayState
    }
    
    public func updatePaymentMethod(paymentMethod: PaymentMethodCategory) {
        self.paymentMethodTracker.paymentMethod = paymentMethod
    }
    
    public var currentPaymentMethod: PaymentMethodCategory? {
        return self.paymentMethodTracker.paymentMethod
    }
}

// MARK: - Steps Trackers

// MARK: - Alias
public final class AliasTracker {
    fileprivate var alias: String
    public init(alias: String) {
        self.alias = alias
    }
}

public final class ApplePayTracker {
    fileprivate var applePayState: CardApplePayState?
    public init(applePayState: CardApplePayState?) {
        self.applePayState = applePayState
    }
}

public final class PaymentMethodTracker {
    fileprivate var paymentMethod: PaymentMethodCategory?
    public init(paymentMethod: PaymentMethodCategory?) {
        self.paymentMethod = paymentMethod
    }
}
