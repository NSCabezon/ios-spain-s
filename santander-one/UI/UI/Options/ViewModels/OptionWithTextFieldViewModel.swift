//
//  OptionWithTextFieldViewModel.swift
//  UI
//
//  Created by Iván Estévez Nieto on 16/6/21.
//

import Foundation

public struct OptionWithTextFieldViewModel {
    let title: String
    let subtitle: String
    let expandable: OptionWithTextFieldReasonViewModel?
    
    public init(title: String, subtitle: String, expandable: OptionWithTextFieldReasonViewModel? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.expandable = expandable
    }
}
