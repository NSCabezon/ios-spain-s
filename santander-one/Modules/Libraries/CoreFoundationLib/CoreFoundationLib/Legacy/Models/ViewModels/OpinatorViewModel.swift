//
//  OpinatorViewModel.swift
//  Models
//
//  Created by Tania Castellano Brasero on 28/7/21.
//

import Foundation

public struct OpinatorViewModel {
    public let description: String
    public let opinatorPath: String
    public let accessibilityOfView: String
    
    public init(description: String, opinatorPath: String, accessibilityOfView: String) {
        self.description = description
        self.opinatorPath = opinatorPath
        self.accessibilityOfView = accessibilityOfView
    }
}
