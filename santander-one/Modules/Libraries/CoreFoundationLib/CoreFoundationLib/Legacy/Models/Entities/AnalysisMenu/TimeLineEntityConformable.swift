//
//  TimeLineEntityConformable.swift
//  Models
//
//  Created by Boris Chirino Fernandez on 21/04/2020.
//

import Foundation

public protocol TimeLineEntityConformable {
    var amount: Decimal {get set}
    var merchant: (code: String, name: String) {get set}
    var fullDate: Date {get set}
    var month: String {get set}
    var ibanEntity: IBANEntity? { get set }
}
