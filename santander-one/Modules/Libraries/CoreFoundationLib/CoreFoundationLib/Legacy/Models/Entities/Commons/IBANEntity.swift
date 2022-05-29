//
//  IBANEntity.swift
//  Models
//
//  Created by alvola on 14/10/2019.
//

import SANLegacyLibrary
import CoreDomain

public final class IBANEntity: DTOInstantiable {
    public var dto: IBANDTO
    
    public init(_ dto: IBANDTO) {
        self.dto = dto
    }
    
    public static func create(fromText text: String) -> IBANEntity {
        return IBANEntity(IBANDTO(ibanString: text))
    }
    
    public var ibanString: String {
        return dto.countryCode + dto.checkDigits + dto.codBban
    }
    
    public var ibanElec: String {
        return ibanString.replace(" ", "")
    }
    
    public var ibanPapel: String {
        let ibantrim = ibanString.replacingOccurrences(of: " ", with: "")
        let numberOfGroups: Int = ibantrim.count / 4

        var printedIban = String(ibantrim.prefix(4))

        for iterator in 1..<numberOfGroups {
            let firstIndex = ibantrim.index(ibantrim.startIndex, offsetBy: 4*iterator)
            let secondIndex = ibantrim.index(ibantrim.startIndex, offsetBy: 4*(iterator+1) - 1)
            printedIban += " \(ibantrim[firstIndex...secondIndex])"
        }

        if ibantrim.count > 4*numberOfGroups {
            printedIban += " \(ibantrim.suffix(ibantrim.count - 4*numberOfGroups))"
        }
        return printedIban
    }

    public var ccc: String {
        let ibanTrim = ibanString.replace(" ", "").substring(5)
        guard let entity = ibanTrim?.substring(0, 4),
            let office = ibanTrim?.substring(4, 8),
            let ccc = ibanTrim?.substring(8, 10),
            let accountNumber = ibanTrim?.substring(10) else {
                return ""
        }
        return "\(entity) \(office) \(ccc) \(accountNumber)"
    }

    /// Returns the iban formatted according to the country
    /// Spain: ESXX XXXX XXXX XXXX
    /// Other Sepa countries: FRXX XXXXXXXXXXXX
    var formatted: String {
        if !["ES", "PT"].contains(dto.countryCode.uppercased()) {
            return dto.countryCode + dto.checkDigits + " " + dto.codBban
        }
        return ibanPapel
    }

    /**
     Needs dependencies.
     */
//    func getAliasAndInfo(withCustomAlias alias: String?) -> String {
//        return dto.transformToAliasAndInfo(alias: alias ?? dto.getAliasCamelCase()) + " | " + dto.ibanShort()
//    }

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
    public func ibanShort(showCountryCode: Bool = false, asterisksCount: Int = 3, lastDigitsCount: Int = 4) -> String {
        guard lastDigitsCount < ibanString.count - 2 else {
            let countryCode: String = showCountryCode ? self.countryCode : ""
            return countryCode + dto.checkDigits + dto.codBban
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

    public func getAsterisk() -> String {
        let text: String = dto.checkDigits + dto.codBban
        let totalLenght: Int = text.count
        let lenght: Int = totalLenght > 4 ? totalLenght - 4: totalLenght
        let end: String = String(text.suffix(totalLenght - lenght))
        let asterisks: String = String(repeating: "*", count: lenght)
        return countryCode + asterisks + end
    }

    public var countryCode: String {
        return dto.countryCode
    }

    var ibanShortWithCountryCode: String {
        return ibanShort(showCountryCode: true)
    }

    func setCountryCode(countryCode: String) {
        dto.countryCode = countryCode
    }
    
    public func getEntityCode() -> String? {
        let codBbanTrim = dto.codBban.replace(" ", "")
        guard let entity = codBbanTrim.substring(0, 4) else {
            return nil
        }
        return entity
    }
}

extension IBANEntity: Equatable {}

public func == (lhs: IBANEntity, rhs: IBANEntity) -> Bool {
    return lhs.dto.codBban30 == rhs.dto.codBban30
}

public class IBANRepresented: IBANRepresentable {
    public var countryCode: String
    public var checkDigits: String
    public var codBban: String
    public var iban: String
    
    public init(ibanString: String) {
        self.iban = ibanString
        let ibantrim = ibanString.replace(" ", "")
        if ibantrim.count > 4 {
            self.countryCode = ibantrim.substring(0, 2) ?? ""
            self.checkDigits = ibantrim.substring(2, 4) ?? ""
            self.codBban = ibantrim.substring(4) ?? ""
        } else {
            self.countryCode = ""
            self.checkDigits = ""
            self.codBban = ""
        }
    }
}
