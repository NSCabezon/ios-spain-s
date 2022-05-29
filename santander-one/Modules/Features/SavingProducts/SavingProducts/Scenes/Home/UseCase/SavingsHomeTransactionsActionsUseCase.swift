//
//  SavingsHomeTransactionsActionsUseCase.swift
//  SavingProducts
//
//  Created by Mario Rosales Maillo on 18/4/22.
//

import Foundation
import CoreDomain
import OpenCombine
import CoreFoundationLib
import UI

public protocol SavingsHomeTransactionsActionsUseCase {
    func getAvailableTransactionsButtonActions(for savingProduct: SavingProductRepresentable) -> AnyPublisher<[SavingProductsTransactionsButtonsType], Never>
}

struct DefaultSavingsHomeTransactionsActionsUseCase : SavingsHomeTransactionsActionsUseCase {
    func getAvailableTransactionsButtonActions(for savingProduct: SavingProductRepresentable) -> AnyPublisher<[SavingProductsTransactionsButtonsType], Never> {
        return Just([.filter]).eraseToAnyPublisher()
    }
}
