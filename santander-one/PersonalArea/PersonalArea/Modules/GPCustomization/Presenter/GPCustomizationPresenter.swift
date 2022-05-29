import CoreFoundationLib
import CoreDomain

protocol GPCustomizationPresenterProtocol {
    var view: GPCustomizationViewProtocol? { get set }
    var isPb: Bool? { get }
    func viewDidLoad()
    func saveConfiguration(for models: [[GPCustomizationProductViewModel]])
    func returnToDefaultConfiguration()
    func didChangedSwitch(_ product: GPCustomizationProductViewModel)
    func didUpdateAlias(_ info: GPCustomizationProductViewModel)
    func didMoveSection(_ section: [GPCustomizationProductViewModel])
    func didMoveProduct(_ product: GPCustomizationProductViewModel)
    func didPressBack(with models: [[GPCustomizationProductViewModel]])
    func didPressClose(with models: [[GPCustomizationProductViewModel]])
    func getProductAlias(for type: ProductTypeEntity) -> ProductAlias?
}

final class GPCustomizationPresenter: GPCustomizationPresenterProtocol {
    private var personalAreaCoordinator: PersonalAreaMainModuleCoordinatorDelegate? {
        return engine.resolve(for: PersonalAreaMainModuleCoordinatorDelegate.self)
    }

    private var baseURLProvider: BaseURLProvider {
        return engine.resolve(for: BaseURLProvider.self)
    }

    private var globalPositionUseCase: GetGlobalPositionUseCase {
        return engine.resolve(for: GetGlobalPositionUseCase.self)
    }

    private var changeAccountAliasUseCase: ChangeAccountAliasUseCase {
        return engine.resolve(for: ChangeAccountAliasUseCase.self)
    }

    private var changeCardAliasUseCase: ChangeCardAliasUseCase {
        return engine.resolve(for: ChangeCardAliasUseCase.self)
    }

    private var updateUserPrefContentUseCase: UpdateUserPrefContentUseCase {
        return engine.resolve(for: UpdateUserPrefContentUseCase.self)
    }

    private var getConfigurationUseCase: GetGPCustomizationConfigurationUseCase {
        return engine.resolve(for: GetGPCustomizationConfigurationUseCase.self)
    }

    private let engine: DependenciesResolver
    private var globalPosition: GlobalPositionWithUserPrefsRepresentable?
    private var defaultModels: [[GPCustomizationProductViewModel]] = []
    private var needsReloadBeforeBack = false
    var isPb: Bool?
    weak var view: GPCustomizationViewProtocol?

    private var localAppConfig: LocalAppConfig {
        self.engine.resolve(for: LocalAppConfig.self)
    }

    init(dependenciesResolver: DependenciesResolver) {
        self.engine = dependenciesResolver
    }

    func viewDidLoad() {
        self.trackScreen()
        reload()
    }
    
    func reload() {
        UseCaseWrapper(
            with: getConfigurationUseCase.setRequestValues(
                requestValues: GetGPCustomizationConfigurationUseCaseInput(dependenciesResolver: engine)),
            useCaseHandler: engine.resolve(for: UseCaseHandler.self),
            onSuccess: { [weak self] (result) in
            self?.setInfo(globalPosition: result.globalPosition, defaultGlobalPosition: result.defaultGlobalPosition)
        })
    }

    // MARK: - Private funcs

    private func setInfo(globalPosition: GlobalPositionWithUserPrefsRepresentable, defaultGlobalPosition: GlobalPositionWithUserPrefsRepresentable) {
        self.globalPosition = globalPosition
        self.isPb = globalPosition.isPb
        let models = createViewModels(for: globalPosition)
        view?.setModels(models)
        defaultModels = createViewModels(for: defaultGlobalPosition)
        view?.isSameAsDefault(!didChangeGP(withModels: models))
    }

