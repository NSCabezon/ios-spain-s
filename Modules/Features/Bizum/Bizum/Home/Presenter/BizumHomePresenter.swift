//
//  BizumHomePresenter.swift
//  Bizum
//
//  Created by Carlos Gutiérrez Casado on 08/09/2020.
//

import CoreFoundationLib
import Operative

protocol BizumHomePresenterProtocol: MenuTextWrapperProtocol {
    var view: BizumHomeViewProtocol? { get set }
    func viewDidLoad()
    func didSelectMenu()
    func didSelectDismiss()
    func didSelectSearch()
    func didSelectNewSend()
    func didSelectNewRequest()
    func didSelectSettings()
    func didSelectRecents()
    func didSelectRecentsList()
    func didSelectOperation(_ identifier: String?)
    func didSelectContact(_ contact: BizumHomeContactViewModel)
    func didSelectVirtualAssistant()
    func didSelectOption(_ option: BizumHomeOptionViewModel?)
    func didSelectSearchContact()
    func didAllowPermission()
    func didSelectKnowMoreOfShopping()
    func trackFaqEvent(_ question: String, url: URL?)
}

final class BizumHomePresenter {
    weak var view: BizumHomeViewProtocol?
    let dependenciesResolver: DependenciesResolver
    private var selectedAccount: AccountEntity?
    private let bizumCheckPaymentEntity: BizumCheckPaymentEntity
    private var operationEntities: [String: BizumOperationEntity] = [:]
    private var pullOfferCandidates: [PullOfferLocation: OfferEntity]?
    private let locations: [PullOfferLocation] = PullOffersLocationsFactoryEntity().bizumHome
    
    init(dependenciesResolver: DependenciesResolver, bizumCheckPaymentEntity: BizumCheckPaymentEntity) {
        self.dependenciesResolver = dependenciesResolver
        self.bizumCheckPaymentEntity = bizumCheckPaymentEntity
        self.registerForGlobalPositionReload()
    }
}

private extension BizumHomePresenter {
    var coordinator: BizumHomeModuleCoordinatorProtocol {
        return self.dependenciesResolver.resolve(for: BizumHomeModuleCoordinatorProtocol.self)
    }
    var coordinatorDelegate: BizumHomeModuleCoordinatorDelegate {
        return self.dependenciesResolver.resolve(for: BizumHomeModuleCoordinatorDelegate.self)
    }
    var useCaseHandler: UseCaseHandler {
        return self.dependenciesResolver.resolve(for: UseCaseHandler.self)
    }
    var getFaqsUseCase: GetFaqsUseCaseAlias {
        return self.dependenciesResolver.resolve(for: GetFaqsUseCaseAlias.self)
    }
    var bizumOperationUseCaseAlias: BizumOperationUseCaseAlias {
        return self.dependenciesResolver.resolve(for: BizumOperationUseCaseAlias.self)
    }
    var contactPermission: ContactPermissionsManagerProtocol {
        return dependenciesResolver.resolve(for: ContactPermissionsManagerProtocol.self)
    }
    
    func getContactsViewModel(_ entities: [BizumOperationEntity]) -> [BizumHomeContactViewModel] {
        let colorsEngine: ColorsByNameEngine = self.dependenciesResolver.resolve()
        let phone = self.bizumCheckPaymentEntity.phone?.trim()
        let models = entities
            .filter { $0.stateType != .validated && $0.stateType != .error }
            .filter { ($0.type == .request || $0.type == .send) && $0.emitterId == phone }
            .filter { $0.type != .donation }
            .reduce(NSMutableOrderedSet()) {
                let identifier = $1.receptorAlias ?? $1.receptorId ?? ""
                let colorType = colorsEngine.get(identifier)
                let alias = $1.receptorAlias
                let model = BizumHomeContactViewModel(identifier: identifier,
                                                      initials: alias?.nameInitials,
                                                      name: alias?.camelCasedString,
                                                      phone: $1.receptorId,
                                                      isRegisterInBizum: false,
                                                      colorModel: ColorsByNameViewModel(colorType))
                $0.add(model)
                return $0
            }
        return Array(models) as? [BizumHomeContactViewModel]  ?? []
    }
    
