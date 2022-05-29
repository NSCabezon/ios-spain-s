import CoreFoundationLib

// MARK: - BizumHistoricPresenterProtocol

protocol BizumHistoricPresenterProtocol: MenuTextWrapperProtocol {
    func setView(_ view: BizumHistoricViewProtocol)
    func didLoad()
    func didSelectSearch()
    func didSelectAll()
    func didSelectSend()
    func didSelectReceived()
    func didSelectBuy()
    func didSelectMenu()
    func didSelectDismiss()
    func didSearchText(_ text: String)
    func didClearSearch()
    func didSelectDetail(_ item: BizumHistoricCellViewModel)
    func didSelectBizumAction(_ actionViewModel: BizumAvailableActionViewModel)
}

// MARK: - BizumHistoricPresenter

final class BizumHistoricPresenter {
    let dependenciesResolver: DependenciesResolver
    private weak var view: BizumHistoricViewProtocol?
    private var items: [BizumHistoricOperationEntity]
    private let operationsSuperUseCase: BizumHistoricSuperUseCase
    private let phoneOwner: String?
    private var timer: Timer?
    private var searchTerm = ""
    private var segmentSelected: SegmentSelected = .all
    private var bizumAppConfigActionsStatus: BizumAppConfigOperationsStatus?
    private var isOnErrorMessage: Bool = false

    private lazy var allOperations: [BizumHistoricCellViewModel] = {
        return self.items.flatMap({self.createCellViewModel($0)})
    }()
    init(dependenciesResolver: DependenciesResolver, bizumCheckPaymentEntity: BizumCheckPaymentEntity) {
        self.dependenciesResolver = dependenciesResolver
        self.items = []
        self.phoneOwner = bizumCheckPaymentEntity.phone
        self.operationsSuperUseCase = self.dependenciesResolver.resolve()
        self.operationsSuperUseCase.setCheckPayment(bizumCheckPaymentEntity)
        self.operationsSuperUseCase.delegate = self
    }
}

// MARK: - BizumHistoricPresenter - BizumHistoricPresenterProtocol

extension BizumHistoricPresenter: BizumHistoricPresenterProtocol {
    func didSelectBizumAction(_ actionViewModel: BizumAvailableActionViewModel) {
        guard let operationEntity = self.items.filter({ $0.operationId == actionViewModel.operationID }).first else { return }
        
        switch actionViewModel.processedActiontype {
        case .cancelSend:
            self.coordinator.didSelectCancel(operationEntity)
        case .acceptRequest:
            self.coordinator.didSelectAccept(operationEntity)
        case .rejectRequest:
            self.coordinator.didSelectRejectRequest(operationEntity)
        case .refund:
            self.coordinator.didSelectRefund(operationEntity)
        case .cancelRequest:
            self.coordinator.didSelectCancelRequest(operationEntity)
        default:
            break
        }
    }
    
    func setView(_ view: BizumHistoricViewProtocol) {
        self.view = view
    }
    
    func didLoad() {
        self.loadData()
        trackScreen()
    }
    
    func didSelectSearch() {
        self.coordinator.didSelectSearch()
    }
    
    func didSelectAll() {
        segmentSelected = .all
        searchTerm = ""
        showHistoricItems()
        trackEvent(.filter, parameters: [.bizumHistoricType: BizumHistoricTrack.all.rawValue])
    }
    
    func didSelectSend() {
        segmentSelected = .sent
        searchTerm = ""
        showHistoricItems()
        trackEvent(.filter, parameters: [.bizumHistoricType: BizumHistoricTrack.sent.rawValue])
    }
    
    func didSelectReceived() {
        segmentSelected = .received
        searchTerm = ""
        showHistoricItems()
        trackEvent(.filter, parameters: [.bizumHistoricType: BizumHistoricTrack.received.rawValue])
    }
    
    func didSelectBuy() {
        segmentSelected = .bought
        searchTerm = ""
        showHistoricItems()
        trackEvent(.filter, parameters: [.bizumHistoricType: BizumHistoricTrack.purchase.rawValue])
    }
    