    private func createViewModels(for globalPosition: GlobalPositionWithUserPrefsRepresentable?) -> [[GPCustomizationProductViewModel]] {
        guard let globalPosition = globalPosition, let userPref = globalPosition.userPref else { return [] }
        var models: [ProductTypeEntity: [GPCustomizationProductViewModel]] = [:]
        models[.account] = globalPosition.accounts.all().map({ GPCustomizationProductViewModel(product: $0, didUpdateAlias: changeAccountAlias, isEditable: isEditAliasEnabled(.account)) })
        models[.card] = globalPosition.cards.all().map({ GPCustomizationProductViewModel(product: $0, baseUrl: baseURLProvider.baseURL, didUpdateAlias: changeCardAlias, isEditable: isEditAliasEnabled(.card)) })
        models[.savingProduct] = globalPosition.savingProducts.all().map({ GPCustomizationProductViewModel(product: $0, baseUrl: baseURLProvider.baseURL, didUpdateAlias: changeSavingProductAlias, isEditable: isEditAliasEnabled(.savingProduct)) })
        models[.fund] = globalPosition.funds.all().map({ GPCustomizationProductViewModel(product: $0) })
        models[.loan] = globalPosition.loans.all().map({ GPCustomizationProductViewModel(product: $0, didUpdateAlias: changeLoansAlias, isEditable: isEditAliasEnabled(.loan)) })
        models[.stockAccount] = globalPosition.stockAccounts.all().map({ GPCustomizationProductViewModel(product: $0) })
        models[.deposit] = globalPosition.deposits.all().map({ GPCustomizationProductViewModel(product: $0, didUpdateAlias: changeDepositsAlias, isEditable: isEditAliasEnabled(.deposit)) })
        models[.pension] = globalPosition.pensions.all().map({ GPCustomizationProductViewModel(product: $0, didUpdateAlias: changePensionAlias, isEditable: isEditAliasEnabled(.pension)) })
        models[.managedPortfolio] = globalPosition.managedPortfolios.all().map({ GPCustomizationProductViewModel(product: $0, productType: .managedPortfolio) })
        models[.notManagedPortfolio] = globalPosition.notManagedPortfolios.all().map({ GPCustomizationProductViewModel(product: $0, productType: .notManagedPortfolio) })
        models[.insuranceSaving] = globalPosition.insuranceSavings.all().map({ GPCustomizationProductViewModel(product: $0, didUpdateAlias: changeInsuranceSavingAlias, isEditable: isEditAliasEnabled(.insuranceSaving)) })
        models[.insuranceProtection] = globalPosition.protectionInsurances.all().map({ GPCustomizationProductViewModel(product: $0) })
        models[.fund] = globalPosition.funds.all().map({ GPCustomizationProductViewModel(product: $0, didUpdateAlias: changeFundAlias, isEditable: isEditAliasEnabled(.fund)) })

        var viewModels: [[GPCustomizationProductViewModel]] = []
        let boxes: [ProductTypeEntity] = userPref.getBoxesOrder().map({$0.asProductType})

        for boxType in boxes {
            guard let boxContent = models[boxType], !boxContent.isEmpty else { continue }
            viewModels.append(boxContent)
        }

        return viewModels
    }

    private func didChangeGP(withModels models: [[GPCustomizationProductViewModel]]) -> Bool {
        var hasAnyChanges = false
        var index = 0
        while !hasAnyChanges && index < models.count {
            let firstIndex = defaultModels.firstIndex(of: models[index])
            hasAnyChanges = firstIndex == nil || firstIndex != index
            index += 1
        }
        return hasAnyChanges
    }

    private func changeAccountAlias(account: GlobalPositionProduct, newAlias: String?) {
        personalAreaCoordinator?.showLoading(completion: { [weak self] in
            guard let strongSelf = self else { return }
            guard let account = account as? AccountEntity else {
                strongSelf.personalAreaCoordinator?.hideLoading(completion: nil)
                return
            }
            guard !strongSelf.isAliasEmpty(newAlias ?? "", self?.getProductAlias(for: .account)) else {
                return
            }
            UseCaseWrapper(with: strongSelf.changeAccountAliasUseCase.setRequestValues(requestValues: ChangeAccountAliasUseCaseInput(dependenciesResolver: strongSelf.engine, account: account, alias: newAlias)), useCaseHandler: strongSelf.engine.resolve(for: UseCaseHandler.self), onSuccess: {
                self?.onSuccessChangeAlias()
            }, onError: { [weak self] error in
                self?.onErrorChangeAlias(error: error)
            })
        })
    }