    func getOperationViewModel(_ entity: BizumOperationEntity) -> BizumHomeOperationViewModel? {
        guard let type = BizumUtils.getViewModelType(entity.type),
              let phone = self.bizumCheckPaymentEntity.phone?.trim()
        else { return nil }
        let timeManager: TimeManager = self.dependenciesResolver.resolve()
        let date = timeManager.toString(date: entity.date, outputFormat: .d_MMM)?.uppercased()
        let title: String?
        let emmissorType = BizumUtils.getEmissorType(phone: phone, emitterId: entity.emitterId ?? "", receptorIds: [entity.receptorId ?? ""])
        switch emmissorType {
        case .send:
            title = entity.receptorAlias
        case .received:
            title = entity.emitterAlias
        case .none:
            title = nil
        }
        let transactionType = BizumUtils.getTransactionType(phone: phone, emitterId: entity.emitterId ?? "", emitterType: type)
        let stateType = BizumUtils.getViewModelStateType(entity.stateType)
        let amount = (entity.amount ?? 0.0) * BizumUtils.getAmountSign(type, emmissorType: emmissorType)
        return BizumHomeOperationViewModel(identifier: entity.operationId,
                                           date: date,
                                           title: title?.camelCasedString,
                                           subtitle: entity.concept,
                                           amount: amount,
                                           transactionType: transactionType,
                                           emmissorType: emmissorType,
                                           state: entity.stateType?.rawValueFormatted ?? "",
                                           stateType: stateType,
                                           isMultiple: entity.isMultiple)
    }
    
    func loadData() {
        self.view?.setRecentsLoading()
        self.view?.setContactsEmpty()
        self.loadHomeConfig()
        self.loadFaqs()
    }
    
    func loadHomeConfig() {
        let bizumHomeConfigUseCase: BizumHomeConfigurationUseCaseAlias = self.dependenciesResolver.resolve()
        let getPullOffersUseCase: GetPullOffersUseCase = self.dependenciesResolver.resolve()
        let getPullOffersInput = GetPullOffersUseCaseInput(locations: self.locations)
        Scenario(useCase: getPullOffersUseCase, input: getPullOffersInput)
            .execute(on: DispatchQueue.main)
            .onSuccess { [weak self] result in
                self?.pullOfferCandidates = result.pullOfferCandidates
            }
            .then { _ in
                Scenario(useCase: bizumHomeConfigUseCase)
            }
            .onSuccess { [weak self] result in
                self?.setContactsLoading(result.isEnableSendMoneyBizumNative)
                self?.loadOperations(result.isEnableSendMoneyBizumNative)
                self?.setOptions(isEnableBizumQrOption: result.isEnableBizumQrOption)
            }.onError { [weak self] _ in
                self?.setContactsLoading(false)
                self?.loadOperations(false)
                self?.setOptions(isEnableBizumQrOption: false)
            }
    }
    
    func setOptions(isEnableBizumQrOption: Bool) {
        var options: [BizumHomeOptionViewModel] = [.send, .request, .donation]
        options.append(.qrCode, conditionedBy: isEnableBizumQrOption)
        options.append(.payGroup, conditionedBy: self.isPayGroupEnabled())
        options.append(.fundMoneySent, conditionedBy: self.isFundMoneySentEnabled())
        self.view?.setOptions(options)
    }
    
    func setContactsLoading(_ isEnableSendMoneyBizumNative: Bool) {
        if isEnableSendMoneyBizumNative {
            self.view?.setContactsLoading()
        } else {
            self.view?.setContactsEmpty()
        }
    }
    
    func loadOperations(_ isEnableSendMoneyBizumNative: Bool) {
        let input = BizumOperationUseCaseInput(
            page: 1,
            checkPayment: self.bizumCheckPaymentEntity,
            orderBy: .dischargeDate,
            orderType: .descendant
        )
        let usecase = bizumOperationUseCaseAlias.setRequestValues(requestValues: input)
        UseCaseWrapper(with: usecase, useCaseHandler: self.useCaseHandler, onSuccess: { [weak self] response in
            guard let self = self else { return }
            self.view?.disableGoToHistoric(response.operations.isEmpty)
            self.handleOperationsSuccessFullRespose(response,
                                                    isEnableSendMoneyBizumNative: isEnableSendMoneyBizumNative)
        }, onError: { [weak self] _ in
            self?.view?.setRecentsEmptyView()
            self?.view?.setContacts([])
        })
    }
    
