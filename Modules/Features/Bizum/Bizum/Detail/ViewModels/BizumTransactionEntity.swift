import CoreFoundationLib

final class BizumTransactionEntity {
    private let dependenciesResolver: DependenciesResolver
    let historicOperationEntity: BizumHistoricOperationEntity?
    let operations: [BizumOperationMultiDetailItemEntity]?
    let amount: Double
    let emitterAlias: String?
    let emitterId: String
    let concept: String?
    let operationId: String
    let hasAttachment: Bool
    let date: String
    let dateWithHour: String
    let receiverState: [String]?
    let receiverAlias: [String]
    let receiversIds: [String]
    let isMultiple: Bool
    var multimedia: BizumMultimediaData?
    let emitterType: BizumHomeOperationTypeViewModel?
    var typeTransaction: BizumTransactionType?
    var checkPaymentEntity: BizumCheckPaymentEntity {
        let configuration: BizumCheckPaymentConfiguration = dependenciesResolver.resolve()
        return configuration.bizumCheckPaymentEntity
    }
    var emissorType: BizumEmissorType? {
        guard
            let phone = checkPaymentEntity.phone?.trim(),
            let operation = historicOperationEntity
        else { return nil }
        if phone == operation.emitterId {
            return .send
        } else if operation.receptorId.contains(phone) {
            return .receive
        } else {
            return nil
        }
    }
    var stateType: BizumOperationStateEntity? {
        guard let operation = historicOperationEntity else { return nil }
        switch operation {
        case .simple(operation: let operation):
            return operation.stateType
        case .multiple(operation: let operation):
            return operation.operations.contains { $0.state == "ACEPTADA" } ? .accepted : nil
        }
    }
    let type: BizumOperationTypeEntity?
    var userName: String?
    var bizumOperationEntity: BizumOperationEntity? {
        return historicOperationEntity?.bizumOperationEntity
    }
    
    init(operationEntity: BizumHistoricOperationEntity, dependenciesResolver: DependenciesResolver) {
        switch operationEntity {
        case .simple:
            self.isMultiple = false
        case .multiple:
            self.isMultiple = true
        }
        self.historicOperationEntity = operationEntity
        self.dependenciesResolver = dependenciesResolver
        self.emitterAlias = operationEntity.emitterAlias
        self.emitterId = operationEntity.emitterId ?? ""
        self.receiversIds = operationEntity.receptorId.map({ $0 ?? "" })
        self.receiverAlias = operationEntity.receptorAlias.map({ $0 ?? "" })
        self.concept = operationEntity.concept
        self.operationId = operationEntity.operationId ?? ""
        self.hasAttachment = operationEntity.hasAttachment
        var date: String { let dateString = dependenciesResolver.resolve(for: TimeManager.self)
            .toString(date: operationEntity.date, outputFormat: .dd_MMM_yyyy)?.lowercased() ?? ""
            return dateString
        }
        self.date = date
        var dateWithHour: String { let dateString = dependenciesResolver.resolve(for: TimeManager.self)
            .toString(date: operationEntity.date, outputFormat: .dd_MMM_yyyy_hyphen_HHmm_h)?.lowercased() ?? ""
            return dateString
        }
        self.dateWithHour = dateWithHour
        self.emitterType = BizumUtils.getViewModelType(operationEntity.type)
        self.receiverState = operationEntity.receptorState
        self.amount = operationEntity.amount ?? 0
        self.type = operationEntity.type
        self.operations = operationEntity.operations
    }
    
    func resolveOrigin(phone: String) {
        guard let type = self.emitterType else { return }
        self.typeTransaction = BizumUtils.getTransactionType(phone: phone, emitterId: self.emitterId, emitterType: type)
    }
    
    func getContacts() -> [BizumContactEntity] {
        if let operations = self.operations {
            var contacts: [BizumContactEntity] = []
            operations.forEach { itemEntity in
                let identifier = BizumUtils.getIdentifier(itemEntity.receptorAlias, phone: itemEntity.receptorId ?? "")
                let contact = BizumContactEntity(
                    identifier: identifier,
                    name: itemEntity.receptorAlias,
                    phone: itemEntity.receptorId ?? "",
                    alias: itemEntity.receptorAlias
                )
                contacts.append(contact)
            }
            return contacts
        } else {
            let identifier = BizumUtils.getIdentifier(self.receiverAlias.first, phone: self.receiversIds.first ?? "")
            let contact = BizumContactEntity(
                identifier: identifier,
                name: self.receiverAlias.first ?? "",
                phone: self.receiversIds.first ?? "",
                alias: self.receiverAlias.first
            )
            return [contact]
        }
    }
    
    func getEmitterTypeTransaction() -> BizumEmitterType? {
        guard let type = typeTransaction else { return nil }
        switch type {
        case .emittedRequest: return .request
        case .emittedSend: return .send
        case .donation, .purchase, .receiverRequest, .receiverSend: return nil
        }
    }
    
    func getTransferTitle(name: String) -> LocalizedStylableText {
        guard let typeTransaction = self.typeTransaction else {
            return .empty
        }
        let placeholder = [StringPlaceholder(.name, name.camelCasedString)]
        switch typeTransaction {
        case .emittedSend:
            return localized("bizum_label_shareWith", placeholder)
        case .receiverSend:
            return .empty
        case .emittedRequest:
            return localized("bizum_label_shareRequestWith", placeholder)
        case .receiverRequest:
            guard let stateType = self.stateType else { return .empty }
            if stateType == .accepted {
                return localized("bizum_label_shareAcceptRequest", placeholder)
            } else if stateType == .rejected {
                return localized("bizum_label_shareRejectRequest", placeholder)
            } else {
                return .empty
            }
        case .donation:
            return localized("bizum_label_shareDonation", placeholder)
        case .purchase:
            return .empty

        }
    }
}
