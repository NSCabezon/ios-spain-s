import Foundation

public struct StringPlaceholder {
    
    public enum Placeholder: String {
        case number = "{{NUMBER}}"
        case month = "{{MONTH}}"
        case name = "{{NAME}}"
        case value = "{{VALUE}}"
        case date = "{{DATE}}"
        case phone = "{{TELF}}"

        init?(_ type: String) {
            self.init(rawValue: type)
        }
    }

    public let replacement: String
    public let placeholder: String

    public init(_ placeholder: Placeholder, _ replacement: String) {
        self.placeholder = placeholder.rawValue
        self.replacement = replacement
    }
    
    public init(_ placeholder: String, _ replacement: String) {
        self.placeholder = placeholder
        self.replacement = replacement
    }

}