    func handleOperationsSuccessFullRespose(_ response: BizumOperationUseCaseOkOutput, isEnableSendMoneyBizumNative: Bool) {
        let operations = response.operations
            .filter { $0.stateType != .validated && $0.stateType != .error }
        if operations.count > 0 {
            self.operationEntities = Dictionary(uniqueKeysWithValues: operations.map { ($0.operationId ?? "", $0) })
            let viewOperationsModels = operations
                .filter { $0.type != .donation }
                .compactMap { self.getOperationViewModel($0) }
            self.view?.setRecents(viewOperationsModels)
            self.processContacts(
                operations: operations,
                isEnableSendMoneyBizumNative: isEnableSendMoneyBizumNative
            )
        } else {
            self.view?.setRecentsEmptyView()
            self.processContacts(
                operations: [],
                isEnableSendMoneyBizumNative: isEnableSendMoneyBizumNative
            )
        }
    }
    
    func processContacts(operations: [BizumOperationEntity], isEnableSendMoneyBizumNative: Bool) {
        if isEnableSendMoneyBizumNative {
            let viewContactsModels = self.getContactsViewModel(operations)
            self.view?.setContacts(viewContactsModels)
        } else {
            self.view?.setContactsEmpty()
        }
    }
    
    func registerForGlobalPositionReload() {
        self.dependenciesResolver.resolve(for: GlobalPositionReloadEngine.self).add(self)
    }
    
    func loadFaqs() {
        Scenario(useCase: self.getFaqsUseCase, input: FaqsUseCaseInput(type: .bizumHome))
            .execute(on: self.useCaseHandler)
            .onSuccess { [weak self] response in
                self?.proccessFaqs(response.faqs)
            }
            .onError { [weak self] _ in
                self?.proccessFaqs([])
            }
    }
    
    func proccessFaqs(_ faqs: [FaqsEntity]) {
        let viewModels = faqs.map { FaqsViewModel($0) }
        self.view?.showFaqs(viewModels)
    }
    
    func newSendBizum() {
        self.trackEvent(.newSend, parameters: [:])
        self.coordinator.goToBizumSendMoney(nil)
    }
    
    func newRequestMoney() {
        coordinator.goToBizumRequestMoney(nil)
    }
    
    func goToAllOperations() {
        self.coordinator.didSelectHistoric()
    }
    
    func goToBizumWebView(to type: BizumWebViewType) {
        let useCase = self.dependenciesResolver.resolve(for: GetBizumWebConfigurationUseCase.self)
        let input = GetBizumWebConfigurationUseCaseInput(type: type)
        Scenario(useCase: useCase, input: input)
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess { result in
                self.coordinator.goToBizumWebWithConfiguration(result.configuration)
            }
    }
    
    func checkBizumOffsetState() {
        guard self.bizumCheckPaymentEntity.offsetState == "N" else { return }
        self.view?.showBizumShoppingAlert()
    }
    
    func isPayGroupEnabled() -> Bool {
        guard let offersCandidates = self.pullOfferCandidates,
              !offersCandidates.isEmpty,
              offersCandidates.contains(location: BizumHomeOffers.bizumPayGroup) else {
            return false
        }
        return true
    }

    func isFundMoneySentEnabled() -> Bool {
        guard let offersCandidates = self.pullOfferCandidates,
              !offersCandidates.isEmpty,
              offersCandidates.contains(location: BizumHomeOffers.bizumFundSent) else {
            return false
        }
        return true
    }

    func executePayGroupOffer() {
        guard let offersCandidates = self.pullOfferCandidates,
              let offerEntity = offersCandidates.location(key: BizumHomeOffers.bizumPayGroup)?.offer else {
            return
        }
        self.coordinatorDelegate.didSelectOffer(offer: offerEntity)
    }

    func executeFundMoneySent() {
        guard let offersCandidates = self.pullOfferCandidates,
              let offerEntity = offersCandidates.location(key: BizumHomeOffers.bizumFundSent)?.offer else {
            return
        }
        self.coordinatorDelegate.didSelectOffer(offer: offerEntity)
    }
}

extension BizumHomePresenter: BizumHomePresenterProtocol {
    func viewDidLoad() {
        self.loadData()
        self.checkBizumOffsetState()
    }
    
