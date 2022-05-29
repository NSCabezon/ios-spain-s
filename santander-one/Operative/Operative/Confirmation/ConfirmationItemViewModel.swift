import CoreFoundationLib

public typealias ConfirmationItemAction = (title: String, action: () -> Void)

public final class ConfirmationItemViewModel {

    public enum Position {
        case first
        case unknown
        case last
    }
    
    let title: LocalizedStylableText
    let value: NSAttributedString
    public let info: NSAttributedString?
    let action: ConfirmationItemAction?
    let position: Position
    let accessibilityIdentifier: String?
    let baseUrl: String?
    
    public convenience init(
        from item: ConfirmationItemViewModel,
        position: Position
    ) {
        self.init(
            title: item.title,
            value: item.value,
            position: position,
            info: item.info,
            action: item.action,
            accessibilityIdentifier: item.accessibilityIdentifier,
            baseUrl: item.baseUrl
        )
    }
    
    public convenience init(
        title: LocalizedStylableText,
        value: String,
        position: Position = .unknown,
        info: NSAttributedString? = nil,
        action: ConfirmationItemAction? = nil,
        accessibilityIdentifier: String? = nil,
        baseUrl: String? = nil
    ) {
        self.init(
            title: title,
            value: NSAttributedString(string: value),
            position: position,
            info: info,
            action: action,
            accessibilityIdentifier: accessibilityIdentifier,
            baseUrl: baseUrl
        )
    }
    
    public init(
        title: LocalizedStylableText,
        value: NSAttributedString,
        position: Position = .unknown,
        info: NSAttributedString? = nil,
        action: ConfirmationItemAction? = nil,
        accessibilityIdentifier: String? = nil,
        baseUrl: String? = nil
    ) {
        self.title = title
        self.value = value
        self.info = info
        self.action = action
        self.position = position
        self.accessibilityIdentifier = accessibilityIdentifier
        self.baseUrl = baseUrl
    }
}
