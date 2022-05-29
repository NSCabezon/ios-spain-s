//
//  BizumActionsEvaluator.swift
//  Bizum
//
//  Created by Boris Chirino Fernandez on 17/12/2020.
//
import CoreFoundationLib

final class BizumActionsEvaluator {
    private let bizumActionsStatusByAppConfig: BizumAppConfigOperationsStatus?
    private let entity: BizumOperationEntity
    private var appUser: String
    private var availableActions: [BizumActionEntity]?

    init(actionsStatus: BizumAppConfigOperationsStatus, operationEntity: BizumOperationEntity, appUser: String) {
        self.bizumActionsStatusByAppConfig = actionsStatus
        self.entity = operationEntity
        self.appUser = appUser.trim()
    }
    
    func validActions() -> [BizumAvailableActionViewModel]? {
        guard let operationType = self.entity.type else {
            return nil
        }
        let today = Date()
        let notExpiredActions = self.entity.availableActions?
            .filter({ $0.expiry > today && getProcessedTypeforBasicBizumOperationType($0.action, for: operationType) != nil})
            .map({
                    BizumAvailableActionViewModel(action: $0.action,
                                                 processedActiontype: getProcessedTypeforBasicBizumOperationType($0.action, for: operationType),
                                                 expiry: $0.expiry,
                                                 operationID: self.entity.operationId ?? "") })
        return notExpiredActions?.sorted()
    }
}

private extension BizumActionsEvaluator {
    
    func getProcessedTypeforBasicBizumOperationType(_ bizumBasicType: BizumOperationActionType, for operationType: BizumOperationTypeEntity) -> BizumActionType? {
        switch operationType {
        case .request:
            switch bizumBasicType {
            case .accept:
                return self.passRequisitesForAcceptRequest() ? .acceptRequest : nil
            case .reject:
                return self.passRequisitesForRejectRequest() ? .rejectRequest : nil
            case .cancel:
                return self.passRequisitesForCancelRequest() ? .cancelRequest : nil
            default:
                return nil
            }
        case .send:
            switch bizumBasicType {
            case .refund:
                return passRequisitesForRefund() ? .refund : nil
            case .cancel:
                return passRequisitesForCancelNotRegistered() ? .cancelSend : nil
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
    // MARK: - Accept
    func passRequisitesForAcceptRequest() -> Bool {
        guard self.entity.stateType == .pending
            && bizumActionsStatusByAppConfig?.accept == true
            && self.entity.type == .request // C2CPull
            && self.entity.receptorId == self.appUser  else { return false }
        return true
    }
    
    // MARK: - Refund
    func passRequisitesForRefund() -> Bool {
        guard self.entity.stateType == .accepted
            && bizumActionsStatusByAppConfig?.refund == true
            && self.entity.type == .send // C2CPush
            && self.entity.receptorId == self.appUser else { return false }
        return true
    }
    
    // MARK: - Cancel
    func passRequisitesForCancelNotRegistered() -> Bool {
        return self.entity.stateType == .pendingRegister
                && bizumActionsStatusByAppConfig?.cancelNotRegistered == true
                && self.entity.type == .send // C2CPush
                && self.entity.emitterId?.trim() == self.appUser
    }
    
    func passRequisitesForCancelRequest() -> Bool {
        return self.entity.stateType == .pending
            && self.entity.type == .request
            && self.entity.emitterId == self.appUser
    }
    
    // MARK: - Reject
    func passRequisitesForRejectRequest() -> Bool {
        return self.entity.stateType == .pending
            && self.entity.type == .request
            && self.entity.receptorId?.trim() == self.appUser
    }
}
