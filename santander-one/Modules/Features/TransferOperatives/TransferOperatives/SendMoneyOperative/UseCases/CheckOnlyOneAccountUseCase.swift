//
//  CheckOnlyOneAccountUseCase.swift
//  TransferOperatives
//
//  Created by José María Jiménez Pérez on 15/9/21.
//

import CoreFoundationLib
import CoreDomain

class CheckOnlyOneAccountUseCase: UseCase<CheckOnlyAccountUseCaseInput, AccountRepresentable?, StringErrorOutput> {
    override func executeUseCase(requestValues: CheckOnlyAccountUseCaseInput) throws -> UseCaseResponse<AccountRepresentable?, StringErrorOutput> {
        guard requestValues.accountVisibles.count + requestValues.accountNotVisibles.count == 1 else {
            return .ok(nil)
        }
        if requestValues.accountVisibles.count > 0 {
            return .ok(requestValues.accountVisibles.first)
        } else {
            return .ok(requestValues.accountNotVisibles.first)
        }
    }
}

struct CheckOnlyAccountUseCaseInput {
    let accountVisibles: [AccountRepresentable]
    let accountNotVisibles: [AccountRepresentable]
}
