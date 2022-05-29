//
//  SetupPresenter.swift
//  FinantialTimeline
//
//  Created by Hernán Villamil on 27/09/2019.
//

import Foundation

class SetupPresenter {
    weak private var view: SetupViewProtocol?
    private let router: SetupRouterProtocol
    private let textEngine: TextsEngine
    private let interactor: SetupInteractorProtocol
    
    private var blackList = BlackList()
    private let delegate: TimeLineDetailDelegate
    
    init(view: SetupViewProtocol, interactor: SetupInteractorProtocol, router: SetupRouterProtocol, textEngine: TextsEngine, delegate: TimeLineDetailDelegate) {
        self.view = view
        self.router = router
        self.textEngine = textEngine
        self.interactor = interactor
        self.delegate = delegate
    }
}

extension SetupPresenter: SetupPresenterProtocol {
    func viewDidLoad() {
        loadProducts()
    }
    
    func didSelectBack() {
        router.dismiss()
    }
    
    func getTransactionTypes() -> [TimeLineConfiguration.Text] {
        return textEngine.getAllTransactionText()
    }
    
    func loadProducts() {
        interactor.fetchAccounts()
        interactor.fetchCards()
    }
    
    func updateBlackList(accountList: [Product]?, cardList: [Product]?, eventTypeList: [TimeLineConfiguration.Text]?, maxDate: Int?, minDate: Int?, onlyFuture: Bool?) {
        if let updatedAccountList = accountList {
            self.blackList.accountCodes = updatedAccountList
        }
        
        if let updatedCardList = cardList {
            self.blackList.cardCodes = updatedCardList
        }
        
        if let updatedEventTypeList = eventTypeList {
            self.blackList.eventTypeCodes = updatedEventTypeList
        }
        
        if let minimum = minDate {
            self.blackList.minNumberOfMonths = minimum
        }
        
        if let maximun = maxDate {
            self.blackList.maxNumberOfMonths = maximun
        }
        
        if let future = onlyFuture {
            self.blackList.onlyFuture = future
        }
    }
    
    func saveBlackList() {
        SecureStorageHelper.saveBlackList(blackList)
        didSelectBack()
        delegate.didTappedBack()
    }
}

extension SetupPresenter: SetupInteractorOutput {
    func onfetchedCards(cardList: [Product]) {
        view?.show(cardList: cardList)
    }
    
    func onFetchCardsDidFail() {
        view?.show(cardList: [])
    }
    
    func onFetchedAccounts(accountList: [Product]) {
        view?.show(accountList: accountList)
    }
    
    func onFetchAccountsDidFail() {
        view?.show(accountList: [])
    }
}
