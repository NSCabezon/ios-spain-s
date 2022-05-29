//
//  ContactsDetailViewModel.swift
//  Transfer
//
//  Created by Carlos Monfort Gómez on 30/04/2020.
//

import CoreFoundationLib
import CoreDomain
import Foundation

struct ContactDetailViewModel {
    let favoriteType: FavoriteType
    let sepaInfoList: SepaInfoListEntity
    let baseUrl: String?
    let colorsByNameViewModel: ColorsByNameViewModel
    
    var avatarColor: UIColor {
        return self.colorsByNameViewModel.color
    }
    
    var avatarName: String {
        guard let alias = self.favoriteType.alias else {
            return ""
        }
        return alias
            .split(" ")
            .prefix(2)
            .map({ $0.prefix(1) })
            .joined()
            .uppercased()
    }
    
    private var contact: PayeeRepresentable {
        return favoriteType.favorite
    }
    
    var noSepaContact: NoSepaPayeeDetailEntity? {
        return self.favoriteType.noSepaPayeeDetail
    }
    
    var formattedAccount: String {
        return self.favoriteType.account ?? ""
    }
    
    var beneficiary: String {
        return self.favoriteType.name ?? ""
    }
    
    var currency: String {
        guard var name = self.favoriteType.favorite.currencyName.flatMap(self.sepaInfoList.currencyFor) else { return "" }
        if let symbol = self.favoriteType.currencyCode, !symbol.isEmpty {
            name += " (\(symbol))"
        }
        return name
    }
    
    var country: String {
        return self.favoriteType.countryCode.flatMap(self.sepaInfoList.countryFor) ?? ""
    }
    
    var alias: String {
        return self.favoriteType.alias?.camelCasedString ?? ""
    }
    
    var bankIconUrl: String? {
        guard let entityCode = self.contact.ibanRepresentable?.ibanElec.substring(4, 8),
              let contryCode = self.contact.countryCode,
              let baseUrl = self.baseUrl
        else { return nil }
        return String(format: "%@%@/%@_%@%@", baseUrl,
                      GenericConstants.relativeURl,
                      contryCode.lowercased(),
                      entityCode,
                      GenericConstants.iconBankExtension)
    }
    
    var beneficiaryAddress: String {
        return self.noSepaContact?.payeeAddress ?? ""
    }
    
    var beneficiaryTown: String {
        return self.noSepaContact?.payeeLocation ?? ""
    }
    
    var destinationCountry: String {
        return self.noSepaContact?.destinationCountryCode.flatMap(self.sepaInfoList.countryFor) ?? ""
    }
    
    var bicSwift: String {
        return self.noSepaContact?.bicSwift ?? ""
    }
    
    var bankName: String {
        return self.noSepaContact?.dto.payee?.bankName ?? ""
    }
    
    var bankAddress: String {
        return self.noSepaContact?.dto.payee?.bankAddress ?? ""
    }
    
    var bankTown: String {
        return self.noSepaContact?.dto.payee?.bankTown ?? ""
    }
    
    var bankCountry: String {
        return self.noSepaContact?.dto.payee?.bankCountryName ?? ""
    }
    
    var isSepa: Bool {
        return self.favoriteType.isSepa
    }
}
