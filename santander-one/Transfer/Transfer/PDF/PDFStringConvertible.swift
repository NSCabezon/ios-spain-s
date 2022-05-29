import CoreFoundationLib
import PdfCommons

extension AmountEntity {
    public var pdfString: String {
        return getAbsFormattedAmountUI()
    }
}

extension String {
    public var pdfString: String {
        return description
    }
}
