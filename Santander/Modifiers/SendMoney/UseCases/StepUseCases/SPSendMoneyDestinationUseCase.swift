//
//  SPSendMoneyDestinationUseCase.swift
//  Santander
//
//  Created by David Gálvez Alonso on 3/2/22.
//

import CoreFoundationLib
import TransferOperatives

final class SPSendMoneyDestinationUseCase: UseCase<SendMoneyOperativeData, SendMoneyOperativeData, DestinationAccountSendMoneyUseCaseErrorOutput>, SendMoneyDestinationUseCaseProtocol {
    
    private var bankingUtils: BankingUtilsProtocol
    var dependenciesResolver: DependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.bankingUtils = dependenciesResolver.resolve()
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: SendMoneyOperativeData) throws -> UseCaseResponse<SendMoneyOperativeData, DestinationAccountSendMoneyUseCaseErrorOutput> {
        guard self.checkDestinationComplete(requestValues: requestValues) else {
            return .error(DestinationAccountSendMoneyUseCaseErrorOutput(.ibanInvalid))
        }
        guard let name = requestValues.destinationName, name.trim().count > 0 else {
            return .error(DestinationAccountSendMoneyUseCaseErrorOutput(.noToName))
        }
        if requestValues.saveToFavorite {
            if let error = self.checkNewFavoriteError(requestValues: requestValues) {
                return .error(error)
            }
        }
        var response = try self.completeTransferData(requestValues: requestValues)
        guard response.isOkResult,
              let okValue = try? response.getOkResult()
        else {
            return .error(DestinationAccountSendMoneyUseCaseErrorOutput(.serviceError(errorDesc: try response.getErrorResult().localizedDescription)))
        }
        if okValue.type != .noSepa || okValue.destinationSelectionType == .newRecipient {
            response = try self.transferType(requestValues: okValue)
        }
        if response.isOkResult {
            let okResult = try response.getOkResult()
            if okResult.expenses == nil {
                okResult.expenses = SpainNoSepaTransferExpenses.shared
            }
            guard okResult.type != .noSepa else {
                okResult.transferDateType = .now
                return .ok(okResult)
            }
            guard let ibanString = requestValues.destinationIBANRepresentable?.ibanString,
                  bankingUtils.isValidIban(ibanString: ibanString)
            else { return .error(DestinationAccountSendMoneyUseCaseErrorOutput(.ibanInvalid)) }
            okResult.destinationAccount = ibanString
            return .ok(okResult)
        } else {
            let error = try response.getErrorResult()
            return .error(DestinationAccountSendMoneyUseCaseErrorOutput(.serviceError(errorDesc: error.localizedDescription)))
        }
    }
}

private extension SPSendMoneyDestinationUseCase {
    func checkDestinationComplete(requestValues: SendMoneyOperativeData) -> Bool {
        guard let ibanString = requestValues.destinationIBANRepresentable?.ibanString,
              !ibanString.isEmpty
        else {
            guard let destinationAccount = requestValues.destinationAccount,
                  !destinationAccount.isEmpty
            else {
                return false
            }
            return true
        }
        return true
    }
    
    func checkNewFavoriteError(requestValues: SendMoneyOperativeData) -> DestinationAccountSendMoneyUseCaseErrorOutput? {
        guard let destinationAlias = requestValues.destinationAlias?.lowercased().trim(),
              destinationAlias.count > 0 else {
            return DestinationAccountSendMoneyUseCaseErrorOutput(.noAlias)
        }
        guard let destinationIban = requestValues.destinationIBANRepresentable?.ibanString,
              let destinationAccount = requestValues.destinationAccount else {
            return DestinationAccountSendMoneyUseCaseErrorOutput(.ibanInvalid)
        }
        let duplicatedDestination = requestValues.fullFavorites?.first {
            return $0.ibanRepresentable?.ibanString == destinationIban || $0.destinationAccount == destinationAccount
        }
        guard duplicatedDestination == nil else {
            return DestinationAccountSendMoneyUseCaseErrorOutput(.duplicateIban)
        }
        let duplicatedAlias = requestValues.fullFavorites?.first {
            return $0.payeeAlias?.lowercased().trim() == destinationAlias
        }
        guard duplicatedAlias == nil else {
            return DestinationAccountSendMoneyUseCaseErrorOutput(.duplicateAlias)
        }
        return nil
    }
}

extension SPSendMoneyDestinationUseCase: SPSendMoneyTransferTypeProtocol { }
extension SPSendMoneyDestinationUseCase: SPSendMoneyTransferDataProtocol { }
