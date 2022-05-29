//
//  OneSmallSelectorListViewModel.swift
//  Commons
//
//  Created by Angel Abad Perez on 10/1/22.
//

import Foundation

public struct OneSmallSelectorListViewModel {
    public let leftTextKey: String
    public let rightAccessory: RightAccessory
    public let status: Status
    public let highlightedText: String?
    public var accessibilitySuffix: String?
    
    public init(leftTextKey: String,
                rightAccessory: RightAccessory,
                status: Status,
                highlightedText: String? = nil,
                accessibilitySuffix: String? = nil) {
        self.leftTextKey = leftTextKey
        self.rightAccessory = rightAccessory
        self.status = status
        self.highlightedText = highlightedText
        self.accessibilitySuffix = accessibilitySuffix
    }
    
    public enum RightAccessory {
        case none
        case icon(imageName: String)
        case text(textKey: String)
    }
    public enum Status {
        case activated
        case inactive
    }
}
