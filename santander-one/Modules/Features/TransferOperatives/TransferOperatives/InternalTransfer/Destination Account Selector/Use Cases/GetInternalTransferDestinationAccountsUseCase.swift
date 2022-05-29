//
//  GetInternalTransferDestinationAccountsUseCase.swift
//  TransferOperatives
//
//  Created by Carlos Monfort Gómez on 18/2/22.
//

import OpenCombine
import CoreDomain

public struct GetInternalTransferDestinationAccountsInput {
    public let visibleAccounts: [AccountRepresentable]
    public let notVisibleAccounts: [AccountRepresentable]
    public let originAccount: AccountRepresentable
}

public struct GetInternalTransferDestinationAccountsOutput {
    public let visibleAccounts: [AccountRepresentable]
    public let notVisibleAccounts: [AccountRepresentable]
    
    public init(visibleAccounts: [AccountRepresentable], notVisibleAccounts: [AccountRepresentable]) {
        self.visibleAccounts = visibleAccounts
        self.notVisibleAccounts = notVisibleAccounts
    }
}

public protocol GetInternalTransferDestinationAccountsUseCase {
    func fetchAccounts(input: GetInternalTransferDestinationAccountsInput) -> AnyPublisher<GetInternalTransferDestinationAccountsOutput, Never>
}

struct DefaultGetInternalTransferDestinationAccountsUseCase {}

extension DefaultGetInternalTransferDestinationAccountsUseCase: GetInternalTransferDestinationAccountsUseCase {
    func fetchAccounts(input: GetInternalTransferDestinationAccountsInput) -> AnyPublisher<GetInternalTransferDestinationAccountsOutput, Never> {
        let visiblesFiltered = input.visibleAccounts.filter { !$0.equalsTo(other: input.originAccount) }
        let notVisiblesFiltered = input.notVisibleAccounts.filter { !$0.equalsTo(other: input.originAccount) }
        return Just(GetInternalTransferDestinationAccountsOutput(
            visibleAccounts: visiblesFiltered,
            notVisibleAccounts: notVisiblesFiltered
        )).eraseToAnyPublisher()
    }
}
