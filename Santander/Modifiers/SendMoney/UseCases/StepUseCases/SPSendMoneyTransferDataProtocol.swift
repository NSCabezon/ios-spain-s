//
//  SPSendMoneyTransferDataProtocol.swift
//  Santander
//
//  Created by José María Jiménez Pérez on 15/2/22.
//

import CoreFoundationLib
import TransferOperatives
import CoreDomain
import SANSpainLibrary

protocol SPSendMoneyTransferDataProtocol {
    var dependenciesResolver: DependenciesResolver { get }
    func completeTransferData(requestValues: SendMoneyOperativeData) throws -> UseCaseResponse<SendMoneyOperativeData, StringErrorOutput>
}

extension SPSendMoneyTransferDataProtocol {
    func completeTransferData(requestValues: SendMoneyOperativeData) throws -> UseCaseResponse<SendMoneyOperativeData, StringErrorOutput> {
        switch requestValues.destinationSelectionType {
        case .favorite: return try self.completeFavoriteData(operativeData: requestValues)
        case .recent: return try self.completeRecentTransferData(operativeData: requestValues)
        case .newRecipient: return .ok(requestValues)
        }
    }
}

private extension SPSendMoneyTransferDataProtocol {
    func completeRecentTransferData(operativeData: SendMoneyOperativeData) throws -> UseCaseResponse<SendMoneyOperativeData, StringErrorOutput> {
        guard let selectedIndex = operativeData.selectedLastTransferIndex,
              let selectedRecent = operativeData.lastTransfers?[selectedIndex]
        else {
            return .error(StringErrorOutput(nil))
        }
        guard let selectedTransferType = TransfersType.findBy(type: selectedRecent.transferType) else {
            return .error(StringErrorOutput(nil))
        }
        let transferType = OnePayTransferType.from(selectedTransferType)
        operativeData.type = transferType
        if transferType == .noSepa {
            return try self.getNoSepaTransferDetail(operativeData: operativeData, transfer: selectedRecent)
        } else {
            return try self.getSepaTransferDetail(operativeData: operativeData, transfer: selectedRecent)
        }
    }
    
    func getSepaTransferDetail(operativeData: SendMoneyOperativeData, transfer: TransferRepresentable) throws -> UseCaseResponse<SendMoneyOperativeData, StringErrorOutput> {
        let transferRepository: TransfersRepository = self.dependenciesResolver.resolve()
        let result = try transferRepository.getTransferDetail(transfer: transfer)
        switch result {
        case .success(let transferRepresentable):
            operativeData.destinationName = transferRepresentable.name
            operativeData.destinationIBANRepresentable = transferRepresentable.ibanRepresentable
            operativeData.countryCode = transferRepresentable.countryCode
            operativeData.type = .sepa
            return .ok(operativeData)
        case .failure(let error):
            return .error(StringErrorOutput(error.localizedDescription))
        }
    }
    
    func getNoSepaTransferDetail(operativeData: SendMoneyOperativeData, transfer: TransferRepresentable) throws -> UseCaseResponse<SendMoneyOperativeData, StringErrorOutput> {
        guard let spainTransferRepository = self.dependenciesResolver.resolve(for: TransfersRepository.self) as? SpainTransfersRepository
        else { return .error(StringErrorOutput(nil)) }
        let result = try spainTransferRepository.getNoSepaTransferDetail(transfer: transfer)
        switch result {
        case .success(let noSepaTransferRepresentable):
            operativeData.countryCode = noSepaTransferRepresentable.countryCode
            operativeData.currencyName = noSepaTransferRepresentable.amountRepresentable?.currencyRepresentable?.currencyName
            operativeData.bicSwift = noSepaTransferRepresentable.bicSwift
            operativeData.destinationAccount = noSepaTransferRepresentable.destinationAccount
            operativeData.bankName = noSepaTransferRepresentable.bankName
            operativeData.bankAddress = noSepaTransferRepresentable.bankAddress
            return .ok(operativeData)
        case .failure(let error):
            return .error(StringErrorOutput(error.localizedDescription))
        }
    }
    
    func completeFavoriteData(operativeData: SendMoneyOperativeData) throws -> UseCaseResponse<SendMoneyOperativeData, StringErrorOutput> {
        guard let spainTransferRepository = self.dependenciesResolver.resolve(for: TransfersRepository.self) as? SpainTransfersRepository,
              let payee = operativeData.selectedPayee
        else { return .error(StringErrorOutput(nil)) }
        guard payee.isNoSepa else {
            operativeData.type = .sepa
            operativeData.countryCode = payee.countryCode
            operativeData.currencyName = payee.currencyName
            return .ok(operativeData)
        }
        operativeData.type = .noSepa
        let result = try spainTransferRepository.getNoSepaPayeeDetail(alias: payee.payeeAlias ?? "", recipientType: payee.recipientType ?? "")
        switch result {
        case .success(let noSepaPayeeRepresentable):
            operativeData.countryCode = noSepaPayeeRepresentable.countryCode
            operativeData.currencyName = noSepaPayeeRepresentable.amountRepresentable?.currencyRepresentable?.currencyName
            operativeData.bicSwift = noSepaPayeeRepresentable.bicSwift
            operativeData.bankName = noSepaPayeeRepresentable.bankName
            operativeData.bankAddress = noSepaPayeeRepresentable.bankAddress
            operativeData.destinationAccount = noSepaPayeeRepresentable.destinationAccount
            return .ok(operativeData)
        case .failure(let error):
            return .error(StringErrorOutput(error.localizedDescription))
        }
        
    }
}
