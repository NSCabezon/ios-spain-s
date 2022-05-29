//
//  SetupProtocols.swift
//  FinantialTimeline
//
//  Created by Hernán Villamil on 27/09/2019.
//

import Foundation

// MARK: - View
protocol SetupViewProtocol: AnyObject {
    func show(cardList: [Product])
    func show(accountList: [Product])
}

// MARK: - Interactor
protocol SetupInteractorProtocol: AnyObject {
    func fetchCards()
    func fetchAccounts()
}

// MARK: - Presenter
protocol SetupPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didSelectBack()
    func getTransactionTypes() -> [TimeLineConfiguration.Text]
    func updateBlackList(accountList: [Product]?, cardList: [Product]?, eventTypeList: [TimeLineConfiguration.Text]?, maxDate: Int?, minDate: Int?, onlyFuture: Bool?)
    func saveBlackList()
}

// MARK: - Router
protocol SetupRouterProtocol: AnyObject {
    func dismiss()
}

protocol SetupInteractorOutput: AnyObject {
    func onfetchedCards(cardList: [Product])
    func onFetchCardsDidFail()
    func onFetchedAccounts(accountList: [Product])
    func onFetchAccountsDidFail()
}

// MARK: - Delegate
protocol SetupDelegate: AnyObject {
}