    private func changeCardAlias(card: GlobalPositionProduct, newAlias: String?) {
        personalAreaCoordinator?.showLoading(completion: { [weak self] in
            guard let strongSelf = self else { return }
            guard let card = card as? CardEntity else {
                strongSelf.personalAreaCoordinator?.hideLoading(completion: nil)
                return
            }
            guard !strongSelf.isAliasEmpty(newAlias ?? "", self?.getProductAlias(for: .card)) else {
                return
            }
            UseCaseWrapper(with: strongSelf.changeCardAliasUseCase.setRequestValues(requestValues: ChangeCardAliasUseCaseInput(dependenciesResolver: strongSelf.engine, card: card, alias: newAlias)), useCaseHandler: strongSelf.engine.resolve(for: UseCaseHandler.self), onSuccess: {
                self?.personalAreaCoordinator?.hideLoading(completion: {})
                self?.needsReloadBeforeBack = true
            }, onError: { [weak self] error in
                self?.onErrorChangeAlias(error: error)
            })
        })
    }

    func dismiss() {
        self.view?.navigationController?.popViewController(animated: true)
    }
    
    func isAliasEmpty(_ newAlias: String, _ aliasConfiguration: ProductAlias?) -> Bool {
        guard let aliasConfiguration = aliasConfiguration else {
            return false
        }
        guard !newAlias.isEmpty else {
            let max = StringPlaceholder(.value, "\(aliasConfiguration.maxChars)")
            let text: LocalizedStylableText = localized("productsOrder_alert_aliasValue", [max])
            self.personalAreaCoordinator?.hideLoading(completion: {
                self.personalAreaCoordinator?.showAlertDialog(acceptTitle: localized("generic_button_accept"), cancelTitle: nil, title: nil, body: text, acceptAction: nil, cancelAction: nil)
            })
            return true
        }
        return false
    }

    // MARK: - GPCustomizationPresenterProtocol

    func saveConfiguration(for models: [[GPCustomizationProductViewModel]]) {
        self.trackEvent(.save, parameters: [:])
        self.personalAreaCoordinator?.startCustomLoading(completion: { [weak self] in
            guard let strongSelf = self else { return }

            guard let userPref = strongSelf.globalPosition?.userPref else {
                strongSelf.personalAreaCoordinator?.hideLoading(completion: nil)
                return
            }

            UseCaseWrapper(with: strongSelf.updateUserPrefContentUseCase.setRequestValues(requestValues: UpdateUserPrefContentUseCaseInput(dependenciesResolver: strongSelf.engine, userPref: userPref, globalPosition: models)), useCaseHandler: strongSelf.engine.resolve(for: UseCaseHandler.self), onSuccess: { [weak self] _ in
                self?.personalAreaCoordinator?.globalPositionDidReload()
            })
        })
    }

    func returnToDefaultConfiguration() {
        self.personalAreaCoordinator?.startGlobalLoading(completion: { [weak self] in
            guard let strongSelf = self else { return }

            guard let userPref = strongSelf.globalPosition?.userPref else {
                strongSelf.personalAreaCoordinator?.hideLoading(completion: nil)
                return
            }

            UseCaseWrapper(with: strongSelf.updateUserPrefContentUseCase.setRequestValues(requestValues: UpdateUserPrefContentUseCaseInput(dependenciesResolver: strongSelf.engine, userPref: userPref, globalPosition: strongSelf.defaultModels)), useCaseHandler: strongSelf.engine.resolve(for: UseCaseHandler.self), onSuccess: { [weak self] _ in
                self?.personalAreaCoordinator?.globalPositionDidReload()
            })
        })
    }

