import CoreFoundationLib
import CoreDomain

public struct CardMapItem {
    public let date: Date?
    public let name: String?
    public let alias: String?
    let amount: AmountEntity?
    public let address: String?
    public let postalCode: String?
    public let location: String?
    public let latitude: Double
    public let longitude: Double
    public let amountValue: Decimal?
    public let totalValues: Decimal
    var dateDecorated: NSAttributedString? {
        guard let date = dateToString(date: self.date, outputFormat: TimeFormat.dd_MMM_yyyy) else {
            return nil
        }
        guard let time = dateToString(date: self.date, outputFormat: TimeFormat.HHmm) else {
            return nil
        }
        let font = UIFont.santander(family: .text, type: .regular, size: 14)
        let fontMin = UIFont.santander(family: .text, type: .regular, size: 11)
        return TextStylizer.Builder(fullText: "\(date) · \(time)")
            .addPartStyle(part: TextStylizer.Builder.TextStyle(word: date).setStyle(font))
            .addPartStyle(part: TextStylizer.Builder.TextStyle(word: "· \(time)").setStyle(fontMin))
            .build()
    }
    var amountDecorated: String? {
        return amount?.getStringValue()
    }
    var amountSmartDecorated: NSAttributedString? {
        guard let amount = self.amount else {
            return nil
        }
        let font: UIFont = UIFont.santander(family: .text, type: .bold, size: 25)
        let amountDecorator = MoneyDecorator(amount, font: font, decimalFontSize: 19)
        return amountDecorator.getFormatedAbsWith1M()
    }
    var addressDecorated: String? {
        var textDecorated = self.address
        if var text = textDecorated, let postalCode = postalCode {
            text += "\n"
            text += postalCode
            textDecorated = text
        } else {
            textDecorated = self.postalCode
        }
        if var text = textDecorated, let location = location {
            text += "\n"
            text += location
            textDecorated = text
        } else {
            textDecorated = self.location
        }
        return textDecorated
    }
    
    public init(date: Date?,
                name: String?,
                alias: String?,
                amount: AmountEntity?,
                address: String?,
                postalCode: String?,
                location: String?,
                latitude: Double,
                longitude: Double,
                amountValue: Decimal?,
                totalValues: Decimal) {
        self.date = date
        self.name = name
        self.alias = alias
        self.amount = amount
        self.address = address
        self.postalCode = postalCode
        self.location = location
        self.latitude = latitude
        self.longitude = longitude
        self.amountValue = amountValue
        self.totalValues = totalValues
    }
    
    public init(_ representable: CardMapItemRepresentable) {
        self.date = representable.date
        self.name = representable.name
        self.alias = representable.alias
        if let amountRepresentable = representable.amountRepresentable {
            self.amount = AmountEntity(amountRepresentable)
        } else {
            self.amount = nil
        }
        self.address = representable.address
        self.postalCode = representable.postalCode
        self.location = representable.location
        self.latitude = representable.latitude
        self.longitude = representable.longitude
        self.amountValue = representable.amountValue
        self.totalValues = representable.totalValues
    }
    
    func isEqual(other: CardMapItem) -> Bool {
        return self.date == other.date
            && self.name == other.name
            && self.alias == other.alias
            && self.amount?.getStringValue() == other.amount?.getStringValue()
            && self.address == other.address
            && self.postalCode == other.postalCode
            && self.location == other.location
            && self.latitude == other.latitude
            && self.longitude == other.longitude
            && self.amountValue == other.amountValue
    }
}

extension CardMapItem: CardMapItemRepresentable {
    public var amountRepresentable: AmountRepresentable? {
        return amount
    }
}
