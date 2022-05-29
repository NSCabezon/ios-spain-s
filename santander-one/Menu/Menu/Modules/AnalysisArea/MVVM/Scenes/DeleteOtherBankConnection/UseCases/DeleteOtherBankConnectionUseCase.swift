//
//  DeleteOtherBankConnectionUseCase.swift
//  Menu
//
//  Created by Adrian Arcalá Ocón on 21/3/22.
//

import Foundation
import OpenCombine
import CoreDomain

public protocol DeleteOtherBankConnectionUseCase {
    func fetchFinancialDeleteBankPublisher(bankCode: String) -> AnyPublisher<Void, Error>
}

struct DefaultDeleteOtherBankConnectionUseCase {
    private let repository: FinancialHealthRepository
    
    init(dependencies: DeleteOtherBankConnectionDependenciesResolver) {
        self.repository = dependencies.external.resolve()
    }
}

extension DefaultDeleteOtherBankConnectionUseCase: DeleteOtherBankConnectionUseCase {
    func fetchFinancialDeleteBankPublisher(bankCode: String) -> AnyPublisher<Void, Error> {
        self.repository.deleteFinancialBank(bankCode: bankCode)
    }
}
