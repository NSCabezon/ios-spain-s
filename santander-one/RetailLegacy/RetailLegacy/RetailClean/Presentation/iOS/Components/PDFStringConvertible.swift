protocol PDFStringConvertible {
    var pdfString: String { get }
}

struct PDFInfo: Equatable {
    let key: String
    let value: PDFStringConvertible
    
    static func == (lhs: PDFInfo, rhs: PDFInfo) -> Bool {
        return lhs.key == rhs.key
    }
}

extension Amount: PDFStringConvertible {
    var pdfString: String {
        return getAbsFormattedAmountUI()
    }
}

extension String: PDFStringConvertible {
    var pdfString: String {
        return description
    }
}
