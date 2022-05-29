//
//  BizumDonationOperative+Opinator.swift
//  Bizum
//
//  Created by Carlos Monfort Gómez on 22/03/2021.
//

import Foundation
import Operative
import CoreFoundationLib

extension BizumDonationOperative: OperativeOpinatorCapable {
    var opinator: RegularOpinatorInfoEntity {
        RegularOpinatorInfoEntity(path: "app-bizum-donacion_exito")
    }
}

extension BizumDonationOperative: OperativeGiveUpOpinatorCapable {
    var giveUpOpinator: GiveUpOpinatorInfoEntity {
        GiveUpOpinatorInfoEntity(path: "app-bizum-donacion-abandono")
    }
}
