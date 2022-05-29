import SANLegacyLibrary

struct PaymentMethod {
    private(set) var dto: PaymentMethodDTO
    
    init(_ dto: PaymentMethodDTO) {
        self.dto = dto
    }
    
    func getSubtitleCell() -> (Int, Int) {
        switch paymentMethod {
        case .fixedFee?:
            return (Int(feeAmount?.value?.doubleValue ?? 0.0), 0)
        case .deferredPayment?:
            guard let minAmortAmount = minAmortAmount, let feeAmount = feeAmount else { return (0, 0) }
            let percentaje = Int(feeAmount.value?.doubleValue ?? 0.0)
            let amount = Int(minAmortAmount.value?.doubleValue ?? 0.0)
            return (percentaje, amount)
        default:
            return (0, 0)
        }
    }
    
    //! Get Amount Range
    func getRangeAmount() -> [Int] {
        guard let inc = incModeAmount?.value, inc > 0,
            let max = maxModeAmount?.value, max > 0,
            let min = minModeAmount?.value else { return [] }
        return getRange(minimum: min, maximum: max, increment: inc)
    }
    
    //! Get Percentage Range
    func getRangePercentage() -> [Int] {
        guard let inc = incModeAmount?.value, inc > 0,
            let max = maxModeAmount?.value, max > 0,
            let min = minModeAmount?.value else { return [] }
        return (getRange(minimum: min, maximum: max, increment: inc))
    }
    
    // Get the array from minimum to maximum by increment
    private func getRange(minimum: Decimal, maximum: Decimal, increment: Decimal) -> [Int] {
        var intArray = [Int]()
        for i in stride(from: Int(truncating: NSDecimalNumber(decimal: minimum)), through: Int(truncating: NSDecimalNumber(decimal: maximum)), by: Int(truncating: NSDecimalNumber(decimal: increment))) {
            intArray.append(i)
        }
        return intArray
    }
    
    func getAmountByIndex(index: Int) -> Int {
        return getRangeAmount()[index]
    }
    
    func getPercentageByIndex(index: Int) -> Int {
        let percentage = getRangePercentage()
        return percentage[index]
    }
    
    var idRangeFP: String? {
        return dto.idRangeFP
    }
    var liquidationType: String? {
        return dto.liquidationType
    }
    var paymentMethod: PaymentMethodType? {
        return dto.paymentMethod
    }
    var paymentMethodStatus: PaymentMethodStatus? {
        if let status = dto.paymentMethod {
            switch status {
            case .monthlyPayment:
                return .monthlyPayment
            case .fixedFee:
                return .fixedFee
            case .minimalPayment:
                return .minimalPayment
            case .deferredPayment:
                return .deferredPayment
            case .immediatePayment:
                return .immediatePayment
            }
        }
        return nil
    }
    
    var paymentMethodDesc: String? {
        return dto.paymentMethodDesc
    }
    public var thresholdDesc: Decimal? {
        return dto.thresholdDesc
    }
    var feeAmount: Amount? {
        return Amount.createFromDTO(dto.feeAmount)
    }
    var incModeAmount: Amount? {
        return Amount.createFromDTO(dto.incModeAmount)
    }
    var maxModeAmount: Amount? {
        return Amount.createFromDTO(dto.maxModeAmount)
    }
    var minAmortAmount: Amount? {
        return Amount.createFromDTO(dto.minAmortAmount)
    }
    var minModeAmount: Amount? {
        return Amount.createFromDTO(dto.minModeAmount)
    }
    
    private func isNumeric(string: String) -> Bool {
        if string.rangeOfCharacter(from: .decimalDigits) != nil {
            return true
        }
        return false
    }
}
