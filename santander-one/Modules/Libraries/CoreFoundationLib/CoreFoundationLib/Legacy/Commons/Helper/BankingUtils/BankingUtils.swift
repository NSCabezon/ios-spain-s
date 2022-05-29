//
//  BankingUtils.swift
//  Commons
//
//  Created by David Gálvez Alonso on 01/06/2020.
//

public protocol IBANTextInputProtocol {
    var keyboardType: UIKeyboardType { get }
    var bbaLenght: Int { get }
    var checkDigit: String? { get set }
    var validCharacterSet: CharacterSet { get }
}

public protocol BankingUtilsProtocol: AnyObject {
    func isValidIban(ibanString: String) -> Bool
    func calculateCheckDigit(originalIBAN: String) -> String
    @available(*, deprecated, message: " use calculateCheckDigit(bban: String) ")
    func calculateCheckDigit(bban: String, countryCode: String) -> String
    func calculateCheckDigit(bban: String) -> String
    func flagForCountryCode(_ ccode: String) -> String?
    func setCountryCode(_ countryCode: String, isAlphanumeric: Bool?, isSepaCountry: Bool?)
    var countryCode: String? { get }
    var textInputAttributes: IBANTextInputProtocol { get }
    var selectedCountryMatchAppCountry: Bool { get }
    var isSepaCountry: Bool? { get }
}

public extension BankingUtilsProtocol {
    func setCountryCode(_ countryCode: String, isAlphanumeric: Bool? = nil, isSepaCountry: Bool? = nil) {
        setCountryCode(countryCode, isAlphanumeric: isAlphanumeric, isSepaCountry: isSepaCountry)
    }
}

public final class BankingUtils {
    
    typealias CheckDigitValidationBlock = (_ bban: String) -> String?
    private var validatorBlocks: [String: CheckDigitValidationBlock] = [:]
    private var currentCountryCode: String?
    private var isSepa: Bool?
    private let dependenciesResolver: DependenciesResolver
    private var byCountryTextInputAttributes: IBANTextInputProtocol
    private var customTextInputAttributes: IBANTextInputProtocol? {
        dependenciesResolver.resolve(forOptionalType: IBANTextInputProtocol.self)
    }
    private var localAppConfiguration: LocalAppConfig {
        dependenciesResolver.resolve(for: LocalAppConfig.self)
    }
    private let minLenght = 0
    internal let mod97Constant = 98
    
    public init(dependencies: DependenciesResolver) {
        self.dependenciesResolver = dependencies
        self.byCountryTextInputAttributes = TextInputAttributes()
        self.setupCountryValidations()
    }
}

extension BankingUtils: BankingUtilsProtocol {
    public var selectedCountryMatchAppCountry: Bool {
        return localAppConfiguration.countryCode == self.currentCountryCode
    }
    
    public var isSepaCountry: Bool? {
        return self.isSepa
    }
    
    public var textInputAttributes: IBANTextInputProtocol {
        if selectedCountryMatchAppCountry, let customAttributes = self.customTextInputAttributes {
            return customAttributes
        }
        return byCountryTextInputAttributes
    }
    
    public var countryCode: String? {
        return self.currentCountryCode
    }
    
    public func setCountryCode(_ countryCode: String, isAlphanumeric: Bool? = nil, isSepaCountry: Bool? = nil) {
        self.currentCountryCode = countryCode
        self.isSepa = isSepaCountry
        self.byCountryTextInputAttributes = getTextInputAttributes(countryCode, isAlphanumeric: isAlphanumeric)
    }
    
    public func isValidIban(ibanString: String) -> Bool {
        let countryCode = ibanString.prefix(2).description
        let checkDigitCandidate = ibanString.substring(2, 4)?.description
        guard let proposedIBANLenght = ibanLenghtForCountryCode(countryCode),
              checkDigitCandidate != nil else { return false}
        // check 1 ( iban lenght must match international declared lenght )
        let ibanLenghtValid = ibanString.count == proposedIBANLenght
        // check 2 ( checksum )
        let checksum = calculateCheckDigit(originalIBAN: ibanString)
        let checkDigitValid = checksum == checkDigitCandidate
        return checkDigitValid && ibanLenghtValid
    }
    
