//
//  OptionWithTextFieldReasonViewModel.swift
//  UI
//
//  Created by Iván Estévez Nieto on 16/6/21.
//

import Foundation

public struct OptionWithTextFieldReasonViewModel {
    internal let description: String
    internal let placeholderText: String
    
    public init(description: String, placeholderText: String) {
        self.description = description
        self.placeholderText = placeholderText
    }
}
