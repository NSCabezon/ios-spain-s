import Foundation

public struct EasyPayAmortizationDTO: Codable {
    let interestAmount: [Double]?
    let amountCurrency: [String]?
    let nextAmortizationDate: [String]?
    let feeAmount: [Double]?
    let amortizedAmount: [Double]?
    let pendingAmount: [Double]?
    public var amortizations: [AmortizationDTO]?

    enum CodingKeys: String, CodingKey {
        case interestAmount = "iminters"
        case amountCurrency = "clamon3"
        case nextAmortizationDate = "feprocuo"
        case feeAmount = "imprtcuo"
        case amortizedAmount = "imcaptal"
        case pendingAmount = "cappen"
        case amortizations
    }

    public init() {
        self.interestAmount = nil
        self.amountCurrency = nil
        self.nextAmortizationDate = nil
        self.feeAmount = nil
        self.amortizedAmount = nil
        self.pendingAmount = nil
        self.amortizations = nil
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.interestAmount = try? container.decodeIfPresent([Double].self, forKey: .interestAmount)
        self.amountCurrency = try? container.decodeIfPresent([String].self, forKey: .amountCurrency)
        self.nextAmortizationDate = try? container.decodeIfPresent([String].self, forKey: .nextAmortizationDate)
        self.feeAmount = try? container.decodeIfPresent([Double].self, forKey: .feeAmount)
        self.amortizedAmount = try? container.decodeIfPresent([Double].self, forKey: .amortizedAmount)
        self.pendingAmount = try? container.decodeIfPresent([Double].self, forKey: .pendingAmount)

        guard let interestAmount = interestAmount,
              let amountCurrency = amountCurrency,
              let nextAmortizationDate = nextAmortizationDate,
              let feeAmount = feeAmount,
              let amortizedAmount = amortizedAmount,
              let pendingAmount = pendingAmount,
              !interestAmount.isEmpty,
              interestAmount.count == amountCurrency.count,
              amountCurrency.count == nextAmortizationDate.count,
              nextAmortizationDate.count == feeAmount.count,
              feeAmount.count == amortizedAmount.count,
              amortizedAmount.count == pendingAmount.count else {
            self.amortizations = nil
            return
        }

        self.amortizations = [AmortizationDTO]()
        for index in (0 ..< pendingAmount.count) {
            let date = nextAmortizationDate[index].trim()
            let currency = amountCurrency[index]
            var newAmort = AmortizationDTO()
            newAmort.nextAmortizationDate = DateFormats.safeDate(date)
            newAmort.interestAmount = AmountDTO(value: DTOParser.safeDecimal(interestAmount[index].description) ?? Decimal.nan,
                                                currency: CurrencyDTO.create(currency))
            newAmort.totalFeeAmount = AmountDTO(value: DTOParser.safeDecimal(feeAmount[index].description) ?? Decimal.nan,
                                                currency: CurrencyDTO.create(currency))
            newAmort.amortizedAmount = AmountDTO(value: DTOParser.safeDecimal(amortizedAmount[index].description) ?? Decimal.nan,
                                                currency: CurrencyDTO.create(currency))
            newAmort.pendingAmount = AmountDTO(value: DTOParser.safeDecimal(pendingAmount[index].description) ?? Decimal.nan,
                                                currency: CurrencyDTO.create(currency))
            self.amortizations?.append(newAmort)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(interestAmount, forKey: .interestAmount)
        try container.encode(amountCurrency, forKey: .amountCurrency)
        try container.encode(nextAmortizationDate, forKey: .nextAmortizationDate)
        try container.encode(feeAmount, forKey: .feeAmount)
        try container.encode(amortizedAmount, forKey: .amortizedAmount)
        try container.encode(pendingAmount, forKey: .pendingAmount)
        try container.encode(amortizations, forKey: .amortizations)
    }
}
