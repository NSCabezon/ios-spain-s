//
//  Dialog+Extension.swift
//  Operative
//
//  Created by Jose Carlos Estela Anguita on 13/01/2020.
//

import Foundation
import UI
import CoreFoundationLib

public typealias DialogAction = (title: String, action: () -> Void)
public enum DialogItem {
    
    case text(String)
    case styledText(LocalizedStylableText, Bool)
    case listItem(String)
    case alignedStyledText(LocalizedStylableText, alignment: NSTextAlignment)
    
    func toDialogItemView() -> Dialog.Item {
        switch self {
        case .text(let text):
            return .text(text)
        case .listItem(let text):
            return .listItem(text, margin: .zero())
        case .styledText(let text, let hasTitleAndNotAlignment):
            return .styledText(text, hasTitleAndNotAlignment: hasTitleAndNotAlignment)
        case .alignedStyledText(let text, alignment: let alignment):
            return .styledConfiguredText(text, configuration: LocalizedStylableTextConfiguration(alignment: alignment))
        }
    }
}
