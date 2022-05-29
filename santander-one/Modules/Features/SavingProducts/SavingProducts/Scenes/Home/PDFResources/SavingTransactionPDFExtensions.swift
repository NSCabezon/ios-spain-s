//
//  SavingTransactionPDFExtensions.swift
//  SavingProducts
//
//  Created by Jose Servet Font on 4/5/22.
//

import Foundation
import CoreFoundationLib

extension Double {
    /// Calculate the proportion among four numbers, using three.
    /// The proportion is used as (a/b) = (c/d)
    ///
    /// - Returns: the result of calculating number d. If a equals 0, returns nil.
    static func proportion(a: Double, b: Double, c: Double) -> Double? {
        guard a != 0 else { return nil }
        return c * b / a
    }
}

extension UIFont {

    public static func latoRegular(size: CGFloat) -> UIFont {
        return FontsHandler.shared.santander(family: .lato, type: .regular , size: size)
    }

    public static func latoBold(size: CGFloat) -> UIFont {
        return FontsHandler.shared.santander(family: .lato, type: .bold , size: size)
    }
}

extension UIColor {

    // Colors that require alpha different than 1.0 should not be added here, use withAlphaComponent(Double) instead.

    // Corporate Colors

    /// #EC0000
    /// rgb(236, 0, 0)
    public static let sanRed = UIColor(red: 236.0 / 255.0, green: 0.0, blue: 0.0, alpha: 1.0)

    /// #9B9B9B
    /// rgb(155, 155, 155)
    public static let sanGreyMedium = UIColor(white: 155.0 / 255.0, alpha: 1.0)

    /// #4A4A4A
    /// rgb(74, 74, 74)
//    public static let sanGreyDark = UIColor(white: 74.0 / 255.0, alpha: 1.0)

    /// #ECEFF3
    /// rgb(236, 239, 243)
    public static let sanGreyLight = UIColor(red: 236.0 / 255.0, green: 239.0 / 255.0, blue: 243.0 / 255.0, alpha: 1.0)

}
