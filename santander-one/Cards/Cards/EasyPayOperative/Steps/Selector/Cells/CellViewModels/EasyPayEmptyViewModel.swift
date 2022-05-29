//
//  EasyPayEmptyViewModel.swift
//  Cards
//
//  Created by alvola on 15/12/2020.
//

import UIKit
import CoreFoundationLib

enum EmptyViewStyle {
    case normal
    case globalPosition
}

final class EmptyViewModelView {
    var identifier = "EmptyViewCell"
    var text: LocalizedStylableText
    let title: LocalizedStylableText?
    let isForcingHeight: Bool
    let style: EmptyViewStyle
    
    init(title: LocalizedStylableText?,
         text: LocalizedStylableText,
         forceHeight: Bool = false,
         style: EmptyViewStyle = .normal) {
        self.text = text
        self.title = title
        self.isForcingHeight = forceHeight
        self.style = style
    }
    
    var height: CGFloat? {
        return isForcingHeight ? 268.0 : nil
    }
}

extension EmptyViewModelView: EasyPayTableViewModelProtocol {}
