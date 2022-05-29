import Foundation
import SANLegacyLibrary

public class FieldsUtils {
    public static let amountDTO = AmountDTO(value: Decimal(floatLiteral: 1000), currency: CurrencyDTO.create(SharedCurrencyType.default))
    public static let amountTransferDTO = AmountDTO(value: Decimal(floatLiteral: 10), currency: CurrencyDTO.create(SharedCurrencyType.default))
    public static let amountDirectMoney = AmountDTO(value: Decimal(floatLiteral: 301.50), currency: CurrencyDTO.create(SharedCurrencyType.default))
    public static let NEW_SIGNATURE = "44444444"
    public static let OLD_ACCESS_PASSWORD = "14725836"
    public static let NEW_ACCESS_PASSWORD = "22222222"
    public static let ACCOUNT_NEW_ALIAS = "CTA.CTE.SANTANDER"
    public static let CARD_NEW_ALIAS = "MI TARJETA PREF"
    public static let STOCK_PERIODICAL_ACTIVE = "AC"
    public static let STOCK_ORDER_STATUS_PENDING = "PENDIENTE"
    public static let STOCK_TYPE_ORDER_AT_BEST = "0"
    public static let STOCK_TYPE_ORDER_AT_MARKET = "4"
    public static let MOBILE_RECHARGE_MOBIL = "676025541"

    public class func getSignatureXml(signatureDTO: SignatureDTO) -> String {
        var output = ""
        guard let positions = signatureDTO.positions,
              !positions.isEmpty,
              let values = signatureDTO.values else { return output }

        positions.enumerated().forEach { idx, pos in
            output += "<c\(pos)>\(values[idx])</c\(pos)>"
        }
        return output
    }
}
