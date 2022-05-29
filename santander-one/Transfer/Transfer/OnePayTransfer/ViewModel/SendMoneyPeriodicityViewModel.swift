//
//  SendMoneyPeriodicityViewModel.swift
//  Transfer
//
//  Created by Jose Javier Montes Romero on 24/5/21.
//
import CoreFoundationLib
import TransferOperatives

public struct SendMoneyPeriodicityViewModel {
    
    private let dependenciesResolver: DependenciesResolver

    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    public var periodicityTypes: [SendMoneyPeriodicityTypeViewModel] {
        guard let periodicityTypesModifier = self.dependenciesResolver.resolve(forOptionalType: OnePayTransferModifierProtocol.self)?.getPeriodicityTypes() else {
            return [.month, .quarterly, .semiannual]
        }
        return periodicityTypesModifier
    }
}