    /// Each IBAN contains a check digit calculated individually by the bank for the account holder. This check digit makes it easy to recognize typing errors or numbers when entering and processing the IBAN. This method may be util to validate an IBAN, meaning that the resulting check digit may be compared with other
    /// - Parameter originalIBAN: International Bank Account Number IBAN in its whole format
    /// - Returns: The Check Digit string
    public func calculateCheckDigit(originalIBAN: String) -> String {
        let countryCode = originalIBAN.prefix(2).description
        // the bank code and account number are merged to form the so-called BBAN
        let bban = originalIBAN.substring(4, originalIBAN.count) ?? ""
        let result = applyCheckDigitAlgorithm(bban: bban, countryCode: countryCode)
        return result ?? ""
    }
    
    /// Each IBAN contains a check digit calculated individually by the bank for the account holder. This check digit makes it easy to recognize typing errors or numbers when entering and processing the IBAN
    /// - Parameters:
    ///   - bban: BBAN is short for Basic Bank Account Number. The BBAN is the last part of the IBAN when used for international funds transfers. In other words its the IBAN without Country and check digit
    ///   - country: An entity representing business logic country info
    /// - Returns: The Check Digit string
    public func calculateCheckDigit(bban: String, countryCode: String) -> String {
        let result = applyCheckDigitAlgorithm(bban: bban, countryCode: countryCode)
        return result ?? ""
    }
    
    public func calculateCheckDigit(bban: String) -> String {
        guard let countryCode = self.countryCode else { return "" }
        let result = applyCheckDigitAlgorithm(bban: bban, countryCode: countryCode)
        return result ?? ""
    }
    
    public func bbanLenghtForCountryCode(_ ccode: String) -> Int? {
        let lenght = BankingUtils.ibanLengthByCountry.first(where: {$0.key == ccode})?.value ?? 0
        let result = lenght - 4
        return  result <= minLenght ? nil : result
    }
    
    public func ibanLenghtForCountryCode(_ ccode: String) -> Int? {
        let lenght = BankingUtils.ibanLengthByCountry.first(where: {$0.key == ccode})?.value ?? 0
        let result = lenght
        return  result <= minLenght ? nil : result
    }
    
    public func flagForCountryCode(_ code: String) -> String? {
        return BankingUtils.flagImageKeyByCountry[code]
    }
}

private extension BankingUtils {
    func applyCheckDigitAlgorithm(bban: String, countryCode: String) -> String? {
        if let specificValidationBlock = validatorBlocks[countryCode] {
           return specificValidationBlock(bban)
        }
        // assemble a string with bban the country code and the check digit set to 00
        let changeOver = bban + countryCode + "00"
        // Now all letters must be replaced by numbers. For A = 10, B = 11 etc. up to Z = 35
        var replaceLetters = changeOver
        for (key, value) in BankingUtils.lettersToDigitMap {
            let newstr = replaceLetters.replacingOccurrences(of: key, with: value)
            replaceLetters = newstr
        }
        // the resulting number is divided by 97 (Modulo 97 method)
        guard let module97 = mod97(numericValue: replaceLetters) else {
            return nil
        }
        // and the integer remainder of 98 is subtracted.
        let result = mod97Constant - module97
        // if the resulting checkDigit has only one digit, add zero to the left
        let twoDigitsResult = putZerosLeft(str: String(describing: result), length: 2)
        return twoDigitsResult
    }

    func getTextInputAttributes(_ countryCode: String, isAlphanumeric: Bool? = nil) -> TextInputAttributes {
        let keyboardType: UIKeyboardType
        if let isAlphanumeric = isAlphanumeric {
            keyboardType = isAlphanumeric ? .default : .numberPad
        } else {
            keyboardType = BankingUtils.keyboardTypeByCountry[countryCode] ?? UIKeyboardType.default
        }
        return TextInputAttributes(
            autocapitalizationType: .allCharacters,
            keyboardType: keyboardType,
            bbaLenght: bbanLenghtForCountryCode(countryCode) ?? 0,
            checkDigit: BankingUtils.checkDigitByCountry[countryCode],
            validCharacterSet: BankingUtils.allowedCharacterSetByCountry[countryCode] ?? .iban)
    }
}

extension BankingUtils {
    func setupCountryValidations() {
        let esValidation: CheckDigitValidationBlock = { bban in
            return self.calculateESdcIbanFromBBAN(bban)
        }
        validatorBlocks["ES"] = esValidation
    }
}
