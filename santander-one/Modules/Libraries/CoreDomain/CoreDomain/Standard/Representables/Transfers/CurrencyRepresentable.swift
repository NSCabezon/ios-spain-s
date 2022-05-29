//
//  CurrencyRepresentable.swift
//  CoreFoundationLib
//
//  Created by David Gálvez Alonso on 8/9/21.
//

public protocol CurrencyRepresentable {
    var currencyName: String { get }
    func getSymbol() -> String
    var currencyType: CurrencyType { get }
    var currencyCode: String { get }
}

public enum CurrencyType: Codable, RawRepresentable, Equatable {
    case eur
    case dollar
    case pound
    case swissFranc
    case złoty
    case other(String)
    
    public static func parse(_ currency: String?) -> CurrencyType {
        if let currency = currency, !currency.isEmpty {
            switch (currency.uppercased()) {
            case eur.rawValue.uppercased():
                return eur
            case dollar.rawValue.uppercased():
                return dollar
            case pound.rawValue.uppercased():
                return pound
            case swissFranc.rawValue.uppercased():
                return swissFranc
            case złoty.rawValue.uppercased():
                return złoty
            default:
                return other(currency)
            }
        }
        return other(currency ?? "")
    }
    
    public init?(rawValue: String) {
        switch rawValue {
        case "EUR": self = .eur
        case "USD": self = .dollar
        case "GBP": self = .pound
        case "CHF": self = .swissFranc
        case "PLN": self = .złoty
        default: self = .other(rawValue)
        }
    }
    
    public init?(_ type: String) {
        self.init(rawValue: type)
    }
    
    public var rawValue: String {
        switch self {
        case .eur:
            return "EUR"
        case .dollar:
            return "USD"
        case .pound:
            return "GBP"
        case .swissFranc:
            return "CHF"
        case .złoty:
            return "PLN"
        case .other(let string):
            return string
        }
    }
    
    public var name: String {
        get {
            return self.rawValue
        }
    }
    
    public var symbol: String? {
        get {
            switch self {
            case .eur:
                return "€"
            case .dollar:
                return "$"
            case .pound:
                return "£"
            case .swissFranc:
                return "CHF"
            case .złoty:
                return "PLN"
            case .other(let currency):
                return currency
            }
        }
    }
}

