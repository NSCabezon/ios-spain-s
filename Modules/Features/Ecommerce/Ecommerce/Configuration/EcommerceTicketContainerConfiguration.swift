//
//  EcommerceTicketContainerConfiguration.swift
//  Ecommerce
//
//  Created by Ignacio González Miró on 2/3/21.
//

import UI
import CoreFoundationLib

public enum EcommerceAuthStatus {
    case confirmed
    case notConfirmed
}

public enum EcommerceAuthType {
    case fingerPrint
    case faceId
    case code
    
    func imageName() -> String {
        switch self {
        case .fingerPrint:
            return "icnEcommerceTouchId"
        case .faceId:
            return "icnBigFaceId"
        case .code:
            return "icnBigAccessCode"
        }
    }
    
    func labelKeyWithStatus(_ status: EcommerceAuthStatus) -> String {
        switch self {
        case .fingerPrint:
            return status == .confirmed
                ? "ecommerce_button_confirmFingerPrint"
                : "ecommerce_label_ErrorFingerPrint"
        case .faceId:
            return status == .confirmed
                ? "ecommerce_label_confirmFaceId"
                : "ecommerce_label_errorFacial"
        case .code:
            return "ecommerce_label_confirmWithPassword"
        }
    }
    
    func labelColorWithStatus(_ status: EcommerceAuthStatus) -> UIColor {
        switch self {
        case .fingerPrint, .faceId:
            return status == .confirmed ? .lisboaGray : .bostonRedLight
        case .code:
            return .lisboaGray
        }
    }
}

public enum EcommerceTicketContentType {
    case ticket(_ config: EcommerceTicketContainerConfiguration)
    case errorData(reason: String?)
    case loading
}

public enum EcommercePaymentStatus: Equatable {
    case identifying
    case success
    case errorConfirmation(_ message: String)
    case errorData(reason: String?)
    case expired
    
    func imageName() -> String {
        switch self {
        case .identifying:
            return "icnBigSantanderKeyLock"
        case .success:
            return "icnSantanderKeyOkLock"
        case .expired:
            return "ecommerceImgTime"
        case .errorConfirmation, .errorData:
            return ""
        }
    }
    
    func messageKey() -> String {
        switch self {
        case .identifying:
            return "ecommerce_label_identifying"
        case .success:
            return "ecommerce_label_purchaseConfirmedOk"
        case .errorConfirmation(let message):
            return message
        case .errorData(let reason):
            return reason ?? "ecommerce_label_noData"
        case .expired:
            return "ecommerce_label_expiredTime"
        }
    }
}

public enum EcommerceFooterType: Equatable {
    case confirmBy(_ type: EcommerceAuthType)
    case useCodeAccess
    case processingPayment
    case tryAgainInShop
    case emptyView
    case restorePassword
}

public enum EcommerceHeaderHeight {
    case big
    case small
}

public enum EcommerceHeaderType {
    case loading
    case content
    
    public var rawValue: Bool {
        return self == .loading
    }
}

public final class EcommerceTicketContainerConfiguration {
    let viewModel: EcommerceViewModel
    var showsCodeKeyButton: Bool
    var purchaseStatus: EcommercePaymentStatus?
    var confirmType: EcommerceAuthType
    var confirmStatus: EcommerceAuthStatus
    var opinatorViewModel: OpinatorViewModel?
    
    init(_ viewModel: EcommerceViewModel, confirmType: EcommerceAuthType, confirmStatus: EcommerceAuthStatus, opinatorViewModel: OpinatorViewModel?) {
        self.viewModel = viewModel
        self.showsCodeKeyButton = confirmType == .faceId || confirmType == .fingerPrint
        self.confirmType = confirmType
        self.confirmStatus = confirmStatus
        self.opinatorViewModel = opinatorViewModel
    }
}
