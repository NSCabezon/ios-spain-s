import CoreFoundationLib

public enum FlipViewStyle {
    case showNumberLabel
    case hideNumberLabel
}

public struct PhoneViewModel {
    public let phone: String
    public let title: LocalizedStylableText?
    public var viewStyle: FlipViewStyle
    public init(phone: String, title: LocalizedStylableText? = nil, viewStyle: FlipViewStyle = .showNumberLabel) {
        self.phone = phone
        self.title = title
        self.viewStyle = viewStyle
    }
    public init(phone: String) {
        self.phone = phone
        self.title = nil
        self.viewStyle = .showNumberLabel
    }
}
