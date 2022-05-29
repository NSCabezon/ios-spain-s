//
//  TransferPackageViewModel.swift
//  Transfer
//
//  Created by Cristobal Ramos Laina on 8/6/21.
//

import Foundation
import CoreFoundationLib

public struct TransferPackageViewModel {
    let numberTransfers: Int
    let remainingTransfers: Int
    let packageName: String
    let expirationDate: String
    let transferTime: TransferTime
    
    public init(numberTransfers: Int, remainingTransfers: Int, packageName: String, expirationDate: String, transferTime: TransferTime) {
        self.numberTransfers = numberTransfers
        self.remainingTransfers = remainingTransfers
        self.packageName = packageName
        self.expirationDate = expirationDate
        self.transferTime = transferTime
    }
}
