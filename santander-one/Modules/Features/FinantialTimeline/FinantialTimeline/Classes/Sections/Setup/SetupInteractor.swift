//
//  SetupInteractor.swift
//  FinantialTimeline
//
//  Created by Hernán Villamil on 27/09/2019.
//

import Foundation

class SetupInteractor: SetupInteractorProtocol {
    weak var output: SetupInteractorOutput?
    private let repository: TimeLineRepository
    
    init(timeLineRepository: TimeLineRepository) {
        self.repository = timeLineRepository
    }
    
    func fetchCards() {
        repository.fetchCards { [weak self] result in
            switch result {
            case .success(let list):
                self?.output?.onfetchedCards(cardList: list.cards)
            case .failure:
                self?.output?.onFetchCardsDidFail()
            }
        }
    }
    
    func fetchAccounts() {
        repository.fetchAccounts { [weak self] result in
            switch result {
            case .success(let list):
                self?.output?.onFetchedAccounts(accountList: list.accountsDataList)
            case .failure:
                self?.output?.onFetchAccountsDidFail()
            }
        }
    }
}
