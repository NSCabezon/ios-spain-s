import SANLegacyLibrary
import CoreFoundationLib

class IBAN: GenericProduct {
    
    static func create(_ from: IBANDTO) -> IBAN {
        return IBAN(dto: from)
    }
    
    static func createEmpty() -> IBAN {
        return IBAN.create(IBANDTO())
    }
    
    static func create(fromText text: String) -> IBAN {
        return IBAN(dto: IBANDTO(ibanString: text))
    }
    
    static func create(fromCountryCode countryCode: String, checkDigits: String, codBban: String) -> IBAN {
        return IBAN(dto: IBANDTO(countryCode: countryCode, checkDigits: checkDigits, codBban: codBban))
    }
    
    private(set) var ibanDTO: IBANDTO
    
    internal init(dto: IBANDTO) {
        ibanDTO = dto
        super.init()
    }
    
    var entity: IBANEntity {
        return IBANEntity(ibanDTO)
    }
    
    var ibanString: String {
        return ibanDTO.countryCode + ibanDTO.checkDigits + ibanDTO.codBban
    }
    
    var ibanElec: String {
        return ibanString.replace(" ", "")
    }
    
    var ibanPapel: String {
        let ibantrim = ibanString.replacingOccurrences(of: " ", with: "")
        let numberOfGroups: Int = ibantrim.count / 4
        
        var printedIban = String(ibantrim.prefix(4))
        
        for i in 1..<numberOfGroups {
            let firstIndex = ibantrim.index(ibantrim.startIndex, offsetBy: 4*i)
            let secondIndex = ibantrim.index(ibantrim.startIndex, offsetBy: 4*(i+1) - 1)
            printedIban += " \(ibantrim[firstIndex...secondIndex])"
        }
        
        if ibantrim.count > 4*numberOfGroups {
            printedIban += " \(ibantrim.suffix(ibantrim.count - 4*numberOfGroups))"
        }
        
        return printedIban
    }
    
    var ccc: String {
        let ibanTrim = ibanString.replace(" ", "").substring(5)
        guard let entity = ibanTrim?.substring(0, 4),
            let office = ibanTrim?.substring(4, 8),
            let cc = ibanTrim?.substring(8, 10),
            let accountNumber = ibanTrim?.substring(10) else {
                return ""
        }
        
        return "\(entity) \(office) \(cc) \(accountNumber)"
    }
    
    /// Returns the iban formatted according to the country
    /// Spain: ESXX XXXX XXXX XXXX
    /// Other Sepa countries: FRXX XXXXXXXXXXXX
    var formatted: String {
        if countryCode.uppercased() != "ES" {
            return ibanDTO.countryCode + ibanDTO.checkDigits + " " + ibanDTO.codBban
        }
        
        return ibanPapel
    }
    
    /**
     Needs dependencies.
    */
    override func getAliasAndInfo(withCustomAlias alias: String?) -> String {
        return transformToAliasAndInfo(alias: alias ?? getAliasCamelCase()) + " | " + ibanShort()
    }
    
    @available(*, deprecated, message: "Use ibanShort(showCountryCode:, numberOfAsterisks:) instead.")
    var ibanShort: String {
        let ibantrim = ibanString.replace(" ", "")
        return "***" + (ibantrim.substring(ibantrim.count - 4) ?? "*")
    }
    
    /// Returns the iban formatted with asterisks.
    ///
    /// - Parameters:
    ///   - showCountryCode: flag to show the country code at the start of the iban.
    ///   - asterisksCount: the number of asterisks between the country code and the last digits. If lower than 0, transform the non-country code nor last digits characters to asterisks.
    ///   - lastDigitsCount: the iban last digits count. If lastDigitsCount is bigger than the complete iban character count without country code, then the function returns the complete iban.
    /// - Returns: the iban formatted with asterisks.
    func ibanShort(showCountryCode: Bool = false, asterisksCount: Int = 3, lastDigitsCount: Int = 4) -> String {
        guard lastDigitsCount < ibanString.count - 2 else {
            let countryCode: String = showCountryCode ? self.countryCode : ""
            return countryCode + ibanDTO.checkDigits + ibanDTO.codBban
        }
        let countryCode: String = showCountryCode ? self.countryCode : ""
        let lastDigits: String = String(ibanString.replacingOccurrences(of: " ", with: "").suffix(lastDigitsCount >= 0 ? lastDigitsCount: 0))
        
        var asterisksCount = asterisksCount
        if asterisksCount < 0 {
            asterisksCount = ibanString.count - self.countryCode.count - lastDigitsCount
        }
        
        let asterisks: String = String(repeating: "*", count: asterisksCount)
        return countryCode + asterisks + lastDigits
    }
    
    func getAsterisk() -> String {
        let text: String = ibanDTO.checkDigits + ibanDTO.codBban
        let totalLenght: Int = text.count
        let lenght: Int = totalLenght > 4 ? totalLenght - 4: totalLenght
        let end: String = String(text.suffix(totalLenght - lenght))
        let asterisks: String = String(repeating: "*", count: lenght)
        return countryCode + asterisks + end
    }
    
    var countryCode: String {
        return ibanDTO.countryCode
    }
    
    var ibanShortWithCountryCode: String {
        return ibanShort(showCountryCode: true)
    }
    
    func setCountryCode(countryCode: String) {
        ibanDTO.countryCode = countryCode
    }
    
}

extension IBAN: Equatable {}

extension IBAN: CustomStringConvertible {
    
    /// Returns the global IBAN representation (adding space each 4 characters)
    var description: String {
        return ibanString.replace(" ", "").inserting(separator: " ", every: 4)
    }
}

extension IBAN: OperativeParameter {}

func == (lhs: IBAN, rhs: IBAN) -> Bool {
    return lhs.ibanDTO.codBban30 == rhs.ibanDTO.codBban30
}
