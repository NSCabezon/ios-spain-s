//
//  LoanTransactionDetailActionType.swift
//  Loans
//
//  Created by alvola on 28/2/22.
//

import Foundation
import CoreFoundationLib
import CoreDomain

extension LoanTransactionDetailActionType {
    func values() -> (title: String, imageName: String) {
        switch self {
        case .partialAmortization: return ("transaction_buttonOption_amortizationPartial", "icnAmortizationPartial")
        case .changeAccount: return ("transaction_buttonOption_changeAccount", "icnChangeAccount")
        case .configureAlerts: return ("loansOption_button_settingAlerts", "icnAlertConfig")
        case .pdfExtract: return ("transaction_buttonOption_viewPdf", "icnRedPdf")
        case .share: return ("generic_button_share", "icnShare")
        case .showDetail: return ("transaction_buttonOption_detailLoan", "icnInfo")
        }
    }
    
    func getAccesibilityIds() -> LoanActionAccessibilityIds {
        switch self {
        case .pdfExtract:
            return LoanActionAccessibilityIds(container: AccessibilityIDLoansTransactionsDetail.actionPDFContainer.rawValue,
                                              icon: AccessibilityIDLoansTransactionsDetail.actionPDFIcon.rawValue,
                                              title: AccessibilityIDLoansTransactionsDetail.actionPDFLabel.rawValue)
        case .share:
            return LoanActionAccessibilityIds(container: AccessibilityIDLoansTransactionsDetail.actionShareContainer.rawValue,
                                              icon: AccessibilityIDLoansTransactionsDetail.actionShareIcon.rawValue,
                                              title: AccessibilityIDLoansTransactionsDetail.actionShareLabel.rawValue)
        case .partialAmortization:
            return LoanActionAccessibilityIds(container: AccessibilityIDLoansTransactionsDetail.actionAmortizationPartialContainer.rawValue,
                                              icon: AccessibilityIDLoansTransactionsDetail.actionAmortizationPartialIcon.rawValue,
                                              title: AccessibilityIDLoansTransactionsDetail.actionAmortizationPartialLabel.rawValue)
        case .changeAccount:
            return LoanActionAccessibilityIds(container: AccessibilityIDLoansTransactionsDetail.actionChangeAccountContainer.rawValue,
                                              icon: AccessibilityIDLoansTransactionsDetail.actionChangeAccountIcon.rawValue,
                                              title: AccessibilityIDLoansTransactionsDetail.actionChangeAccountLabel.rawValue)
        case .showDetail:
            return LoanActionAccessibilityIds(container: AccessibilityIDLoansTransactionsDetail.actionSeeDetailContainer.rawValue,
                                              icon: AccessibilityIDLoansTransactionsDetail.actionSeeDetailAccountIcon.rawValue,
                                              title: AccessibilityIDLoansTransactionsDetail.actionSeeDetailAccountLabel.rawValue)
        default:
            return LoanActionAccessibilityIds(container: "", icon: "", title: "")
        }
    }
    
    func getViewType(_ renderingMode: UIImage.RenderingMode = .alwaysTemplate) -> ActionButtonFillViewType {
        let optionValues = self.values()
        let ids = self.getAccesibilityIds()
        return .defaultButton(DefaultActionButtonViewModel(title: optionValues.title,
                                                           imageKey: optionValues.imageName,
                                                           renderingMode: renderingMode,
                                                           titleAccessibilityIdentifier: ids.title ?? optionValues.title,
                                                           imageAccessibilityIdentifier: ids.icon ?? optionValues.imageName,
                                                           accessibilityButtonValue: ids.container)
        )
    }
}

extension LoanTransactionDetailActionType: AccessibilityProtocol {
    public var accessibilityIdentifier: String? {
        switch self {
        case .pdfExtract:
            return AccessibilityIDLoansTransactionsDetail.actionPDFContainer.rawValue
        case .share:
            return AccessibilityIDLoansTransactionsDetail.actionShareContainer.rawValue
        case .partialAmortization:
            return AccessibilityIDLoansTransactionsDetail.actionAmortizationPartialContainer.rawValue
        case .changeAccount:
            return AccessibilityIDLoansTransactionsDetail.actionChangeAccountContainer.rawValue
        case .showDetail:
            return AccessibilityIDLoansTransactionsDetail.actionSeeDetailContainer.rawValue
        default:
            return ""
        }
    }
}

extension LoanTransactionDetailActionType: Trackable {
    public var trackName: String? {
        switch self {
        case .partialAmortization:
            return "amortizacion_parcial"
        case .changeAccount:
            return "cambio_cuenta_cargo"
        case .configureAlerts:
            return "configurar_alertas"
        case .pdfExtract:
            return "consultar_extracto"
        case .share:
            return "compartir"
        case .showDetail:
            return "consultar_detalle"
        }
    }
}

extension LoanTransactionDetailActionType: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.trackName)
    }
    
    public static func == (lhs: LoanTransactionDetailActionType, rhs: LoanTransactionDetailActionType) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
