//
//  EnvironmentViewModel.swift
//  Commons
//
//  Created by Juan Carlos López Robles on 11/27/20.
//

import Foundation

public protocol PickerElement: Equatable {
    var value: String { get }
    var accessibilityIdentifier: String? { get set }
}

public struct EnvironmentViewModel: PickerElement {
    public var title: String
    public var url: String
    public var accessibilityIdentifier: String?
    
    public init(title: String, url: String, accessibilityIdentifier: String? = nil) {
        self.title = title
        self.url = url
        self.accessibilityIdentifier = accessibilityIdentifier
    }
    
    public var value: String {
        return title
    }
    
    public static func == (lhs: EnvironmentViewModel, rhs: EnvironmentViewModel) -> Bool {
        return lhs.title == rhs.title
    }
}