    func didSelectMenu() {
        self.coordinator.didSelectMenu()
    }
    
    func didSelectDismiss() {
        self.coordinator.didSelectDismiss()
    }
    
    func didSearchText(_ text: String) {
        timer?.invalidate()
        searchTerm = text
        startTimer()
        trackEvent(.search, parameters: [.textSearch: text])
    }
    
    func didClearSearch() {
        searchTerm = ""
        timer?.invalidate()
        showHistoricItems()
    }
    
    func didSelectDetail(_ item: BizumHistoricCellViewModel) {
        guard let operationEntity = self.items.filter({ $0.operationId == item.operationId }).first else { return }
        self.coordinator.didSelectDetail(operationEntity)
        
        trackGoToDetail(operationEntity)
        self.coordinator.didSelectDetail(operationEntity)
    }
}

// MARK: - BizumHistoricPresenter - BizumHistoricSuperUseCaseDelegate

extension BizumHistoricPresenter: BizumHistoricSuperUseCaseDelegate {
    func didFinishSuccessfully(_ operations: [BizumHistoricOperationEntity], actionsStatus: BizumAppConfigOperationsStatus?) {
        self.items.append(
            contentsOf: operations
                .filter { $0.stateType != .validated }
        )
        self.bizumAppConfigActionsStatus = actionsStatus
        self.isOnErrorMessage = false
        self.view?.hideLoadingView({ [weak self] in
            self?.didSelectAll()
            self?.view?.goToAllTab()
        })
    }
    
    func didFinishWithError(_ error: String?) {
        self.items = []
        self.isOnErrorMessage = error != nil
        if self.isOnErrorMessage {
            self.view?.disableSelector()
        }
        self.bizumAppConfigActionsStatus = .none
        self.view?.hideLoadingView({ [weak self] in
            self?.didSelectAll()
            self?.view?.goToAllTab()
        })
    }
}

// MARK: - BizumHistoricPresenter - Private

private extension BizumHistoricPresenter {
    enum SegmentSelected {
        case all, sent, received, bought
    }
    
    var coordinator: BizumHistoricModuleCoordinatorProtocol {
        return self.dependenciesResolver.resolve(for: BizumHistoricModuleCoordinatorProtocol.self)
    }
    
    func loadData() {
        self.items.removeAll()
        self.view?.showLoadingView({ [weak self] in
            self?.operationsSuperUseCase.execute()
        })
    }
    
    func getAllOperations() -> [BizumHistoricCellViewModel] {
        self.allOperations
    }
    
    func getOperations(_ type: BizumHomeOperationTypeViewModel) -> [BizumHistoricCellViewModel] {
        guard self.phoneOwner != nil else { return [] }
        let viewModel = self.allOperations.filter({self.checkColumnType($0) == type})
        return viewModel
    }
    
    func checkColumnType(_ item: BizumHistoricCellViewModel) -> BizumHomeOperationTypeViewModel? {
        if item.type == .purchase {
            return .purchase
        } else if item.type == .donation || ((item.type == .request || item.type == .send) && item.emmissorType  == .send) {
            return .send
        } else if (item.type == .request || item.type == .send) && item.emmissorType == .received {
            return .request
        } else {
            return nil
        }
    }
    
    func createCellViewModel(_ entity: BizumHistoricOperationEntity) -> BizumHistoricCellViewModel? {
        guard entity.type != nil else { return nil }
        switch entity {
        case .simple(let operation):
            return self.createSimpleViewModel(operation)
        case .multiple(let operation):
            return self.createMultipleViewModel(operation)
        }
    }
    
