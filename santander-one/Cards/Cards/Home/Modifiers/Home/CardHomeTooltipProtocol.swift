//
//  CardHomeTooltipProtocol.swift
//  RetailLegacy
//
//  Created by Pedro Meira on 25/02/2021.
//

import Foundation

public protocol CardHomeTooltipProtocol {
    func getOptions() -> [CustomOptionWithTooltipCarsdHome]
}

public class CustomOptionWithTooltipCarsdHome {
    let textKey: String
    let iconKey: String

    public init(text: String, icon: String) {
        self.textKey = text
        self.iconKey = icon
    }
}
