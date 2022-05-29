//
//  LoadFundableTypeUseCase.swift
//  Santander
//
//  Created by José María Jiménez Pérez on 13/1/22.
//

import CoreFoundationLib
import TransferOperatives

final class LoadFundableTypeUseCase: UseCase<LoadFundableTypeUseCaseInput, LoadFundableTypeUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: LoadFundableTypeUseCaseInput) throws -> UseCaseResponse<LoadFundableTypeUseCaseOkOutput, StringErrorOutput> {
        let dispatchGroup = DispatchGroup()
        var fundableType: AccountEasyPayFundableType?
        dispatchGroup.enter()
        self.loadAccountEasyPayInfo { accountEasyPay in
            guard let amount = requestValues.amount,
                  let accountEasyPay = accountEasyPay
            else {
                dispatchGroup.leave()
                return
            }
            fundableType = self.easyPayFundableType(for: amount, accountEasyPay: accountEasyPay)
            dispatchGroup.leave()
        }
        dispatchGroup.wait()
        return .ok(LoadFundableTypeUseCaseOkOutput(fundableType: fundableType))
    }
}

private extension LoadFundableTypeUseCase {
    func loadAccountEasyPayInfo(completion: @escaping (AccountEasyPay?) -> Void) {
        let input = GetAccountEasyPayUseCaseInput(type: .transfer)
        let useCase = GetAccountEasyPayUseCase(dependenciesResolver: self.dependenciesResolver).setRequestValues(requestValues: input)
        Scenario(useCase: useCase, input: input)
            .execute(on: dependenciesResolver.resolve())
            .onSuccess { output in
                completion(output.accountEasyPay)
            }
            .onError { _ in
                completion(nil)
            }
    }
}

extension LoadFundableTypeUseCase: LoadFundableTypeUseCaseProtocol {}

extension LoadFundableTypeUseCase: AccountEasyPayChecker {}
