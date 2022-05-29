//
//  SPSendMoneyAmountNoSepaUseCase.swift
//  Santander
//
//  Created by José María Jiménez Pérez on 23/2/22.
//

import CoreFoundationLib
import TransferOperatives
import SANServicesLibrary

final class SPSendMoneyAmountNoSepaUseCase: UseCase<SendMoneyOperativeData, SendMoneyOperativeData, StringErrorOutput>, SendMoneyAmountNoSepaUseCaseProtocol {
    
    let dependenciesResolver: DependenciesResolver
    
    init(dependeciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependeciesResolver
    }
    
    override func executeUseCase(requestValues: SendMoneyOperativeData) throws -> UseCaseResponse<SendMoneyOperativeData, StringErrorOutput> {
        let result = try self.validateNoSepa(requestValues: requestValues)
        guard result.isOkResult, let okValue = try? result.getOkResult() else {
            return .error(StringErrorOutput(try result.getErrorResult().localizedDescription))
        }
        okValue.specialPricesOutput = self.getDefaultNoSepaSpecialPrices(operativeData: okValue)
        return .ok(okValue)
    }
}

private extension SPSendMoneyAmountNoSepaUseCase {
    func getDefaultNoSepaSpecialPrices(operativeData: SendMoneyOperativeData) -> SendMoneyTransferTypeUseCaseOkOutput {
        let output = SendMoneyTransferTypeUseCaseOkOutput(shouldShowSpecialPrices: false,
                                                          fees: [SendMoneyTransferTypeFee(type: SpainInternationalTransferType.standard, fee: operativeData.expenses?.getSwiftExpensesWith(operativeData: operativeData))], instantMaxAmount: nil)
        operativeData.selectedTransferType = output.fees.first
        return output
    }
}

extension SPSendMoneyAmountNoSepaUseCase: SPSendMoneyNoSepaValidateProtocol { }
