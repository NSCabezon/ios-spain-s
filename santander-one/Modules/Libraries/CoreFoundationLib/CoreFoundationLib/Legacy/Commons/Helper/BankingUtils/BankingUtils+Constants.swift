//
//  BankingUtils+Constants.swift
//  Commons
//
//  Created by Boris Chirino Fernandez on 9/6/21.
//

// MARK: - Constants
extension BankingUtils {
    public static var maxIbanLength = 34

    static var lettersToDigitMap: [String: String] {
        [
            "A": "10", "B": "11", "C": "12", "D": "13",
            "E": "14", "F": "15", "G": "16", "H": "17",
            "I": "18", "J": "19", "K": "20", "L": "21",
            "M": "22", "N": "23", "O": "24", "P": "25",
            "Q": "26", "R": "27", "S": "28", "T": "29",
            "U": "30", "V": "31", "W": "32", "X": "33",
            "Y": "34",
            "Z": "35"
        ]
    }
    
    static var ibanLengthByCountry: [String: Int] {
        [
            "AD": 24, "AE": 23, "AT": 20, "AZ": 28, "BA": 20, "BE": 16, "BG": 22, "BH": 22, "BR": 29,
            "CH": 21, "CR": 21, "CY": 28, "CZ": 24, "DE": 22, "DK": 18, "DO": 28, "EE": 20, "ES": 24,
            "FI": 18, "FO": 18, "FR": 27, "GB": 22, "GI": 23, "GL": 18, "GR": 27, "GT": 28, "HR": 21,
            "HU": 28, "IE": 22, "IL": 23, "IS": 26, "IT": 27, "JO": 30, "KW": 30, "KZ": 20, "LB": 28,
            "LI": 21, "LT": 20, "LU": 20, "LV": 21, "MC": 27, "MD": 24, "ME": 22, "MK": 19, "MR": 27,
            "MT": 31, "NL": 18, "NO": 15, "PK": 24, "PL": 28, "PS": 29, "PT": 25, "QA": 29, "RO": 24,
            "RS": 22, "SA": 24, "SE": 24, "SI": 19, "SK": 24, "SM": 27, "TR": 26, "AL": 28, "GE": 22,
            "SC": 31, "SV": 28, "TL": 23, "UA": 29, "XK": 20, "ST": 25, "VG": 24, "EG": 29, "VA": 22
        ]
    }
    
    static var keyboardTypeByCountry: [String: UIKeyboardType] {
        [
            "AD": .numberPad, "AE": .numberPad, "AT": .numberPad, "AZ": .default,
            "BA": .numberPad, "BE": .numberPad, "BG": .default, "BH": .default, "BR": .default,
            "CH": .numberPad, "CR": .numberPad, "CY": .numberPad, "CZ": .numberPad, "DE": .numberPad,
            "DK": .numberPad, "DO": .default, "EE": .numberPad, "ES": .numberPad, "FI": .numberPad,
            "FO": .numberPad, "FR": .default, "GB": .default, "GI": .default, "GL": .numberPad,
            "GR": .numberPad, "GT": .default, "HR": .numberPad, "HU": .numberPad, "IE": .default,
            "IL": .numberPad, "IS": .numberPad, "IT": .default, "JO": .default, "KW": .default,
            "KZ": .default, "LB": .numberPad, "LI": .default, "LT": .numberPad, "LU": .numberPad,
            "LV": .default, "MC": .numberPad, "MD": .default, "ME": .numberPad, "MK": .numberPad,
            "MR": .numberPad, "MT": .default, "NL": .default, "NO": .numberPad, "PK": .default,
            "PL": .numberPad, "PT": .numberPad, "QA": .default, "RO": .default, "RS": .numberPad,
            "SA": .numberPad, "SE": .numberPad, "SI": .numberPad, "SK": .numberPad, "SM": .default,
            "TR": .numberPad, "AL": .numberPad, "GE": .default, "SV": .default, "TL": .numberPad,
            "UA": .numberPad, "XK": .numberPad, "PS": .default, "VG": .default, "EG": .numberPad,
            "VA": .numberPad
        ]
    }
    
    static var flagImageKeyByCountry: [String: String] {
        [
            "ES": "oneIcnFlagSpain"
        ]
    }
    
    static var allowedCharacterSetByCountry: [String: CharacterSet] {
        [
            "ES": .decimalDigits, "PT": .decimalDigits
        ]
    }
    
    static var checkDigitByCountry: [String: String] {
        [
            "PT": "50"
        ]
    }
}
