//
//  IbanFormatter.swift
//  Commons
//
//  Created by Cristobal Ramos Laina on 19/02/2021.
//

import Foundation

public protocol ShareIbanFormatterProtocol {
    func ibanPapel(_ iban: IBANEntity?) -> String
    func shareAccountNumber(_ account: AccountEntity) -> String
}