    func createSimpleViewModel(_ entity: BizumOperationEntity) -> BizumHistoricCellViewModel? {
        guard let type = BizumUtils.getViewModelType(entity.type),
              let phone = self.phoneOwner?.trim()
        else { return nil }
        let aliasValue: String?
        let phoneValue: String?
        let emmissorType = BizumUtils.getEmissorType(phone: phone, emitterId: entity.emitterId ?? "", receptorIds: [entity.receptorId ?? ""])
        switch emmissorType {
        case .send:
            aliasValue = self.getAlias(entity.receptorAlias)
            phoneValue = entity.receptorId
        case .received:
            aliasValue = self.getAlias(entity.emitterAlias)
            phoneValue = entity.emitterId
        case .none:
            phoneValue = nil
            aliasValue = nil
        }
        
        let transactionType = BizumUtils.getTransactionType(phone: phone, emitterId: entity.emitterId ?? "", emitterType: type)
        let title = transactionType.getHistoricTransactionType(isMultiple: false).text
        let totalAmount = BizumUtils.getTotalAmount(entity.amount ?? 0.0, contacts: 1, transactionType: transactionType)
        let subtitleValue = (aliasValue?.isEmpty ?? true) ? phoneValue?.tlfFormatted() : aliasValue
        var actionsViewModel: BizumActionsEvaluator?
        if let ownerPhone = self.phoneOwner, let statusActions = self.bizumAppConfigActionsStatus {
            actionsViewModel = BizumActionsEvaluator(actionsStatus: statusActions, operationEntity: entity, appUser: ownerPhone)
        }
        return BizumHistoricSimpleCellViewModel(
            actionsEvaluator: actionsViewModel,
            operationId: entity.operationId ?? "",
            type: type,
            transactionType: transactionType,
            emmissorType: emmissorType,
            iconColor: self.getColorByName(aliasValue ?? phoneValue ?? ""),
            title: title,
            subtitle: subtitleValue,
            concept: self.getOperationConcept(entity.concept),
            date: entity.date,
            search: searchTerm,
            hasAttachment: entity.hasAttachment,
            phoneNumber: aliasValue != nil ? (phoneValue?.tlfFormatted() ?? "") : "",
            amount: totalAmount,
            state: BizumUtils.getViewModelStateType(entity.stateType),
            stateLabel: entity.stateType?.rawValueFormatted ?? "",
            initials: aliasValue?.nameInitials ?? "")
    }
    
    func createMultipleViewModel(_ entity: BizumOperationMultiDetailEntity) -> BizumHistoricCellViewModel? {
        guard let type = BizumUtils.getViewModelType(entity.type),
              let phone = self.phoneOwner?.trim()
        else { return nil }
        let emmissorType = BizumUtils.getEmissorType(phone: phone, emitterId: entity.emmiterId ?? "", receptorIds: entity.receptorId)
        let transactionType = BizumUtils.getTransactionType(phone: phone, emitterId: entity.emmiterId ?? "", emitterType: type)
        let totalAmount = BizumUtils.getTotalAmount(entity.amount ?? 0.0, contacts: entity.numberOfOperations, transactionType: transactionType)
        let identifier = BizumUtils.getIdentifier(entity.emitterAlias, phone: entity.emmiterId ?? "")
        return BizumHistoricMultipleCellViewModel(
            operationId: entity.operationId ?? "",
            type: type,
            transactionType: transactionType,
            emmissorType: emmissorType,
            iconColor: self.getColorByName(identifier),
            title: transactionType.getHistoricTransactionType(isMultiple: true).text,
            concept: self.getOperationConcept(entity.concept),
            date: entity.date,
            search: searchTerm,
            totalContacts: entity.numberOfOperations,
            initials: self.createBizumHistoricInitialsViewModel(entity.operations),
            amount: totalAmount)
    }
    
    func createSectionViewModel(_ cellViewModel: [BizumHistoricCellViewModel]) -> [BizumHistoricSectionViewModel] {
        let dictionary: [Date: [BizumHistoricCellViewModel]] = [:]
        let groupedByDate = cellViewModel.reduce(into: dictionary) { result, viewModel in
            let date = viewModel.date?.startOfdayWithoutLocalCalendar() ?? Date()
            let existing = result[date] ?? []
            result[date] = existing + [viewModel]
        }
        return groupedByDate.map { BizumHistoricSectionViewModel(date: $0.key, dateFormatted: $0.key.formatedLocalizedHeader(), items: $0.value) }.sorted(by: { $0.date > $1.date })
    }
    
