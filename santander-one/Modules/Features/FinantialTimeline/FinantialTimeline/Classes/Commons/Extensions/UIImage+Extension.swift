//
//  UIImage.swift
//  FinantialTimeline
//
//  Created by José Carlos Estela Anguita on 04/07/2019.
//

import UIKit

extension UIImage {
    
    convenience init?(fromModuleWithName name: String) {
        self.init(named: name, in: .module, compatibleWith: nil)
    }
    
    static func icon(for type: TimeLineEvent.TransactionType) -> UIImage? {
        switch type {
        case .unknown, .receivedBizum, .receivedTransfer:
             return UIImage(fromModuleWithName: "icTransfer000")?.withRenderingMode(.alwaysTemplate)
        case .deferredTransfer, .bizum:
             return UIImage(fromModuleWithName: "icTransfer100")?.withRenderingMode(.alwaysTemplate)
        case .periodicTransfer:
             return UIImage(fromModuleWithName: "icTransfer101")?.withRenderingMode(.alwaysTemplate)
        case .bill:
             return UIImage(fromModuleWithName: "icTransfer102")?.withRenderingMode(.alwaysTemplate)
        case .cardSubscription:
             return UIImage(fromModuleWithName: "icTransfer103")?.withRenderingMode(.alwaysTemplate)
        case .mortage:
             return UIImage(fromModuleWithName: "icTransfer104")?.withRenderingMode(.alwaysTemplate)
        case .loan:
             return UIImage(fromModuleWithName: "icTransfer105")?.withRenderingMode(.alwaysTemplate)
        case .insurance:
             return UIImage(fromModuleWithName: "icTransfer106")?.withRenderingMode(.alwaysTemplate)
        case .pensionPlan:
             return UIImage(fromModuleWithName: "icTransfer107")?.withRenderingMode(.alwaysTemplate)
        case .cardSettlement:
             return UIImage(fromModuleWithName: "icTransfer108")?.withRenderingMode(.alwaysTemplate)
        case .payroll:
             return UIImage(fromModuleWithName: "icTransfer200")?.withRenderingMode(.alwaysTemplate)
        case .newProduct:
             return UIImage(fromModuleWithName: "icTransfer300")?.withRenderingMode(.alwaysTemplate)
        case .productRemoved:
             return UIImage(fromModuleWithName: "icTransfer301")?.withRenderingMode(.alwaysTemplate)
        case .expiration, .maturity:
             return UIImage(fromModuleWithName: "icTransfer302")?.withRenderingMode(.alwaysTemplate)
        case .personalEvent, .customEvent, .masterEvent:
             return UIImage(fromModuleWithName: "icTransfer900")?.withRenderingMode(.alwaysTemplate)
        case .externalEvent:
             return UIImage(fromModuleWithName: "icTransfer901")?.withRenderingMode(.alwaysTemplate)
        case .externalEventBegins, .externalEventEnds, .externalEventExpires:
             return UIImage(fromModuleWithName: "icTransfer904")?.withRenderingMode(.alwaysTemplate)
        case .noEvent:
             return UIImage(fromModuleWithName: "icNoEvents")
        }
        
        
        
        
//        switch type {
//        case .deferredTransfer, .periodicTransfer:
//            return UIImage(fromModuleWithName: "icTransfer")?.withRenderingMode(.alwaysTemplate)
//        case .bill:
//            return UIImage(fromModuleWithName: "icBill")?.withRenderingMode(.alwaysTemplate)
//        case .mortage:
//            return UIImage(fromModuleWithName: "icMortgage")?.withRenderingMode(.alwaysTemplate)
//        case .pensionPlan:
//            return UIImage(fromModuleWithName: "icPension")?.withRenderingMode(.alwaysTemplate)
//        case .customEvent, .externalEvent, .externalEventBegins, .externalEventEnds, .externalEventExpires:
//            return UIImage(fromModuleWithName: "icPersonalEvent")?.withRenderingMode(.alwaysTemplate)
//        case .unknown, .insurance, .loan, .payroll, .expiration, .productRemoved, .newProduct, .cardSubscription, .cardSettlement, .maturity:
//            return UIImage(fromModuleWithName: "icGeneric")?.withRenderingMode(.alwaysTemplate)
//        case .noEvent:
//            return UIImage(fromModuleWithName: "icNoEvents")?.withRenderingMode(.alwaysTemplate)
//        }
    }
}



