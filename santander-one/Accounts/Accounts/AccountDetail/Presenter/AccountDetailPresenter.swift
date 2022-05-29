//
//  AccountDetailPresenter.swift
//  Account
//
//  Created by Cristobal Ramos Laina on 05/02/2021.
//

import Foundation
import CoreFoundationLib
import SANLegacyLibrary

protocol AccountDetailPresenterProtocol: AnyObject, MenuTextWrapperProtocol {
    var view: AccountDetailViewProtocol? { get set }
    func viewDidLoad()
    func dismiss()
    func didSelectMenu()
    func didTapOnShareViewModel(_ viewModel: AccountDetailDataViewModel)
    func didTapOnEditViewModel(accountViewModel: AccountDetailDataViewModel, alias: String)
    func didTapOnSwitch()
}

final class AccountDetailPresenter {
    weak var view: AccountDetailViewProtocol?
    let dependenciesResolver: DependenciesResolver
    let accountDetailConfiguration: AccountDetailConfiguration
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.accountDetailConfiguration =  self.dependenciesResolver.resolve(for: AccountDetailConfiguration.self)
    }
    var coordinator: AccountDetailCoordinatorProtocol {
        self.dependenciesResolver.resolve(for: AccountDetailCoordinatorProtocol.self)
    }
    
    var accountsCoordinator: AccountsHomeCoordinator {
        self.dependenciesResolver.resolve(for: AccountsHomeCoordinator.self)
    }
    
    var changeAliasDetailUseCase: ChangeAliasDetailUseCaseProtocol {
        self.dependenciesResolver.resolve(for: ChangeAliasDetailUseCaseProtocol.self)
    }
    
    var getAccountDetailUseCase: GetAccountDetailUseCase {
        self.dependenciesResolver.resolve(for: GetAccountDetailUseCase.self)
    }
    
    var useCaseHandler: UseCaseHandler {
        return self.dependenciesResolver.resolve(for: UseCaseHandler.self)
    }
    
    var changeAccountMainUseCase: ChangeAccountMainUseCaseAlias {
        self.dependenciesResolver.resolve(for: ChangeAccountMainUseCaseAlias.self)
    }
    
    func reloadGlobalPosition() {
        let globalPositionReloader = self.dependenciesResolver.resolve(for: GlobalPositionReloader.self)
        globalPositionReloader.reloadGlobalPosition()
    }
}

extension AccountDetailPresenter: AccountDetailPresenterProtocol {
    func didTapOnSwitch() {
        self.view?.showLoading()
        Scenario(useCase: changeAccountMainUseCase, input: ChangeAccountMainUseCaseInput(account: self.accountDetailConfiguration.accountEntity, main: true))
            .execute(on: self.useCaseHandler)
            .onSuccess { [weak self] _ in
                guard let self = self else { return }
                self.reloadGlobalPosition()
                self.view?.dismissLoading { [weak self] in
                    guard let self = self else { return }
                    self.view?.showActivatedMainView("pt_accountDetail_text_selectedMainAccount")
                }
            }
            .onError { [weak self] _ in
                guard let self = self else { return }
                self.view?.dismissLoading { [weak self] in
                    guard let self = self else { return }
                    self.view?.showMainAccountDialog()
                }
            }
    }
    
    func didTapOnShareViewModel(_ viewModel: AccountDetailDataViewModel) {
        self.coordinator.doShare(for: viewModel)
    }
    
    func didTapOnEditViewModel(accountViewModel: AccountDetailDataViewModel, alias: String) {
        self.view?.showLoading { [weak self] in
            guard let self = self else { return }
            Scenario(useCase: self.changeAliasDetailUseCase, input: ChangeAliasDetailUseCaseInput(account: accountViewModel.accountEntity, alias: alias))
                .execute(on: self.useCaseHandler)
                .onSuccess { [weak self] _ in
                    guard let self = self else { return }
                    self.reloadGlobalPosition()
                    self.view?.setUpAccountName(alias)
                    self.view?.dismissLoading { [weak self] in
                        guard let self = self else { return }
                        self.view?.showAliasChangedView(isError: false, subtitle: "accountDetail_label_aliasChanged")
                    }
                }
                .onError { _ in
                    self.view?.dismissLoading { [weak self] in
                        guard let self = self else { return }
                        self.view?.showAliasDialog()
                    }
                }
        }
    }
    
    func viewDidLoad() {
        self.trackScreen()
        self.view?.showLoading()
        Scenario(useCase: getAccountDetailUseCase, input: GetAccountDetailUseCaseInput(account: self.accountDetailConfiguration.accountEntity))
            .execute(on: self.useCaseHandler)
            .onSuccess { response in
                self.view?.dismissLoading { [weak self] in
                    guard let self = self else { return }
                    let accountDetailDataViewModel = AccountDetailDataViewModel(accountEntity: self.accountDetailConfiguration.accountEntity, accountDetailEntity: response.detail, holder: response.holder, dependenciesResolver: self.dependenciesResolver)
                    self.view?.setupViews(viewModel: accountDetailDataViewModel)
                }
            }
            .onError { _ in
                self.view?.dismissLoading { [weak self] in
                    guard let self = self else { return }
                    self.view?.showError()
                }
            }
    }
    
    @objc func dismiss() {
        self.coordinator.dismiss()
    }
    
    func didSelectMenu() {
        self.accountsCoordinator.didSelectMenu()
    }
}

extension AccountDetailPresenter: AutomaticScreenTrackable {
    var trackerPage: AccountDetailPage {
        AccountDetailPage()
    }
    var trackerManager: TrackerManager {
        dependenciesResolver.resolve(for: TrackerManager.self)
    }
}
