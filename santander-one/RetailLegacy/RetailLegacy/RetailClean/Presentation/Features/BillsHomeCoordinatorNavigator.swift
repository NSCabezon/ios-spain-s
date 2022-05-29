//
//  BillsHomeCoordinatorNavigator.swift
//  RetailClean
//
//  Created by Juan Carlos López Robles on 2/26/20.
//  Copyright © 2020 Ciber. All rights reserved.
//

import Foundation
import CoreFoundationLib
import Bills
import FinantialTimeline

extension NSNotification.Name {
    static let billsFaqsAnalytics: Self = .init("billsFaqsAnalytics")
}

final class BillsHomeCoordinatorNavigator: ModuleCoordinatorNavigator {
    private var type: BillsAndTaxesTypeOperativePayment? {
        didSet {
            NotificationCenter.default.removeObserver(self)
            NotificationCenter.default.addObserver(forName: .billsFaqsAnalytics, object: nil, queue: nil) { [weak self] (notification) in
                guard let userInfo = notification.userInfo,
                      let parameters = userInfo["parameters"] as? [String : String]
                else { return }
                var screenName = ""
                switch self?.type {
                case .billPayment: screenName = "payments_other_entities"
                case .taxes: screenName = "payments_taxes"
                case .bills: screenName = "payment_receipts"
                default: return
                }
                let event = parameters.keys.contains("faq_link") ? "click_link_faq" : "click_show_faq"
                self?.dependencies.trackerManager.trackEvent(screenId: screenName, eventId: event, extraParameters: parameters)
            }
        }
    }
}

extension BillsHomeCoordinatorNavigator: BillHomeModuleCoordinatorDelegate {
    func didSelectTimeLine() {
        let timeLine = TimeLine.load()
        self.viewController?.navigationController?.pushViewController(timeLine, animated: true)
    }
    
    func didSelectSearch() {
        navigatorProvider.privateHomeNavigator.goToGlobalSearch()
    }
    
    func didSelectDismiss() {
        viewController?.navigationController?.popViewController(animated: true)
    }
    
    func didSelectMenu() {
        drawer?.toggleSideMenu()
    }
 
    func didSelectLastBill(detail: LastBillDetail, detailList: [LastBillDetail]) {
        let selectedBill = BillAndAccount(
            bill: Bill(dto: detail.bill.dto),
            account: Account(detail.account)
        )
        
        let bills: [BillAndAccount] = detailList.map {
            BillAndAccount(bill: Bill(dto: $0.bill.dto), account: Account($0.account))
        }
        
        guard let index = bills.firstIndex(of: selectedBill) else { return }
        self.navigatorProvider
            .billsHomeNavigator
            .navigateToTransactionDetail(bills, selectedPosition: index)
    }
    
    func didSelectReturnReceipt(bill: LastBillEntity, billDetail: LastBillDetailEntity) {
        let bill = Bill(dto: bill.dto)
        let detail = BillDetail(dto: billDetail.dto)
        self.showReceiptReturn(bill: bill, billDetail: detail, delegate: self)
    }
    
    func showAlertDialog(body: String?) {
        self.showAlertError(keyTitle: nil, keyDesc: body, completion: nil)
    }
    
    func showAlertDialog(title: String?, body: String?) {
        self.showAlertError(keyTitle: title, keyDesc: body, completion: nil)
    }
    
    func didSelectSeePDF(_ document: Data) {
        self.navigatorProvider.billsHomeNavigator.goToPdfViewer(pdfData: document)
    }
    
    func goToBillFinancing(_ offer: OfferEntity) {
        self.executeOffer(offer)
    }
}
extension BillsHomeCoordinatorNavigator: DirectDebitCoordinatorDelegate {
    func didSelectDirectDebit(accountEntity: AccountEntity?) {
        self.showChangeMassiveDirectDebits(account: accountEntity.map({ Account($0) }), delegate: self)
    }
    
    func showAlertDialog(acceptTitle: LocalizedStylableText, cancelTitle: LocalizedStylableText?, title: LocalizedStylableText? = nil, body: LocalizedStylableText, acceptAction: (() -> Void)?, cancelAction: (() -> Void)?) {
        guard let viewController = viewController else { return }
        let acceptComponents = DialogButtonComponents(titled: acceptTitle, does: acceptAction)
        var cancelComponents: DialogButtonComponents?
        if let cancelTitle = cancelTitle {
            cancelComponents = DialogButtonComponents(titled: cancelTitle, does: cancelAction)
        }
        Dialog.alert(title: title, body: body, rightButton: acceptComponents, leftButton: cancelComponents, source: viewController, showCloseButton: true)
    }
}

extension BillsHomeCoordinatorNavigator: PaymentCoordinatorDelegate {
    func didSelectBillEmittersPayment(account: AccountEntity?) {
        self.type = .billPayment
        self.goToBillEmittersPayment(account: account, handler: self)
    }
    
    func didSelectPayment(accountEntity: AccountEntity?, type: BillsAndTaxesTypeOperativePayment?) {
        self.type = type
        self.showBillsAndTaxesScannerOperative(accountEntity.map({ Account($0) }), type: type, delegate: self)
    }
}

extension BillsHomeCoordinatorNavigator: ReceiptReturnOperativeLauncher {}
extension BillsHomeCoordinatorNavigator: BillsAndTaxesScannerLauncher {}
extension BillsHomeCoordinatorNavigator: ChangeMassiveDirectDebitsOperativeLauncher {}
extension BillsHomeCoordinatorNavigator: BillSearchFiltersCoordinatorDelegate {}
extension BillsHomeCoordinatorNavigator: BillEmittersPaymentLauncher {}
