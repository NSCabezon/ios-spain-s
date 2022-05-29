//
//  UnreadMovementsUseCase.swift
//  GlobalPosition
//
//  Created by Boris Chirino Fernandez on 14/07/2020.
//

import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain

public protocol GetUnreadMovementsUseCase: UseCase<GetUnreadMovementsUseCaseInput, GetUnreadMovementsUseCaseOkOutput, StringErrorOutput> {}

final class DefaultGetUnreadMovementsUseCase: UseCase<GetUnreadMovementsUseCaseInput, GetUnreadMovementsUseCaseOkOutput, StringErrorOutput>,
                                              GetUnreadMovementsUseCase {
    private let dependenciesResolver: DependenciesResolver
    private let bsanManagersProvider: BSANManagersProvider
    private var locations: [PullOfferLocation] {
        return PullOffersLocationsFactoryEntity().accountsTransactionDetail
    }
    private var globalPosition: GlobalPositionRepresentable
    private let appConfigRepository: AppConfigRepositoryProtocol
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        globalPosition = dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
        self.bsanManagersProvider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
        self.appConfigRepository = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
    }
    
    override func executeUseCase(requestValues: GetUnreadMovementsUseCaseInput) throws -> UseCaseResponse<GetUnreadMovementsUseCaseOkOutput, StringErrorOutput> {
        let pullOffersInterpreter = self.dependenciesResolver.resolve(for: PullOffersInterpreter.self)
        // pulloffers
        var outputCandidates: [PullOfferLocation: OfferEntity] = [:]
        if let userId: String = globalPosition.userId {
            for location in locations {
                if let candidate = pullOffersInterpreter.getCandidate(userId: userId, location: location) {
                    outputCandidates[location] = OfferEntity(candidate, location: location)
                }
            }
        }
        
        // accounts
        let isAccountEasyPayEnabled = appConfigRepository.getBool(AccountsConstants.appConfigEnableAccountEasyPayForBills) ?? false
        guard isAccountEasyPayEnabled,
            let accountEasyPayLowAmountLimit = appConfigRepository.getDecimal(AccountsConstants.appConfigAccountEasyPayLowAmountLimit),
            let accountEasyPayMinAmount = appConfigRepository.getDecimal(AccountsConstants.appConfigAccountEasyPayMinAmount)
            else {
                return .error(StringErrorOutput(nil))
        }
        let response = try? bsanManagersProvider.getBsanAccountsManager().getAccountEasyPay()
        guard let easyPayResponse = response, easyPayResponse.isSuccess(), let campaignsEasyPay: [AccountEasyPayRepresentable] = try easyPayResponse.getResponseData() else {
            return .error(StringErrorOutput(try response?.getErrorCode()))
        }
        let accountEasyPay = AccountEasyPay(accountEasyPayMinAmount: accountEasyPayMinAmount, accountEasyPayLowAmountLimit: accountEasyPayLowAmountLimit, campaignsEasyPay: campaignsEasyPay)
        
        let accountsCrossSellingParams = AccountsCTAParameters(
            easyPay: accountEasyPay,
            crossSellingEnabled: appConfigRepository.getBool("enableAccountMovementsCrossSelling") == true,
            accountsCrossSelling: accountsCrossSelling
        )
        
        // cards
        let cardsCrossSellingEnabled = CardsCTAParameters(
            easyPayEnabled: appConfigRepository.getBool("enableEasyPayCards") == true,
            crossSellingEnabled: appConfigRepository.getBool("enableCardMovementsCrossSelling") == true,
            cardsCrossSelling: cardsCrossSelling
        )
        
        return UseCaseResponse.ok(
            GetUnreadMovementsUseCaseOkOutput(
                cardMovements: [],
                accountMovements: [],
                accountsCrossSellingParameters: accountsCrossSellingParams,
                cardsCrossSellingParameters: cardsCrossSellingEnabled,
                pullOffersOutputCandidates: outputCandidates,
                cardFractionableMovements: [],
                accountFractionableMovements: []
            ))
    }
}
private extension DefaultGetUnreadMovementsUseCase {
    
    var accountsCrossSelling: [AccountMovementsCrossSellingProperties] {
        let accountsCrossSellingEntity = appConfigRepository
            .getAppConfigListNode(
                "listAccountMovementsCrossSelling",
                object: AccountMovementsCrossSellingEntity.self,
                options: .json5Allowed) ?? []
        
        return accountsCrossSellingEntity
            .map(AccountMovementsCrossSellingProperties.init)
    }

    var cardsCrossSelling: [CardsMovementsCrossSellingProperties] {
        let cardsCrossSelling = appConfigRepository.getAppConfigListNode(
            "listCardMovementsCrossSelling",
            object: CardsMovementsCrossSellingEntity.self,
            options: .json5Allowed) ?? []
        return cardsCrossSelling
            .map(CardsMovementsCrossSellingProperties.init)
    }
 }

public struct GetUnreadMovementsUseCaseOkOutput {
    let cardMovements: [CardTransactionWithCardEntity]
    let accountMovements: [AccountTransactionWithAccountEntity]
    let accountsCrossSellingParameters: AccountsCTAParameters
    let cardsCrossSellingParameters: CardsCTAParameters
    let pullOffersOutputCandidates: [PullOfferLocation: OfferEntity]
    let cardFractionableMovements: [CardTransactionWithCardEntity]
    let accountFractionableMovements: [AccountTransactionWithAccountEntity]
    
    public init(cardMovements: [CardTransactionWithCardEntity],
                accountMovements: [AccountTransactionWithAccountEntity],
                accountsCrossSellingParameters: AccountsCTAParameters,
                cardsCrossSellingParameters: CardsCTAParameters,
                pullOffersOutputCandidates: [PullOfferLocation: OfferEntity],
                cardFractionableMovements: [CardTransactionWithCardEntity],
                accountFractionableMovements: [AccountTransactionWithAccountEntity]) {
        self.cardMovements = cardMovements
        self.accountMovements = accountMovements
        self.accountsCrossSellingParameters = accountsCrossSellingParameters
        self.cardsCrossSellingParameters = cardsCrossSellingParameters
        self.pullOffersOutputCandidates = pullOffersOutputCandidates
        self.cardFractionableMovements = cardFractionableMovements
        self.accountFractionableMovements = accountFractionableMovements
    }
}

public struct GetUnreadMovementsUseCaseInput {
    public let startDate: Date
    public let limit: Int?
}

public struct AccountsCTAParameters {
    let easyPay: AccountEasyPay
    let crossSellingEnabled: Bool
    var accountsCrossSelling: [AccountMovementsCrossSellingProperties]
    
    public init(easyPay: AccountEasyPay, crossSellingEnabled: Bool, accountsCrossSelling: [AccountMovementsCrossSellingProperties]) {
        self.easyPay = easyPay
        self.crossSellingEnabled = crossSellingEnabled
        self.accountsCrossSelling = accountsCrossSelling
    }
}

public struct CardsCTAParameters {
    let easyPayEnabled: Bool?
    let crossSellingEnabled: Bool
    let cardsCrossSelling: [CardsMovementsCrossSellingProperties]
    
    public init(easyPayEnabled: Bool?, crossSellingEnabled: Bool, cardsCrossSelling: [CardsMovementsCrossSellingProperties]) {
        self.easyPayEnabled = easyPayEnabled
        self.crossSellingEnabled = crossSellingEnabled
        self.cardsCrossSelling = cardsCrossSelling
    }
}
