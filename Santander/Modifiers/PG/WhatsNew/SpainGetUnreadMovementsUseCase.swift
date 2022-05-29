//
//  SpainGetUnreadMovementsUseCase.swift
//  Santander
//
//  Created by Hernán Villamil on 10/3/22.
//

import CoreFoundationLib
import SANLegacyLibrary
import CoreDomain
import GlobalPosition
import OpenCombine

final class SpainGetUnreadMovementsUseCase: UseCase<GetUnreadMovementsUseCaseInput, GetUnreadMovementsUseCaseOkOutput, StringErrorOutput> {
    let dependenciesResolver: DependenciesResolver
    var subscriptions: Set<AnyCancellable> = []
    let pfmController: PfmControllerProtocol
    private let setReadAccountTransactionsUseCase: SetReadAccountTransactionsUseCase
    private var setReadCardTransactionsUseCase: SetReadCardTransactionsUseCase
    private let useCaseHandler: UseCaseHandler
    private var merger: GlobalPositionPrefsMergerEntity
    private let bsanManagersProvider: BSANManagersProvider
    private var locations: [PullOfferLocation] {
        return PullOffersLocationsFactoryEntity().accountsTransactionDetail
    }
    private var globalPosition: GlobalPositionRepresentable
    private let appConfigRepository: AppConfigRepositoryProtocol
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        globalPosition = dependenciesResolver.resolve(for: GlobalPositionRepresentable.self)
        self.merger = GlobalPositionPrefsMergerEntity(resolver: dependenciesResolver, globalPosition: globalPosition, saveUserPreferences: false)
        self.bsanManagersProvider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
        self.appConfigRepository = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
        self.setReadAccountTransactionsUseCase = self.dependenciesResolver.resolve(for: SetReadAccountTransactionsUseCase.self)
        self.setReadCardTransactionsUseCase = self.dependenciesResolver.resolve(for: SetReadCardTransactionsUseCase.self)
        self.useCaseHandler = self.dependenciesResolver.resolve(for: UseCaseHandler.self)
        self.pfmController = self.dependenciesResolver.resolve(for: PfmControllerProtocol.self)
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
        
        guard let userCodeType = globalPosition.userCodeType else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        let pfm: PfmHelperProtocol = dependenciesResolver.resolve(for: PfmHelperProtocol.self)
        let cards = merger.cards
            .visibles()
            .filter({$0.isCardContractHolder})
        
        let accounts = merger.accountsVisiblesWithoutPiggy
            .filter({$0.isAccountHolder()})
        
        let unreadTransactions = getUnreadTransactions(pfm, userId: userCodeType, requestValues: requestValues, cards: cards, accounts: accounts)
        let fractionableTransactions = getFractionableTransactions(pfm, userId: userCodeType, cards: cards, accounts: accounts)
        cards.forEach({wait(untilFinished: $0)})
        accounts.forEach({wait(untilFinished: $0)})
        return UseCaseResponse.ok(
            GetUnreadMovementsUseCaseOkOutput(
                cardMovements: unreadTransactions.cards,
                accountMovements: unreadTransactions.accounts,
                accountsCrossSellingParameters: accountsCrossSellingParams,
                cardsCrossSellingParameters: cardsCrossSellingEnabled,
                pullOffersOutputCandidates: outputCandidates,
                cardFractionableMovements: fractionableTransactions.cards,
                accountFractionableMovements: fractionableTransactions.accounts
            ))
    }
}
private extension SpainGetUnreadMovementsUseCase {
    
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
    
    func getUnreadTransactions(_ pfm: PfmHelperProtocol, userId: String, requestValues: GetUnreadMovementsUseCaseInput, cards: [CardEntity], accounts: [AccountEntity]) -> (cards: [CardTransactionWithCardEntity], accounts: [AccountTransactionWithAccountEntity]) {
        var unreadCardMovements: [CardTransactionWithCardEntity] = [CardTransactionWithCardEntity]()
        var unreadAccountMovements: [AccountTransactionWithAccountEntity] = [AccountTransactionWithAccountEntity]()
        // unread cards
        cards.forEach { (cardEntity) in
            let unreadMovements = pfm.getUnreadCardMovementsFor(userId: userId,
                                                                startDate: requestValues.startDate,
                                                                card: cardEntity,
                                                                limit: requestValues.limit)
            let cardTransactionsWithEntity = unreadMovements.map({ cardMovement ->  CardTransactionWithCardEntity in
                let transactionWithEntity = CardTransactionWithCardEntity(cardTransactionEntity: cardMovement,
                                                                          cardEntity: cardEntity)
                return transactionWithEntity
            })
            unreadCardMovements.append(contentsOf: cardTransactionsWithEntity)
        }
        // unread accounts
        accounts.forEach { (accountEntity) in
            let unreadMovements = pfm.getUnreadAccountMovementsFor(userId: userId,
                                                                   startDate: requestValues.startDate,
                                                                   account: accountEntity,
                                                                   limit: requestValues.limit)
            let accountTransactionsWithEntity = unreadMovements.map({ accountMovement -> AccountTransactionWithAccountEntity in
                let transactionWithEntity = AccountTransactionWithAccountEntity(accountTransactionEntity: accountMovement, accountEntity: accountEntity)
                return transactionWithEntity
            })
            unreadAccountMovements.append(contentsOf: accountTransactionsWithEntity)
        }
        return (unreadCardMovements, unreadAccountMovements)
    }
    
    func getFractionableTransactions(
        _ pfm: PfmHelperProtocol,
        userId: String,
        cards: [CardEntity],
        accounts: [AccountEntity]) -> (cards: [CardTransactionWithCardEntity],
                                       accounts: [AccountTransactionWithAccountEntity]) {
        var cardTransactions: [CardTransactionWithCardEntity] = [CardTransactionWithCardEntity]()
        var accountTransactions: [AccountTransactionWithAccountEntity] = [AccountTransactionWithAccountEntity]()
        let startDate = Date().startOfDay().getUtcDate()?.addDay(days: -59) ?? Date()
        let endDate = Date().addDay(days: 1).startOfDay().getUtcDate() ?? Date()
        // all cards
        cards.forEach { (cardEntity) in
            let allCardsTransactions = pfm.getLastMovementsFor(userId: userId,
                                                               card: cardEntity,
                                                               startDate: startDate,
                                                               endDate: endDate)
            let cardTransactionsWithEntity = allCardsTransactions.map({ cardMovement ->  CardTransactionWithCardEntity in
                let transactionWithEntity = CardTransactionWithCardEntity(cardTransactionEntity: cardMovement,
                                                                          cardEntity: cardEntity)
                return transactionWithEntity
            })
            cardTransactions.append(contentsOf: cardTransactionsWithEntity)
        }
        // all accounts
        accounts.forEach { (accountEntity) in
            let allAccountsTransactions = pfm.getMovementsFor(userId: userId,
                                                              date: startDate,
                                                              account: accountEntity)
            let accountTransactionsWithEntity = allAccountsTransactions.map({ accountMovement -> AccountTransactionWithAccountEntity in
                let transactionWithEntity = AccountTransactionWithAccountEntity(accountTransactionEntity: accountMovement, accountEntity: accountEntity)
                return transactionWithEntity
            })
            accountTransactions.append(contentsOf: accountTransactionsWithEntity)
        }
        return (cardTransactions, accountTransactions)
    }
}

extension SpainGetUnreadMovementsUseCase: GetUnreadMovementsUseCase, CardPFMWaiter, AccountPFMWaiter {}
