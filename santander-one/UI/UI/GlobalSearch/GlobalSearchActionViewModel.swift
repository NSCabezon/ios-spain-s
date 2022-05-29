//
//  GlobalSearchActionViewModel.swift
//  UI
//
//  Created by Johnatan Zavaleta Milla on 21/06/2021.
//

import CoreFoundationLib

public struct GlobalSearchActionViewModel {
    public let iconName: String
    private let titleKey: String
    private let descriptionKey: String
    private let highlightedDescriptionKey: String
    public let identifier: String
    public let type: GlobalSearchActionViewType
    
    public init(iconName: String,
                titleKey: String,
                descriptionKey: String,
                highlightedDescriptionKey: String,
                baseURL: String,
                identifier: String,
                type: GlobalSearchActionViewType) {
        self.iconName = baseURL + iconName
        self.titleKey = titleKey
        self.descriptionKey = descriptionKey
        self.highlightedDescriptionKey = highlightedDescriptionKey
        self.identifier = identifier
        self.type = type
    }
    
    public var title: LocalizedStylableText {
        return localized(self.titleKey)
    }
    
    public var description: LocalizedStylableText {
        return localized(self.descriptionKey)
    }
    
    public func isHighlighted() -> Bool {
        return !highlightedDescriptionKey.isEmpty
    }
    
    public var highlightedDescription: LocalizedStylableText {
        return description
    }
    
    public func highlight(_ baseString: NSAttributedString?) -> NSAttributedString {
        guard let baseString = baseString else { return NSAttributedString() }
        let ranges = baseString.string
            .ranges(of: highlightedDescriptionKey.trim())
            .map { NSRange($0, in: highlightedDescriptionKey) }
        return ranges.reduce(NSMutableAttributedString(attributedString: baseString)) {
            $0.addAttribute(.backgroundColor, value: UIColor.lightYellow, range: $1)
            return $0
        }
    }
}
