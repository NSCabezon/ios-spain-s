import Foundation

public class AmountFormats {

    public class func formattedAmountForWS(amount: Decimal) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.decimalSeparator = "."
        numberFormatter.groupingSeparator = ""

        return numberFormatter.string(from: amount as NSDecimalNumber) ?? ""
    }

    public class func getValueForWS(value: Decimal?) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.decimalSeparator = "."
        numberFormatter.groupingSeparator = ""
        numberFormatter.negativeFormat = "#,##0.00"
        numberFormatter.positiveFormat = "#,##0.00"

        if let value = value {
            return numberFormatter.string(from: value as NSDecimalNumber) ?? ""
        }

        return ""
    }

    public class func getValueForWS5Decs(value: Decimal?) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.decimalSeparator = "."
        numberFormatter.groupingSeparator = ""
        numberFormatter.negativeFormat = "#,##0.00000"
        numberFormatter.positiveFormat = "#,##0.00000"

        if let value = value {
            return numberFormatter.string(from: value as NSDecimalNumber) ?? ""
        }

        return ""
    }

    /*
     No funciona.
    */
    public class func getDecimalForWS(value: Decimal?) -> String {
        guard let value = value else {
            return ""
        }
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.decimalSeparator = "."
        numberFormatter.groupingSeparator = ""
        numberFormatter.negativeFormat = "###########0.00"
        numberFormatter.positiveFormat = "###########0.00"
        guard let valueFormatter = numberFormatter.string(from: value as NSDecimalNumber) else {
            return ""
        }
        return (value > 0 ? "+" : "") + valueFormatter
    }

    public class func getSharesFormattedForWS(sharesNumber: Decimal) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        numberFormatter.decimalSeparator = "."
        numberFormatter.groupingSeparator = ""
        numberFormatter.negativeFormat = "#,##0.00000"
        numberFormatter.positiveFormat = "#,##0.00000"
        return numberFormatter.string(from: sharesNumber as NSDecimalNumber) ?? ""
    }
}
