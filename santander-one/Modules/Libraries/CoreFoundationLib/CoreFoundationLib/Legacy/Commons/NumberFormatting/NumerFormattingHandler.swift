import Foundation
import SANLegacyLibrary

public final class NumberFormattingHandler {
    public static let shared = NumberFormattingHandler()
    private var dependenciesResolver: DependenciesResolver?
    
    public lazy var millionsThreshold: Decimal = {
        guard let provider = self.dependenciesResolver?.resolve(forOptionalType: CurrencyFormatterProvider.self) else {
            return self.getCoreMillionsThreshold()
        }
        return provider.millionsThreshold
    }()
    
    public func setup(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        if let provider = dependenciesResolver.resolve(forOptionalType: CurrencyFormatterProvider.self) {
            CoreCurrencyDefault.default = provider.defaultCurrency
        }
    }
    
    public func formatterForRepresentation(_ amountRepresentation: AmountRepresentation) -> NumberFormatter {
        guard let provider = dependenciesResolver?.resolve(forOptionalType: AmountFormatterProvider.self),
              let formatter = provider.formatterForRepresentation(amountRepresentation) else {
            return self.getCoreFormatterProviderForRepresentation(amountRepresentation)
        }
        return formatter
    }
    
    public func getDefaultCurrency() -> CurrencyType {
        guard let provider = self.dependenciesResolver?.resolve(forOptionalType: CurrencyFormatterProvider.self) else {
            return self.getCoreDefaultCurrency()
        }
        return provider.defaultCurrency
    }
    
    public func getDefaultCurrencySymbol() -> String {
        guard let provider = self.dependenciesResolver?.resolve(forOptionalType: CurrencyFormatterProvider.self) else {
            return self.getCoreDefaultCurrencySymbol()
        }
        return provider.defaultCurrency.symbol ?? provider.defaultCurrency.name
    }
    
    public func getDefaultCurrencyTextFieldIcn() -> String {
        guard let provider = self.dependenciesResolver?.resolve(forOptionalType: CurrencyFormatterProvider.self) else {
            return self.getCurrencyTextFieldIcn(with: CoreCurrencyFormatterProvider().defaultCurrency)
        }
        return self.getCurrencyTextFieldIcn(with: provider.defaultCurrency)
    }
    
    public func getDefaultCurrencyText() -> String {
        guard let provider = self.dependenciesResolver?.resolve(forOptionalType: CurrencyFormatterProvider.self) else {
            return self.getCoreDefaultCurrencyText()
        }
        return provider.defaultCurrency.name
    }
    
    public func getDecimalSeparator() -> Character {
        guard let provider = dependenciesResolver?.resolve(forOptionalType: CurrencyFormatterProvider.self) else {
            return self.getCoreDecimalSeparator()
        }
        return provider.decimalSeparator
    }
    
    public func currencyRepresentationFor(_ amountRepresentation: AmountRepresentation, value: NSDecimalNumber?, currencySymbol: String) -> String {
        let formattedValue = formatterForRepresentation(amountRepresentation).string(from: value ?? 0) ?? ""
        return defaultCurrencyRepresentation(formattedValue: formattedValue, currencySymbol: currencySymbol, amountRepresentation: amountRepresentation)
    }
    
    public func defaultCurrencyRepresentation(formattedValue: String, currencySymbol: String, amountRepresentation: AmountRepresentation = .default) -> String {
        guard let provider = dependenciesResolver?.resolve(forOptionalType: CurrencyFormatterProvider.self) else {
            let symbolPosition = self.getCoreDefaultCurrencySymbolPosition(formattedValue: formattedValue, currencySymbol: currencySymbol, amountRepresentation: amountRepresentation)
            return self.getAssembledStringFor(currencySymbolPosition: symbolPosition, currencySymbol: currencySymbol, formattedValue: formattedValue)
        }
        let currencySymbolPosition = provider.assembleCurrencyString(for: formattedValue, with: currencySymbol, representation: amountRepresentation)
        return self.getAssembledStringFor(currencySymbolPosition: currencySymbolPosition, currencySymbol: currencySymbol, formattedValue: formattedValue)
    }
}

