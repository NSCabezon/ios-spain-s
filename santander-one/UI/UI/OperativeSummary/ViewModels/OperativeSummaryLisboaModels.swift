import Foundation

public struct OperativeSummaryLisboaHeaderViewModel {
    public let imageName: String
    public let title: String
    public let subtitleKey: String?
    public let descriptionKey: String
    public let isOk: Bool
    
    public init(imageName: String, title: String, subtitleKey: String?, descriptionKey: String, isOk: Bool) {
        self.imageName = imageName
        self.title = title
        self.subtitleKey = subtitleKey
        self.descriptionKey = descriptionKey
        self.isOk = isOk
    }
}

public struct OperativeSummaryLisboaDetailHeaderViewModel {
    public let title: String
    public let total: String
    
    public init(title: String, total: String) {
        self.title = title
        self.total = total
    }
}

public struct OperativeSummaryLisboaDetailViewModel {
    public let title: String
    public let subtitle: NSMutableAttributedString
    public let accessibilityIdentifier: String
    public let info: String?
    public let baseUrl: String?
    
    public init(title: String, subtitle: NSMutableAttributedString, accessibilityIdentifier: String, info: String? = nil, baseUrl: String? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.accessibilityIdentifier = accessibilityIdentifier
        self.info = info
        self.baseUrl = baseUrl
    }
}

public struct OperativeSummaryLisboaShortcutsViewModel {
    public let title: String
    public let elements: [OperativeSummaryLisboaShortcutViewModel]
    
    public init(title: String, elements: [OperativeSummaryLisboaShortcutViewModel]) {
        self.title = title
        self.elements = elements
    }
}

public struct OperativeSummaryLisboaShortcutViewModel {
    public let title: String
    public let imageName: String
    public let accessibilityIdentifier: String
    public let action: (() -> Void)
    
    public init(title: String, imageName: String, accessibilityIdentifier: String, action: @escaping (() -> Void)) {
        self.title = title
        self.imageName = imageName
        self.accessibilityIdentifier = accessibilityIdentifier
        self.action = action
    }
}