    func didChangedSwitch(_ product: GPCustomizationProductViewModel) {
        guard
            let productType = product.productType,
            let action = trackerPage.changedSwitchTrackAction(type: productType,
                                                              isVisible: product.isVisible)
            else { return }
        self.trackEvent(action, parameters: [:])
    }

    func didUpdateAlias(_ info: GPCustomizationProductViewModel) {
        if info.productType == ProductTypeEntity.account {
            self.trackEvent(.accountEditAlias, parameters: [:])
        } else if info.productType == ProductTypeEntity.card {
            self.trackEvent(.cardEditAlias, parameters: [:])
        } else if info.productType == ProductTypeEntity.savingProduct {
            self.trackEvent(.savingProductEditAlias, parameters: [:])
        }
    }

    func didMoveSection(_ section: [GPCustomizationProductViewModel]) {
        guard
            let product = section.first,
            let productType = product.productType,
            let trackAction = trackerPage.moveSectionTrackAction(type: productType)
            else { return }
        self.trackEvent(trackAction, parameters: [:])
    }

    func didMoveProduct(_ product: GPCustomizationProductViewModel) {
        guard
            let productType = product.productType,
            let trackAction = trackerPage.moveTrackAction(type: productType)
            else { return }
        self.trackEvent(trackAction, parameters: [:])
    }

    func didPressBack(with models: [[GPCustomizationProductViewModel]]) {
        guard needsReloadBeforeBack else { return dismiss() }
        saveConfiguration(for: models)
    }

    func didPressClose(with models: [[GPCustomizationProductViewModel]]) {
        guard needsReloadBeforeBack else { return dismiss() }
        saveConfiguration(for: models)
    }

    func getProductAlias(for type: ProductTypeEntity) -> ProductAlias? {
        engine.resolve(forOptionalType: ProductAliasManagerProtocol.self)?.getProductAlias(for: type)
    }
}

extension GPCustomizationPresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return self.engine.resolve(for: TrackerManager.self)
    }

    var trackerPage: PersonalAreaConfigurationPGProductPage {
        return PersonalAreaConfigurationPGProductPage()
    }
}

private extension GPCustomizationPresenter {
    func changeDepositsAlias(_ deposit: GlobalPositionProduct, newAlias: String?) {
        personalAreaCoordinator?.showLoading(completion: { [weak self] in
            guard let strongSelf = self,
                  let deposit = deposit as? DepositEntity else {
                self?.personalAreaCoordinator?.hideLoading(completion: nil)
                return
            }
            guard !strongSelf.isAliasEmpty(newAlias ?? "", self?.getProductAlias(for: .deposit)) else {
                return
            }
            
            let useCase = ChangeDepositAliasUseCase(dependenciesResolver: strongSelf.engine)
            let input = ChangeDepositAliasUseCaseInput(deposit: deposit,
                                                       alias: newAlias)
            Scenario(useCase: useCase, input: input)
                .execute(on: strongSelf.engine.resolve())
                .onSuccess { [weak self] _ in
                    self?.onSuccessChangeAlias()
                }
                .onError { [weak self] error in
                    self?.onErrorChangeAlias(error: error)
                }
        })
    }

    func changeLoansAlias(_ loan: GlobalPositionProduct, newAlias: String?) {
        personalAreaCoordinator?.showLoading(completion: { [weak self] in
            guard let strongSelf = self,
                  let loan = loan as? LoanEntity else {
                self?.personalAreaCoordinator?.hideLoading(completion: nil)
                return
            }
            guard !strongSelf.isAliasEmpty(newAlias ?? "", self?.getProductAlias(for: .loan)) else {
                return
            }
            
            let useCase = ChangeLoansAliasUseCase(dependenciesResolver: strongSelf.engine)
            let input = ChangeLoansAliasUseCaseInput(loan: loan,
                                                       alias: newAlias)
            Scenario(useCase: useCase, input: input)
                .execute(on: strongSelf.engine.resolve())
                .onSuccess { [weak self] _ in
                    self?.onSuccessChangeAlias()
                }
                .onError { [weak self] error in
                    self?.onErrorChangeAlias(error: error)
                }
        })
    }

