import Foundation
import CoreFoundationLib

enum BizumTransactionType {
    case emittedSend
    case emittedRequest
    case receiverSend
    case receiverRequest
    case donation
    case purchase

    func getDetailTransactionTypeWithAccessibility() -> TextWithAccessibility {
        switch self {
        case .emittedSend: return TextWithAccessibility(text: "bizumDetail_label_sentFrom", accessibility: AccessibilityBizumDetail.bizumLabelEmitterMoney)
        case .emittedRequest: return TextWithAccessibility(text: "bizumDetail_label_requestedFrom", accessibility: AccessibilityBizumDetail.bizumLabelEmitterRequest)
        case .receiverSend: return TextWithAccessibility(text: "bizumDetail_label_receivedFrom", accessibility: AccessibilityBizumDetail.bizumLabelReceiverMoney)
        case .receiverRequest: return TextWithAccessibility(text: "bizumDetail_label_applicant", accessibility: AccessibilityBizumDetail.bizumLabelReceiverRequest)
        default: return TextWithAccessibility(text: "summary_label_origin", accessibility: AccessibilityBizumDetail.bizumLabelOrigin)
        }
    }

    func getHistoricTransactionType(isMultiple: Bool) -> LocalizedStylableText {
        switch self {
        case .emittedSend:
            if isMultiple == true {
                return localized("bizum_label_multipleTo") // ENVIO MULTIPLE A:
            } else {
                return localized("bizum_label_sendTo") // ENVIADO A:
            }
        case .emittedRequest: return localized("bizum_label_requestedFrom") // SOLICITADO A:
        case .receiverSend: return localized("bizum_label_receivedFrom") // RECIBIDO DE:
        case .receiverRequest: return localized("bizum_label_requestedBy")// SOLICITADO POR:
        case .donation: return localized("bizum_label_sendTo") // ENVIADO A:
        case .purchase: return localized("bizum_label_buyIn")
        }
     }
}

enum BizumActionType {
    case share, cancelSend, refund, sendAgain(type: BizumOperationTypeEntity?), reuseContact, cancelRequest, acceptRequest, rejectRequest
}

extension BizumActionType: Equatable {
    static func == (lhs: BizumActionType, rhs: BizumActionType) -> Bool {
        switch (lhs, rhs) {
        case (.share, .share):
            return true
        case (.cancelSend, .cancelSend):
            return true
        case (.rejectRequest, .rejectRequest):
            return true
        case (.refund, .refund):
            return true
        case (.reuseContact, .reuseContact):
            return true
        case (.cancelRequest, .cancelRequest):
            return true
        case (.acceptRequest, .acceptRequest):
            return true
        case (.sendAgain(let ltype), .sendAgain(let rtype)):
            return ltype == rtype
        default:
            return false
        }
    }
}

enum BizumEmissorType {
    case send, receive
}

enum BizumEmitterType {
    case send, request
}

