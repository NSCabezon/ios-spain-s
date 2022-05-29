//
//  NoSepaTransferEmittedDetailDTOExtensions.swift
//  SANLibraryV3
//
//  Created by José María Jiménez Pérez on 16/2/22.
//

import Foundation
import SANSpainLibrary
import CoreDomain

extension NoSepaTransferEmittedDetailDTO: NoSepaTransferRepresentable {
    public var bicSwift: String? {
        guard
            let company = self.payee?.messageSwiftCenter?.company,
            let center = self.payee?.messageSwiftCenter?.center, !company.isEmpty, !center.isEmpty else {
                return nil
        }
        
        return company + center + (self.payee?.swiftCode ?? "")
    }
    
    public var amountRepresentable: AmountRepresentable? {
        self.transferAmount
    }
    
    public var destinationAccount: String? {
        self.payee?.paymentAccountDescription
    }
    
    public var bankName: String? {
        self.payee?.bankName
    }
    
    public var bankAddress: String? {
        self.payee?.bankAddress
    }
}
