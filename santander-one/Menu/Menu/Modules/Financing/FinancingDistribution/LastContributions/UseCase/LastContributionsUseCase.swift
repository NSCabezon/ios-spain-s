//
//  LastContributionsUseCase.swift
//  Menu
//
//  Created by Ignacio González Miró on 03/09/2020.
//

import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class LastContributionsUseCase: UseCase<Void, GetLastContributionsUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private var provider: BSANManagersProvider {
         return self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    private var baseURLProvider: BaseURLProvider {
        return dependenciesResolver.resolve(for: BaseURLProvider.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetLastContributionsUseCaseOkOutput, StringErrorOutput> {
        let globalPosition = self.dependenciesResolver.resolve(for: GlobalPositionWithUserPrefsRepresentable.self)
        let cardsList = globalPosition.cards.visibles().filter({ $0.isCreditCard && $0.isCardContractHolder })
        let loansList = globalPosition.loans.visibles()
        let cards = loadCards(cardsList)
        let loans = loadLoans(loansList)
        return .ok(GetLastContributionsUseCaseOkOutput(lastContributions: (cards: cards, loans: loans)))
    }
}

private extension LastContributionsUseCase {
    func loadCards(_ cardsList: [CardEntity]) -> [LastContributionsCardsEntity] {
        var cards = [LastContributionsCardsEntity]()
        cardsList.forEach { (item) in
            guard let response = try? provider.getBsanCardsManager().getPaymentChange(cardDTO: item.dto) else { return }
            let baseURL = self.baseURLProvider.baseURL ?? ""
            let urlImage = baseURL + item.buildImageRelativeUrl(miniature: false)
            let detailDTO = try? response.getResponseData()
            let detailDtoResponse: ChangePaymentDTO? = response.isSuccess() ? detailDTO : nil
            let card = LastContributionsCardsEntity(
                item.dto,
                changePaymentsDTO: detailDtoResponse,
                cardBalanceDTO: item.cardBalanceDTO,
                urlImage: urlImage)
            cards.append(card)
        }
        return cards
    }
    
    func loadLoans(_ loansList: [LoanEntity]) -> [LastContributionsLoansEntity] {
        var loans = [LastContributionsLoansEntity]()
        loansList.forEach { (item) in
            guard let response = try? provider.getBsanLoansManager().getLoanDetail(forLoan: item.dto) else { return }
            let detailDTO = try? response.getResponseData()
            let detailDtoResponse: LoanDetailDTO? = response.isSuccess() ? detailDTO : nil
            let loan = LastContributionsLoansEntity(item.dto, detailDTO: detailDtoResponse)
            loans.append(loan)
        }
        return loans
    }
}

struct GetLastContributionsUseCaseOkOutput {
    let lastContributions: (cards: [LastContributionsCardsEntity], loans: [LastContributionsLoansEntity])
}