    func changePensionAlias(_ pension: GlobalPositionProduct, newAlias: String?) {
        personalAreaCoordinator?.showLoading(completion: { [weak self] in
            guard let strongSelf = self,
                  let pension = pension as? PensionEntity else {
                self?.personalAreaCoordinator?.hideLoading(completion: nil)
                return
            }
            guard !strongSelf.isAliasEmpty(newAlias ?? "", self?.getProductAlias(for: .pension)) else {
                return
            }
            
            let useCase = ChangePensionsAliasUseCase(dependenciesResolver: strongSelf.engine)
            let input = ChangePensionsAliasUseCaseInput(pension: pension,
                                                       alias: newAlias)
            Scenario(useCase: useCase, input: input)
                .execute(on: strongSelf.engine.resolve())
                .onSuccess { [weak self] _ in
                    self?.onSuccessChangeAlias()
                }
                .onError { error in
                    self?.onErrorChangeAlias(error: error)
                }
        })
    }

    func changeInsuranceSavingAlias(_ insurance: GlobalPositionProduct, newAlias: String?) {
        personalAreaCoordinator?.showLoading(completion: { [weak self] in
            guard let strongSelf = self,
                  let insurance = insurance as? InsuranceSavingEntity else {
                self?.personalAreaCoordinator?.hideLoading(completion: nil)
                return
            }
            guard !strongSelf.isAliasEmpty(newAlias ?? "", self?.getProductAlias(for: .insuranceSaving)) else {
                return
            }
            let useCase = ChangeInsuranceSavingAliasUseCase(dependenciesResolver: strongSelf.engine)
            let input = ChangeInsuranceSavingAliasUseCaseInput(insuranceSaving: insurance, alias: newAlias)
            Scenario(useCase: useCase, input: input)
                .execute(on: strongSelf.engine.resolve())
                .onSuccess { [weak self] _ in
                    self?.onSuccessChangeAlias()
                }
                .onError { error in
                    self?.onErrorChangeAlias(error: error)
                }
        })
    }

    private func changeFundAlias(fund: GlobalPositionProduct, newAlias: String?) {
        personalAreaCoordinator?.showLoading(completion: { [weak self] in
            guard let strongSelf = self,
                  let fund = fund as? FundEntity else {
                      self?.personalAreaCoordinator?.hideLoading(completion: nil)
                      return
                  }
            guard !strongSelf.isAliasEmpty(newAlias ?? "", self?.getProductAlias(for: .fund)) else {
                return
            }
            let useCase = ChangeFundAliasUseCase()
            let input = ChangeFundAliasUseCaseInput(dependenciesResolver: strongSelf.engine, fund: fund, alias: newAlias)
            Scenario(useCase: useCase, input: input)
                .execute(on: strongSelf.engine.resolve())
                .onSuccess { [weak self] _ in
                    self?.onSuccessChangeAlias()
                }
                .onError { error in
                    self?.onErrorChangeAlias(error: error)
                }
        })
    }

    func changeSavingProductAlias(_ savingProduct: GlobalPositionProduct, newAlias: String?) {
        view?.showComingSoon()
    }

    func onSuccessChangeAlias() {
        self.personalAreaCoordinator?.hideLoading(completion: {})
        self.needsReloadBeforeBack = true
    }

    func onErrorChangeAlias(error: UseCaseError<StringErrorOutput>) {
        self.personalAreaCoordinator?.hideLoading(completion: { [weak self] in
            self?.personalAreaCoordinator?.showAlertDialog(acceptTitle: localized("generic_button_accept"),
                                                          cancelTitle: nil,
                                                          title: nil,
                                                          body: localized(error.getErrorDesc() ?? ""),
                                                           acceptAction: self?.reload,
                                                           cancelAction: self?.reload)
        })
    }

    func isEditAliasEnabled(_ product: ProductTypeEntity) -> Bool {
        return localAppConfig.enabledChangeAliasProducts.contains(product)
    }
}
