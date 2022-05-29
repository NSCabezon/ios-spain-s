//
//  SetupSendMoneyUseCase.swift
//  Transfer
//
//  Created by David Gálvez Alonso on 21/07/2021.
//

import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain

class SetupSendMoneyUseCase: UseCase<Void, SetupSendMoneyUseCaseOkOutput, StringErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    private let bsanManagersProvider: BSANManagersProvider
    private let appRepository: AppRepositoryProtocol

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.bsanManagersProvider = dependenciesResolver.resolve()
        self.appRepository = dependenciesResolver.resolve()
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<SetupSendMoneyUseCaseOkOutput, StringErrorOutput> {
        let globalPosition = dependenciesResolver.resolve(for: GlobalPositionWithUserPrefsRepresentable.self)
        let appConfigRepository = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
        let userPrefEntity = globalPosition.userPref
        let favoriteContacts = userPrefEntity?.getFavoriteContacts()
        let dataUsualTransfer = try getUsualTransfers(loadingFromNetworkIfNeeded: true)
        let usualTransfers = dataUsualTransfer
        var amount: AmountEntity?
        if let max = appConfigRepository.getDecimal("instantNationalTransfersMaxAmount") {
            amount = AmountEntity(value: max)
        }
        let baseUrl = try? self.appRepository.getCurrentPublicFilesEnvironment().getResponseData()?.urlBase ?? ""
        let enabledFavouritesCarrusel = appConfigRepository.getBool("enabledCarruselFavoritosDestinatario") ?? false
        let name = globalPosition.clientNameWithoutSurname?.camelCasedString ?? globalPosition.completeName
        let fullName = globalPosition.fullName ?? globalPosition.completeName
        return UseCaseResponse.ok(SetupSendMoneyUseCaseOkOutput(favouriteList: usualTransfers,
                                                                maxAmount: amount,
                                                                payer: name ?? "",
                                                                baseUrl: baseUrl,
                                                                enabledFavouritesCarrusel: enabledFavouritesCarrusel,
                                                                favoriteContacts: favoriteContacts,
                                                                summaryUserName: fullName ?? ""))
    }
}

private extension SetupSendMoneyUseCase {
    func getUsualTransfers(loadingFromNetworkIfNeeded loadingFromNetwork: Bool) throws -> [PayeeDTO] {
        let transferManager = bsanManagersProvider.getBsanTransfersManager()
        let responseUsualTransfer = try transferManager.getUsualTransfers()
        guard
            responseUsualTransfer.isSuccess(),
            let dataUsualTransfer = try responseUsualTransfer.getResponseData(),
            dataUsualTransfer.count > 0
        else {
            guard loadingFromNetwork else { return [] }
            _ = try transferManager.loadUsualTransfers()
            return try getUsualTransfers(loadingFromNetworkIfNeeded: false)
        }
        return dataUsualTransfer
    }
}


struct SetupSendMoneyUseCaseOkOutput {
    let favouriteList: [PayeeRepresentable]
    let maxAmount: AmountEntity?
    let payer: String
    let baseUrl: String?
    let enabledFavouritesCarrusel: Bool
    let favoriteContacts: [String]?
    let summaryUserName: String
}
