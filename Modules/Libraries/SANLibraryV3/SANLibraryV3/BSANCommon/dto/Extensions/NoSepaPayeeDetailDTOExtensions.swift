//
//  NoSepaPayeeDetailDTOExtensions.swift
//  SANLibraryV3
//
//  Created by José María Jiménez Pérez on 16/2/22.
//

import SANSpainLibrary
import CoreDomain

extension NoSepaPayeeDetailDTO: SPNoSepaPayeeDetailRepresentable {
    public var amountRepresentable: AmountRepresentable? {
        self.amount
    }
    
    public var countryCode: String? {
        self.payee?.bankCountryCode
    }
    
    public var bicSwift: String? {
        self.payee?.swiftCode ?? ""
    }
    
    public var bankName: String? {
        self.payee?.bankName
    }
    
    public var bankAddress: String? {
        self.payee?.bankAddress
    }
    
    public var destinationAccount: String? {
        self.payee?.paymentAccountDescription
    }
    
    public var payeeRepresentable: NoSepaPayeeRepresentable? {
        return payee
    }
}
