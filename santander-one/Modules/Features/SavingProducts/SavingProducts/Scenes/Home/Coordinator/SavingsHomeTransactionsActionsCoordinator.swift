//
//  SavingsHomeTransactionsActionsCoordinator.swift
//  SavingProducts
//
//  Created by Mario Rosales Maillo on 21/4/22.
//

import UI
import CoreFoundationLib
import CoreDomain
import OpenCombine
import UIKit

public enum SavingProductsTransactionsButtonsType {
    case downloadPDF
    case filter
}

public protocol SavingsHomeTransactionsActionsCoordinator: BindableCoordinator {}