private extension NumberFormattingHandler {
    func getCoreFormatterProviderForRepresentation(_ amountRepresentation: AmountRepresentation) -> NumberFormatter {
        guard let formatter = CoreCurrencyFormatterProvider().formatterForRepresentation(amountRepresentation) else {
            fatalError("CoreCurrencyProvider must know case \(amountRepresentation)")
        }
        return formatter
    }
    
    func getCoreDefaultCurrency() -> CurrencyType {
        let coreProvider = CoreCurrencyFormatterProvider()
        return coreProvider.defaultCurrency
    }
    
    func getCoreDefaultCurrencySymbol() -> String {
        let coreProvider = CoreCurrencyFormatterProvider()
        return coreProvider.defaultCurrency.symbol ?? coreProvider.defaultCurrency.name
    }
    
    func getCoreMillionsThreshold() -> Decimal {
        let coreProvider = CoreCurrencyFormatterProvider()
        return coreProvider.millionsThreshold
    }
    
    func getCoreDefaultCurrencyText() -> String {
        let coreProvider = CoreCurrencyFormatterProvider()
        return coreProvider.defaultCurrency.name
    }
    
    func getCurrencyTextFieldIcn(with defaultCurrency: CurrencyType) -> String {
        switch defaultCurrency {
        case .eur:
            return "icnEuro"
        case .złoty:
            return "icnPLN"
        case .dollar:
            return ""
        case .pound:
            return ""
        case .swissFranc:
            return ""
        case .other:
            return ""
        }
    }
    
    func getCoreDecimalSeparator() -> Character {
        return CoreCurrencyFormatterProvider().decimalSeparator
    }
    
    func getCoreDefaultCurrencySymbolPosition(formattedValue: String, currencySymbol: String, amountRepresentation: AmountRepresentation) -> CurrencySymbolPosition {
        return CoreCurrencyFormatterProvider().assembleCurrencyString(for: formattedValue, with: currencySymbol, representation: amountRepresentation)
    }
    
    func getAssembledStringFor(currencySymbolPosition: CurrencySymbolPosition, currencySymbol: String, formattedValue: String) -> String {
        switch currencySymbolPosition {
        case .left:
            return "\(currencySymbol)\(formattedValue)"
        case .leftPadded:
            return "\(currencySymbol) \(formattedValue)"
        case .right:
            return "\(formattedValue)\(currencySymbol)"
        case .rightPadded:
            return "\(formattedValue) \(currencySymbol)"
        case .rightPaddedWithMillionShort(let short):
            return "\(formattedValue)\(short) \(currencySymbol)"
        case .custom(let formattedString):
            return formattedString
        }
    }
}

public enum AmountRepresentation {
    case withoutDecimals
    case with1M
    case decimal(decimals: Int = 2)
    case decimalTracker(decimals: Int = 2)
    case decimalServiceValue(decimals: Int = 2)
    case decimalSmart(decimals: Int = 2)
    case descriptionPFM(decimals: Int = 2)
    case description(decimals: Int = 2)
    case wholePart
    case tae(decimals: Int = 2)
    case sharesCount5Decimals
    case transactionFilters
    case withSeparator(decimals: Int)
    case amountTextField(maximumFractionDigits: Int, maximumIntegerDigits: Int)
    case decimalPadded(decimals: Int = 2)
    case `default`
}

public func formatterForRepresentation(_ amountRepresentation: AmountRepresentation) -> NumberFormatter {
    return NumberFormattingHandler.shared.formatterForRepresentation(amountRepresentation)
}

public func currencyRepresentationFor(_ amountRepresentation: AmountRepresentation, value: NSDecimalNumber?, currencySymbol: String) -> String {
    NumberFormattingHandler.shared.currencyRepresentationFor(amountRepresentation, value: value, currencySymbol: currencySymbol)
}

public func currencyDefaultSymbolRepresentation(formattedValue: String) -> String {
    let symbol = NumberFormattingHandler.shared.getDefaultCurrencySymbol()
    return NumberFormattingHandler.shared.defaultCurrencyRepresentation(formattedValue: formattedValue, currencySymbol: symbol)
}
