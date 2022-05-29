//
//  InsurancesModifier.swift
//  Account
//
//  Created by Ernesto Fernandez Calles on 14/2/22.
//

import CoreFoundationLib
import Foundation

open class InsuranceProtectionModifier {
    public var next: InsuranceProtectionModifier?
    public let dependenciesResolver: DependenciesResolver
    public var completion: ((DependenciesResolver) -> Void)?

    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }

    @discardableResult
    public func add(_ modifier: InsuranceProtectionModifier) -> Self {
        if let next = self.next {
            next.add(modifier)
            next.setCompletion(self.completion)
        } else {
            self.next = modifier
            self.next?.setCompletion(self.completion)
        }
        return self
    }

    public func setCompletion(_ completion: ((DependenciesResolver) -> Void)?) {
        self.completion = completion
    }

    @discardableResult
    public func reset() -> Self {
        self.next = nil
        return self
    }

    func addExtraModifier() {
        self.next?.addExtraModifier()
    }

    open func didSelectInsuranceProtection(insurance: InsuranceProtectionEntity) {
        self.next?.didSelectInsuranceProtection(insurance: insurance)
    }
}
