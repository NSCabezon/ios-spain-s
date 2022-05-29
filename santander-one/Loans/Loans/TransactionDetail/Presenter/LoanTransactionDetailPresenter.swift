//
//  LoanTransactionDetailPresenter.swift
//  Account
//
//  Created by Ernesto Fernandez Calles on 19/8/21.
//

import CoreFoundationLib

protocol LoanTransactionDetailPresenterProtocol: AnyObject, MenuTextWrapperProtocol {
    var view: LoanTransactionDetailViewProtocol? { get set }
    func viewDidLoad()
    func dismiss()
    func didSelectMenu()
    func didSelectTransaction(_ transaction: OldLoanTransactionDetailViewModel)
}

final class LoanTransactionDetailPresenter {
    weak var view: LoanTransactionDetailViewProtocol?
    
    let dependenciesResolver: DependenciesResolver
    private var coordinator: LoanTransactionDetailCoordinator {
        self.dependenciesResolver.resolve(for: LoanTransactionDetailCoordinator.self)
    }
    private var timeManager: TimeManager {
        self.dependenciesResolver.resolve(for: TimeManager.self)
    }
    private var transactionDetailUseCase: LoanTransactionDetailUseCaseProtocol {
        self.dependenciesResolver.resolve(firstTypeOf: LoanTransactionDetailUseCaseProtocol.self)
    }
    private var configuration: LoanTransactionDetailConfiguration
    private var loan: LoanEntity {
        self.configuration.selectedLoan
    }
    private var transactions: [LoanTransactionEntity] {
        self.configuration.allTransactions
    }
    private var transactionDetails: [LoanTransactionEntity: LoanTransactionDetailEntity]
    private var selectedTransaction: LoanTransactionEntity
    private var useCaseHandler: UseCaseHandler {
        return self.dependenciesResolver.resolve(for: UseCaseHandler.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.configuration =  self.dependenciesResolver.resolve(for: LoanTransactionDetailConfiguration.self)
        self.selectedTransaction = self.configuration.selectedTransaction
        self.transactionDetails = [:]
    }
}

extension LoanTransactionDetailPresenter: LoanTransactionDetailPresenterProtocol {
    func viewDidLoad() {
        self.loadTransactions()
        self.loadTransactionDetail()
        self.showActions()
    }
    
    func dismiss() {
        self.coordinator.dismiss()
    }
    
    func didSelectMenu() {
        self.coordinator.didSelectMenu()
    }

    func didSelectTransaction(_ transaction: OldLoanTransactionDetailViewModel) {
        self.selectedTransaction = transaction.transaction
        self.loadTransactionDetail()
    }
}

private extension LoanTransactionDetailPresenter {
    
    func loadTransactions() {
        let viewModels = self.transactions.map { viewModelFor(transaction: $0) }
        let selectedTransactionViewModel = viewModelFor(transaction: selectedTransaction)
        self.view?.showTransactions(viewModels, withSelected: selectedTransactionViewModel)
    }
    
    func loadTransactionDetail() {
        if let detail = self.transactionDetails[self.selectedTransaction] {
            self.loadTransactionDetail(with: detail)
            return
        }
        Scenario(useCase: self.transactionDetailUseCase, input: LoanTransactionDetailUseCaseInput(loan: self.loan, transaction: self.selectedTransaction))
            .execute(on: self.useCaseHandler)
            .onSuccess { [weak self] response in
                guard let self = self else { return }
                self.transactionDetails[self.selectedTransaction] = response.detail
                self.loadTransactionDetail(with: response.detail)
            }
    }

    func loadTransactionDetail(with detail: LoanTransactionDetailEntity) {
        let transactionViewModel = self.viewModelFor(transaction: self.selectedTransaction, detail: detail)
        self.view?.updateTransaction(with: transactionViewModel)
        self.showActions()
    }
    
    func viewModelFor(transaction: LoanTransactionEntity, detail: LoanTransactionDetailEntity? = nil) -> OldLoanTransactionDetailViewModel {
        return OldLoanTransactionDetailViewModel(transaction: transaction, loan: configuration.selectedLoan, transactionDetail: detail, timeManager: self.timeManager, dependenciesResolver: self.dependenciesResolver)
    }
    
    func showActions() {
        let transactionDetail = self.transactionDetails[self.selectedTransaction]
        let viewModel = self.viewModelFor(transaction: self.selectedTransaction, detail: transactionDetail)
        let actions = LoanTransactionDetailActionFactory.getLoanTransactionDetailActionForViewModel(
            viewModel: viewModel,
            entity: self.loan,
            dependenciesResolver: self.dependenciesResolver,
            action: { action, entity in
                self.coordinator.didSelectAction(action, transaction: self.selectedTransaction.representable, loan: entity.representable)
            })
        self.view?.showActions(actions)
    }
}
