//
//  FundDetail.swift
//  Funds
//
//  Created by Ernesto Fernandez Calles on 16/3/22.
//

import Foundation

import CoreFoundationLib
import CoreDomain

struct FundDetail {
    let detail: FundDetailRepresentable

    init(detail: FundDetailRepresentable) {
        self.detail = detail
    }
}
