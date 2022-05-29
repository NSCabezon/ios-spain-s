//
//  DepositModifier.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 2/2/21.
//

import CoreFoundationLib
import Foundation

open class DepositModifier {
    public var next: DepositModifier?
    public let dependenciesResolver: DependenciesResolver
    public var completion: ((DependenciesResolver) -> Void)?

    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }

    @discardableResult
    public func add(_ modifier: DepositModifier) -> Self {
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
    
    open func didSelectDeposit(deposit: DepositEntity) {
        self.next?.didSelectDeposit(deposit: deposit)
    }
}
