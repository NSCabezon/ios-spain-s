//
//  ContactViewModel.swift
//  Transfer
//
//  Created by José Carlos Estela Anguita on 05/02/2020.
//

import CoreDomain
import Foundation
import CoreFoundationLib

public protocol ContactViewModel: Shareable {
    var contact: PayeeRepresentable { get }
    var baseUrl: String? { get }
    var colorsByNameViewModel: ColorsByNameViewModel { get }
}

extension ContactViewModel {
    var avatarColor: UIColor {
        return self.colorsByNameViewModel.color
    }
    
    var name: String {
        return self.contact.payeeDisplayName?.camelCasedString ?? ""
    }
    
    var beneficiaryName: String {
        return self.contact.payeeName?.camelCasedString ?? ""
    }
    
    var accountNumber: String {
        guard let ibanShort = self.contact.ibanRepresentable?.ibanShort(asterisksCount: 1),
              !ibanShort.isEmpty
        else { return self.contact.shortAccountNumber ?? "" }
        return ibanShort
    }
    
    var accountNumberPapel: String {
        guard let iban = self.contact.ibanRepresentable else { return accountNumber }
        return iban.ibanPapel
    }
    
    var avatarName: String {
        return self.name
            .split(" ")
            .prefix(2)
            .map({ $0.prefix(1) })
            .joined()
            .uppercased()
    }
    
    var bankIconUrl: String? {
        guard let entityCode = self.contact.ibanRepresentable?.ibanElec.substring(2, 6),
              let contryCode = self.contact.countryCode,
              let baseUrl = self.baseUrl
        else { return nil }
        return String(format: "%@%@/%@_%@%@", baseUrl,
                      GenericConstants.relativeURl,
                      contryCode.lowercased(),
                      entityCode,
                      GenericConstants.iconBankExtension)
    }
    
    var formattedAccount: String? {
        return contact.formattedAccount
    }
}

extension ContactViewModel {
    func getShareableInfo() -> String {
        return contact.formattedAccount ?? ""
    }
}

struct ContactHomeViewModel: ContactViewModel {
    let contact: PayeeRepresentable
    let baseUrl: String?
    let colorsByNameViewModel: ColorsByNameViewModel
}