    func didSelectMenu() {
        self.coordinator.didSelectMenu()
    }
    
    func didSelectDismiss() {
        self.coordinator.didSelectDismiss()
    }
    
    func didSelectSearch() {
        self.coordinator.didSelectSearch()
    }
    
    func didSelectNewSend() {
        self.newSendBizum()
    }
    
    func didSelectNewRequest() {
        newRequestMoney()
    }
    
    func didSelectSettings() {
        self.trackEvent(.settings, parameters: [:])
        self.goToBizumWebView(to: .settings)
    }
    
    func didSelectRecents() {
        self.trackEvent(.operationsList, parameters: [:])
        self.goToAllOperations()
    }
    
    func didSelectOperation(_ identifier: String?) {
        guard let identifier = identifier, let detail = operationEntities[identifier] else { return }
        if detail.isMultiple {
            coordinator.goToDetailOfMultipleOperation(detail)
        } else {
            coordinator.goToDetail(detail)
        }
    }
    
    func didSelectContact(_ contact: BizumHomeContactViewModel) {
        let contactEntity = BizumContactEntity(
            identifier: contact.identifier ?? "",
            name: contact.name ?? "",
            phone: contact.phone ?? "")
        self.trackEvent(.clickFavourite, parameters: [:])
        self.coordinator.goToAmountSendMoney(contactEntity)
    }
    
    func didSelectVirtualAssistant() {
        self.coordinator.goToVirtualAssistant()
    }
    
    func didSelectOption(_ option: BizumHomeOptionViewModel?) {
        guard let option = option else { return }
        switch option {
        case .qrCode:
            self.goToBizumWebView(to: .qrCode)
        case .donation:
            self.coordinator.goToBizumDonations()
        case .request:
            newRequestMoney()
        case .send:
            self.newSendBizum()
        case .payGroup:
            self.executePayGroupOffer()
        case .fundMoneySent:
            self.executeFundMoneySent()
        }
    }
    
    func didSelectRecentsList() {
        self.trackEvent(.operationsButton, parameters: [:])
        self.goToAllOperations()
    }
    
    func didSelectSearchContact() {
        self.trackEvent(.contacts, parameters: [:])
        if self.contactPermission.isContactsAccessEnabled() {
            let presenter = ContactListPresenter(dependenciesResolver: self.dependenciesResolver)
            presenter.delegate = self
            self.view?.showContacts(with: presenter)
        } else {
            self.view?.showAlertContactList()
        }
    }
    
    func didAllowPermission() {
        self.contactPermission.isAlreadySet { [weak self] isAlreadySet in
            guard let self = self else { return }
            if isAlreadySet {
                self.view?.showDialogPermission()
            } else {
                self.contactPermission.askAuthorizationIfNeeded { authorized in
                    if authorized {
                        let presenter = ContactListPresenter(dependenciesResolver: self.dependenciesResolver)
                        presenter.delegate = self
                        self.view?.showContacts(with: presenter)
                    }
                }
            }
        }
    }
    
    func didSelectKnowMoreOfShopping() {
        self.goToBizumWebView(to: .settings)
    }
    
    func trackFaqEvent(_ question: String, url: URL?) {
        let eventId = url == nil ? "click_show_faq" : "click_link_faq"
        var dic: [String: String] = ["faq_question": question]
        if let link = url?.absoluteString {
            dic["faq_link"] = link
        }
        trackerManager.trackEvent(screenId: "bizum", eventId: eventId, extraParameters: dic)
    }
}

extension BizumHomePresenter: ContactListDelegate {
    func didContactSelected(viewModel: BizumContactListViewModel) {
        let contact = BizumContactEntity(
            identifier: viewModel.identifier ?? "",
            name: viewModel.name,
            phone: viewModel.phone,
            thumbnailData: viewModel.thumbnailData
        )
        self.coordinator.goToBizumSendMoney([contact])
    }
}

extension BizumHomePresenter: GlobalPositionReloadable {
    func reload() {
        self.loadData()
    }
}

extension BizumHomePresenter: AutomaticScreenActionTrackable {
    var trackerPage: BizumHomePage {
        BizumHomePage()
    }
    var trackerManager: TrackerManager {
        self.dependenciesResolver.resolve(for: TrackerManager.self)
    }
}
