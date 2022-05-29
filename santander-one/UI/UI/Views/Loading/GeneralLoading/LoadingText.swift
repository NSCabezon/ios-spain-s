//
//  LoadingText.swift
//  UI
//
//  Created by Carlos Monfort Gómez on 19/11/2020.
//

import Foundation
import CoreFoundationLib

public struct LoadingText {
    let title: LocalizedStylableText
    let subtitle: LocalizedStylableText
    
    public static var empty = LoadingText(title: LocalizedStylableText(text: "", styles: nil))
    
    public init(title: LocalizedStylableText) {
        self.title = title
        self.subtitle = LocalizedStylableText(text: "", styles: nil)
    }
    
    public init(title: LocalizedStylableText, subtitle: LocalizedStylableText) {
        self.title = title
        self.subtitle = subtitle
    }
}
