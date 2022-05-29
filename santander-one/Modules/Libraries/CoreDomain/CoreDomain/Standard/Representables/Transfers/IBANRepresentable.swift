//
//  IBANRepresentable.swift
//  CoreFoundationLib
//
//  Created by David Gálvez Alonso on 8/9/21.
//

public protocol IBANRepresentable {
    var countryCode: String { get }
    var checkDigits: String { get }
    var codBban: String { get }
    var iban: String { get }
    var ibanElec: String { get }
    var ibanString: String { get }
    var ibanPapel: String { get }
    var codBban30: String { get }
    var formatted: String { get }
    func ibanShort(showCountryCode: Bool, asterisksCount: Int, lastDigitsCount: Int) -> String
    func getEntityCode(offset: Int) -> String?
}

public extension IBANRepresentable {
    func equalsTo(other: IBANRepresentable) -> Bool {
        return self.countryCode == other.countryCode &&
        self.checkDigits == other.checkDigits &&
        self.codBban == other.codBban &&
        self.iban == other.iban
    }
    
    var ibanElec: String {
        return iban.replacingOccurrences(of: " ", with: "")
    }
    
    var ibanString: String {
        return self.countryCode + self.checkDigits + self.codBban
    }
    
    var ibanPapel: String {
        let ibanTrimmed = self.ibanString.replacingOccurrences(of: " ", with: "")
        let numberOfGroups: Int = ibanTrimmed.count / 4
        var printedIban = String(ibanTrimmed.prefix(4))
        guard numberOfGroups > 0 else { return "" }
        for iterator in 1 ..< numberOfGroups {
            let firstIndex = ibanTrimmed.index(ibanTrimmed.startIndex, offsetBy: 4 * iterator)
            let secondIndex = ibanTrimmed.index(ibanTrimmed.startIndex, offsetBy: 4 * (iterator + 1) - 1)
            printedIban += " \(ibanTrimmed[firstIndex...secondIndex])"
        }
        if ibanTrimmed.count > 4 * numberOfGroups {
            printedIban += " \(ibanTrimmed.suffix(ibanTrimmed.count - 4 * numberOfGroups))"
        }
        return printedIban
    }
    
    var formatted: String {
        if !["ES", "PT"].contains(countryCode.uppercased()) {
            return countryCode + checkDigits + " " + codBban
        }
        return ibanPapel
    }
    
    var codBban30: String {
        var temp = ""
        for _ in (0 ..< 30 - codBban.count) {
            temp = temp + " "
        }
        return codBban + temp
    }
    
    func ibanShort(showCountryCode: Bool = false, asterisksCount: Int = 3, lastDigitsCount: Int = 4) -> String {
        let countryCode = showCountryCode ? self.countryCode : ""
        guard lastDigitsCount < self.ibanString.count - 2 else {
            return countryCode + self.checkDigits + self.codBban
        }
        let lastDigits = getLastDigits(lastDigitsCount)
        let asterisks = String(
            repeating: "*",
            count: getAsteriskCount(asterisksCount, lastDigitsCount)
        )
        return countryCode + asterisks + lastDigits
    }
    
    func getEntityCode(offset: Int = 3) -> String? {
        let codBbanTrim = self.codBban.replacingOccurrences(of: " ", with: "")
        let startIndex = codBbanTrim.startIndex
        guard let endIndex = codBbanTrim.index(
            codBbanTrim.startIndex,
            offsetBy: offset,
            limitedBy: codBbanTrim.endIndex
        ) else { return nil }
        return String(codBbanTrim[startIndex..<endIndex])
    }
}

private extension IBANRepresentable {
    func getLastDigits(_ lastDigitsCount: Int) -> String {
        return String(self.ibanString.replacingOccurrences(of: " ", with: "").suffix(max(lastDigitsCount, min(lastDigitsCount, 0))))
    }
    
    func getAsteriskCount(_ asterisksCount: Int, _ lastDigitsCount: Int) -> Int {
        guard asterisksCount < 0 else { return asterisksCount }
        return self.ibanString.count - self.countryCode.count - lastDigitsCount
    }
}
