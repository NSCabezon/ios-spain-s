//
//  OneProductMoreOptionsAction.swift
//  UIOneComponents
//
//  Created by Iván Estévez Nieto on 26/4/22.
//

import Foundation
import OpenCombine

public protocol OneProductMoreOptionsViewModelProtocol {
    var elementsPublisher: PassthroughSubject<[OneProductMoreOptionsAction], Never> { get }
    func viewDidLoad()
}

public struct OneProductMoreOptionsAction {
    let sectionTitle: String
    let accessibilitySuffix: String?
    let elements: [OneProductMoreOptionsActionElement]
    
    public init(sectionTitle: String, accessibilitySuffix: String? = nil, elements: [OneProductMoreOptionsActionElement]) {
        self.sectionTitle = sectionTitle
        self.accessibilitySuffix = accessibilitySuffix
        self.elements = elements
    }
}

public struct OneProductMoreOptionsActionElement {
    let title: String
    let iconName: String
    let isDisabled: Bool
    let accessibilitySuffix: String?
    let action: () -> ()
    
    public init(title: String, iconName: String, isDisabled: Bool, accessibilitySuffix: String? = nil, action: @escaping () -> ()) {
        self.title = title
        self.iconName = iconName
        self.isDisabled = isDisabled
        self.action = action
        self.accessibilitySuffix = accessibilitySuffix
    }
}
