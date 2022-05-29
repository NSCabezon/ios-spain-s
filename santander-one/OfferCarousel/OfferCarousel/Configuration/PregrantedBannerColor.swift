//
//  PregrantedBannerColor.swift
//  GlobalPosition
//
//  Created by Cristobal Ramos Laina on 04/08/2020.
//

import Foundation
import CoreFoundationLib
import SANLegacyLibrary

public enum PregrantedBannerColor: String {
    case white
    case blue
    case black
    case smart
    
    // MARK: - Initializers
    
    public init(value: String) {
        switch value {
        case "blanco":
            self = .white
        case "azul":
            self = .blue
        case "negro":
            self = .black
        default:
            self = .white
        }
    }
    
    // MARK: - Public methods
    
    public func color() -> UIColor {
        switch self {
        case .white:
            return .clear
        case .blue:
            return .lightTurquoise
        case .black:
            return .blueAnthracita
        case .smart:
            return UIColor.white.withAlphaComponent(0.2)
        default:
            return .clear
        }
    }
    
    public func arrowImage() -> String {
        switch self {
        case .black, .smart:
            return "icnArrowRightPgWhite"
        default:
            return "icnArrowRightPg"
        }
    }
    
    public func icnPayTax() -> String {
        switch self {
        case .black, .smart:
            return "icnPayTax1White"
        default:
            return "icnPayTax1"
        }
    }
    
    public func colorTitle() -> UIColor {
        switch self {
        case .black, .smart:
            return .white
        default:
            return .lisboaGray
        }
    }
    
    public func getLiteral(text: String, amount: Float) -> LocalizedStylableText {
        let amountAsDouble = Double(exactly: amount) ?? 0.0
        guard !text.isEmpty else {
            switch self {
            case .black, .smart:
                let amountEntity = AmountEntity(value: Decimal(amountAsDouble))
                return localized("pg_label_preconceivedTop_white", [StringPlaceholder(.value, amountEntity.getStringValue(withDecimal: 0))])
            default:
                let amountEntity = AmountEntity(value: Decimal(amountAsDouble))
                return localized("pg_label_preconceivedTop", [StringPlaceholder(.value, amountEntity.getStringValue(withDecimal: 0))])
            }
        }
        
        let amountEntity = AmountEntity(value: Decimal(amountAsDouble))
        let key = text.replacingOccurrences(of: "{{VALUE}}", with: amountEntity.getStringValue(withDecimal: 0))
        return localized(key)
    }
    
    public func pregrantedStartedDefaultTitleKey() -> String {
        switch self {
        case .black, .smart:
            return "pg_label_preconceivedStartedTop_white"
        default:
            return "pg_label_preconceivedStartedTop"
        }
    }
}
