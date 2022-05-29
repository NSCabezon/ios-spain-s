//
//  SPSendMoneyTransferTypeProtocol.swift
//  Santander
//
//  Created by Angel Abad Perez on 7/2/22.
//

import TransferOperatives
import CoreFoundationLib
import CoreDomain

public protocol SPSendMoneyTransferTypeProtocol: AnyObject {
    var dependenciesResolver: DependenciesResolver { get }
    func transferType(requestValues: SendMoneyOperativeData) throws -> UseCaseResponse<SendMoneyOperativeData, StringErrorOutput>
}

public extension SPSendMoneyTransferTypeProtocol {
    func transferType(requestValues: SendMoneyOperativeData) throws -> UseCaseResponse<SendMoneyOperativeData, StringErrorOutput> {
        guard let selectedAccount = requestValues.selectedAccount,
              let countryCode = requestValues.country?.code ?? requestValues.countryCode,
              let currencyCode = requestValues.currency?.code
        else {
            return .error(StringErrorOutput(nil))
        }
        let manager: TransfersRepository = dependenciesResolver.resolve()
        let response = try manager.transferType(originAccount: selectedAccount,
                                                selectedCountry: countryCode,
                                                selectedCurrerncy: currencyCode)
        switch response {
        case .success(let data):
            requestValues.type = OnePayTransferType.from(data)
            return .ok(requestValues)
        case .failure(let error):
            return .error(StringErrorOutput(error.localizedDescription))
        }
    }
}
