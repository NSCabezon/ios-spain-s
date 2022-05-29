//
//  BillHomeModuleCoordinatorMock.swift
//  Pods
//
//  Created by Daniel Gómez Barroso on 20/9/21.
//

import CoreFoundationLib
import UI

public final class BillHomeModuleCoordinatorMock: BillHomeModuleCoordinatorDelegate {
    public func goToBillFinancing(_ offer: OfferEntity) { }
    
    public func showAlertDialog(title: String?, body: String?) { }
    
    public func didSelectReturnReceipt(bill: LastBillEntity, billDetail: LastBillDetailEntity) { }
    
    public func didSelectSeePDF(_ document: Data) { }
    
    public func showAlertDialog(body: String?) { }
    
    public func didSelectPayment(accountEntity: AccountEntity?, type: BillsAndTaxesTypeOperativePayment?) { }
    
    public func didSelectSearch() { }
    
    public func didSelectMenu() { }
    
    public func didSelectDismiss() { }
    
    public func didSelectTimeLine() { }
    
    public func didSelectPayment(accountEntity: AccountEntity?) { }
    
    public func didSelectDirectDebit(accountEntity: AccountEntity?) { }
    
    public func didSelectLastBill(detail: LastBillDetail, detailList: [LastBillDetail]) { }
    
    public func didSelectPension(url: URL?) { }
    
    public func didSelectUnemploymentBenefit(url: URL?) { }
}
