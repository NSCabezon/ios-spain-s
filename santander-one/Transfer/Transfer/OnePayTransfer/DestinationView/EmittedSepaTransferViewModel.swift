//
//  EmittedSepaTransferViewModel.swift
//  Transfer
//
//  Created by Laura González on 30/07/2020.
//

import Foundation
import CoreFoundationLib

public protocol EmittedSepaTransferViewModel {
    var beneficiaryName: String { get set }
    var accountIban: String { get set }
    var colorsByNameViewModel: ColorsByNameViewModel { get set }
    var transferEmitted: TransferEmittedEntity { get set }
    var bankIconUrl: String { get set }
}

extension EmittedSepaTransferViewModel {
    var name: String {
        return self.beneficiaryName.capitalizedIgnoringNumbers()
    }
    
    var avatarColor: UIColor {
        return self.colorsByNameViewModel.color
    }
    
    var avatarName: String {
        return self.name
            .split(" ")
            .prefix(2)
            .map({ $0.prefix(1) })
            .joined()
            .uppercased()
    }
}
