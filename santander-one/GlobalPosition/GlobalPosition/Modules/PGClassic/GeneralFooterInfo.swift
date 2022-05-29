//
//  GeneralFooterInfo.swift
//  GlobalPosition
//
//  Created by Rubén Márquez Fernández on 1/7/21.
//

import Foundation
import CoreFoundationLib

struct GeneralFooterInfo {
    let title: LocalizedStylableText
    let amount: NSAttributedString?
    let footerWhenExpanded: Bool
    let cardsStringURL: [String]?
}
