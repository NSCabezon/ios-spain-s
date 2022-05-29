//
//  File.swift
//  Commons
//
//  Created by Boris Chirino Fernandez on 13/02/2020.
//

/// Used by accountFilters to adapt entity to view instance. ex **TransactionFilterViewModel** . Every tag must have an identifier to further manipulate view elements
public struct TagMetaData: Equatable, Hashable {
    
    /// the tag used for delete button
    public static let deleteTagMetaIdentifier: String = "generic_button_deleteFilters"
    /// text displayed by the tag on the view
    public let localizedText: LocalizedStylableText
    /// see description
    public let identifier: String
    /// see description
    public let accessibilityIdentifier: String?
    
    public static func == (lhs: TagMetaData, rhs: TagMetaData) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    public init(withLocalized text: LocalizedStylableText, accessibilityId: String?) {
        self.localizedText = text
        self.identifier = TagMetaData.generateIdentifier()
        self.accessibilityIdentifier = accessibilityId
    }
    
    public init(withLocalized text: LocalizedStylableText, identifier: String, accessibilityId: String?) {
        self.localizedText = text
        self.identifier = identifier
        self.accessibilityIdentifier = accessibilityId
    }
    
    private static func generateIdentifier() -> String {
        let randomNumber: UInt32 = arc4random()
        return "Tag"+String(describing: randomNumber)
    }
}
