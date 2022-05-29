//
//  CoreCurrencyDefault.swift
//  Models
//
//  Created by José María Jiménez Pérez on 18/6/21.
//

import SANLegacyLibrary

public class CoreCurrencyDefault {
    public static var `default`: CurrencyType = .eur {
        didSet {
            SharedCurrencyType.default = `default`
        }
    }
}
