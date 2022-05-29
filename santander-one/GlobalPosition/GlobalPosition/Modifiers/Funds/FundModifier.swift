//
//  DepositModifier.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 2/3/21.
//

import CoreFoundationLib
import Foundation

open class FundModifier {
    public var next: FundModifier?
    public let dependenciesResolver: DependenciesResolver
    public var completion: ((DependenciesResolver) -> Void)?

    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }

    @discardableResult
    public func add(_ modifier: FundModifier) -> Self {
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
    
    open func didSelectFund(fund: FundEntity) {
        self.next?.didSelectFund(fund: fund)
    }
}
