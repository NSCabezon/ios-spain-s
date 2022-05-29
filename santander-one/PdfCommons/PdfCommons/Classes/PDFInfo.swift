import CoreFoundationLib

public protocol PDFStringConvertible {
    var pdfString: String { get }
}

public struct PDFInfo: Equatable {
    public let key: String
    public let value: PDFStringConvertible
    
    public init(key: String, value: PDFStringConvertible) {
        self.key = key
        self.value = value
    }
    
    public static func == (lhs: PDFInfo, rhs: PDFInfo) -> Bool {
        return lhs.key == rhs.key
    }
}

extension AmountEntity: PDFStringConvertible {
    public var pdfString: String {
        return getAbsFormattedAmountUI()
    }
}

extension String: PDFStringConvertible {
    public var pdfString: String {
        return description
    }
}
