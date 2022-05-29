//
//  BizumHistoricCellViewModel.swift
//  Bizum
//
//  Created by Jose Ignacio de Juan Díaz on 27/10/2020.
//

import CoreFoundationLib
import UI
import ESUI

struct BizumHistoricSectionViewModel {
    let date: Date
    let dateFormatted: LocalizedStylableText
    let items: [BizumHistoricCellViewModel]
}

protocol BizumHistoricCellViewModel {
    var operationId: String { get }
    var search: String? { get set }
    var type: BizumHomeOperationTypeViewModel { get }
    var emmissorType: BizumHomeOperationTypeEmissorViewModel? { get }
    var transactionType: BizumTransactionType { get }
    var title: String { get }
    var amount: AmountEntity { get }
    var concept: String { get }
    var date: Date? { get }
    var hasAttachment: Bool { get set }
    var actionsEvaluator: BizumActionsEvaluator? { get }
    func highlight(_ baseString: String, search: String) -> NSAttributedString
    func getHighlightedConcept() -> NSAttributedString?
    func getTypeImage() -> UIImage?
}
    
extension BizumHistoricCellViewModel {
    
    func highlight(_ baseString: String, search: String) -> NSAttributedString {
        let attributedBaseString = NSAttributedString(string: baseString)
        let ranges = attributedBaseString.string.ranges(of: search).map { NSRange($0, in: search) }
        return ranges.reduce(NSMutableAttributedString(attributedString: attributedBaseString)) {
            $0.addAttribute(.backgroundColor, value: UIColor.lightYellow, range: $1)
            return $0
        }
    }
    
    func getHighlightedConcept() -> NSAttributedString? {
        guard let search = search else { return nil }
        return highlight(concept, search: search)
    }
    
    func getTypeImage() -> UIImage? {
        switch transactionType {
        case .emittedSend, .purchase, .receiverRequest, .donation:
            return ESAssets.image(named: "icnSendRedHistory")
        case .emittedRequest, .receiverSend:
            return ESAssets.image(named: "icnReceivedGreenHistory")
        }
    }
}

struct BizumHistoricSimpleCellViewModel: BizumHistoricCellViewModel {
    var actionsEvaluator: BizumActionsEvaluator?
    let operationId: String
    let type: BizumHomeOperationTypeViewModel
    let transactionType: BizumTransactionType
    let emmissorType: BizumHomeOperationTypeEmissorViewModel?
    let iconColor: ColorsByNameViewModel
    let title: String
    let subtitle: String?
    let concept: String
    let date: Date?
    var search: String?
    var hasAttachment: Bool = false
    let phoneNumber: String
    let amount: AmountEntity
    let state: BizumHomeOperationTypeStateViewModel?
    let stateLabel: String
    let initials: String
    
    func getHighlightedSubtitle() -> NSAttributedString? {
        guard let subtitle = subtitle,
        let search = search else { return nil }
        return highlight(subtitle, search: search)
    }
    
    func formattedPhoneNumber() -> String {
        switch type {
        case .donation:
            return String(phoneNumber.suffix(5))
        default:
            return phoneNumber
        }
    }

    func getHighlightedPhone() -> NSAttributedString? {
        guard let search = search else { return nil }
        return highlight(formattedPhoneNumber(), search: search)
    }
}

struct BizumHistoricInitialsViewModel {
    let initials: String
    let colorViewModel: ColorsByNameViewModel
}

struct BizumHistoricMultipleCellViewModel: BizumHistoricCellViewModel {
    var actionsEvaluator: BizumActionsEvaluator?
    let operationId: String
    let type: BizumHomeOperationTypeViewModel
    let transactionType: BizumTransactionType
    let emmissorType: BizumHomeOperationTypeEmissorViewModel?
    let iconColor: ColorsByNameViewModel
    let title: String
    let concept: String
    let date: Date?
    var search: String?
    let totalContacts: Int
    let initials: [BizumHistoricInitialsViewModel]
    var hasAttachment: Bool = false
    let amount: AmountEntity
    
    func getRestCount() -> Int {
        let initialMax = initials.count > 3 ? 3 : initials.count
        let rest = totalContacts - initialMax
        return rest
    }
}

struct BizumAvailableActionViewModel: Comparable {
    let action: BizumOperationActionType
    let processedActiontype: BizumActionType?
    let expiry: Date
    let operationID: String
    
    var iconName: String {
        switch action {
        case .accept: // Aceptar
            return "icnAcceptBizum"
        case .reject: // Rechazar
            return "icnCloseTurq"
        case .refund: // Devolver
            return "icnReturnShipping"
        case .cancel:
            return "icnCancelBizum"
        }
    }
    
    var literalKey: String {
        
        switch processedActiontype {
        case .acceptRequest:
            return "bizum_button_historicAcceptRequest"
        case .cancelSend:
            return "bizum_button_cancelShipmentMade"
        case .cancelRequest:
            return "bizum_button_cancelRequestMade"
        case .refund:
            return "bizum_button_returnShipmentReceived"
        case .rejectRequest:
            return "bizum_button_historicRejectRequest"
        default:
            return ""
        }
    }
    
    var accessibilityIdentifier: String {
        switch action {
        case .accept:
            return AccessibilityBizumHistoric.bizumAcceptActionButton
        case .refund:
            return AccessibilityBizumHistoric.bizumRefundActionButton
        case .reject:
            return AccessibilityBizumHistoric.bizumRejectActionButton
        case .cancel:
            return AccessibilityBizumHistoric.bizumSendActionButton
        }
    }
    
    var displayPriority: Int {
        switch action {
        case .reject:
            return 1
        case .accept:
            return 0
        default:
            return 10
        }
    }
    
    static func < (lhs: BizumAvailableActionViewModel, rhs: BizumAvailableActionViewModel) -> Bool {
        return  rhs.displayPriority < lhs.displayPriority
    }
}