    func getColorByName(_ identifier: String) -> ColorsByNameViewModel {
        let colorsEngine: ColorsByNameEngine = self.dependenciesResolver.resolve()
        let colorType = colorsEngine.get(identifier)
        return ColorsByNameViewModel(colorType)
    }
    
    func createBizumHistoricInitialsViewModel(_ operations: [BizumOperationMultiDetailItemEntity]) -> [BizumHistoricInitialsViewModel] {
        return operations.map { operation in
            let identifier = operation.receptorAlias ?? operation.receptorId ?? ""
            return BizumHistoricInitialsViewModel(initials: operation.receptorAlias?.nameInitials ?? "", colorViewModel: self.getColorByName(identifier))
        }
    }
    
    func getItems() -> [BizumHistoricCellViewModel] {
        switch segmentSelected {
        case .all:
            return self.allOperations
        case .sent:
            return getOperations(.send)
        case .received:
            return getOperations(.request)
        case .bought:
            return getOperations(.purchase)
        }
    }
    
    func showHistoricItems() {
        let items = getItems()
        self.view?.showResults(createSectionViewModel(items), totalItems: items.count, isOnErrorMessage: isOnErrorMessage)
    }

    func showFilteredResults() {
        let filteredResults = self.getItems().reduce(into: [BizumHistoricCellViewModel]()) { result, model in
            var itemsToEvalute = [String]()
            itemsToEvalute.append(model.concept)
            if let simpleItem = model as? BizumHistoricSimpleCellViewModel {
                if let subtitle = simpleItem.subtitle {
                    itemsToEvalute.append(subtitle)
                }
                itemsToEvalute.append(simpleItem.formattedPhoneNumber())
            }
            if itemsToEvalute.contains(where: { $0.lowercased().contains(self.searchTerm.lowercased())}) {
                var updatedModel = model
                updatedModel.search = self.searchTerm
                result.append(updatedModel)
            }
        }
        view?.showResults(createSectionViewModel(filteredResults), totalItems: filteredResults.count, isOnErrorMessage: false)
    }

    func getOperationConcept(_ concept: String?) -> String {
        guard let concept = concept, !concept.isEmpty else {
            return localized("bizum_label_notConcept")
        }
        return concept
    }
    
    func getAlias(_ alias: String?) -> String? {
        guard let alias = alias, !alias.isEmpty else {
            return nil
        }
        return alias
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] timer in
            timer.invalidate()
            guard let self = self else { return }
            self.searchTerm.isEmpty ? self.showHistoricItems() : self.showFilteredResults()
        }
    }
    
    func trackGoToDetail(_ operationEntity: BizumHistoricOperationEntity) {
        let simpleMultipleType: BizumSimpleMultipleType
        switch operationEntity {
        case .simple:
            simpleMultipleType = .simple
        case .multiple:
            simpleMultipleType = .multiple
        }
        let bizumDeliveryType: String
        switch operationEntity.type {
        case .send, .donation:
            bizumDeliveryType = BizumDetailTrack.sendOrDonation.rawValue
        case .purchase:
            bizumDeliveryType = BizumDetailTrack.purchase.rawValue
        case .request:
            bizumDeliveryType = BizumDetailTrack.request.rawValue
        case nil:
            bizumDeliveryType = ""
        }
        let bizumHistoricType: BizumHistoricTrack
        switch segmentSelected {
        case .all:
            bizumHistoricType = .all
        case .bought:
            bizumHistoricType = .purchase
        case .received:
            bizumHistoricType = .received
        case .sent:
            bizumHistoricType = .sent
        }
        trackEvent(.goToDetail,
                   parameters: [.bizumDeliveryType: bizumDeliveryType,
                                .simpleMultipleType: simpleMultipleType.rawValue,
                                .bizumHistoricType: bizumHistoricType.rawValue])
    }
}

extension BizumHistoricPresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    var trackerPage: BizumHistoricPage {
        return BizumHistoricPage()
    }
}
