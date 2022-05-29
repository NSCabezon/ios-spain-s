
private extension BankingUtils {
    func isValidES(bankCode: String, branch: String, checkDigits: String, accountNumber: String) -> Bool {
        let firstCalculatedDC = String(firstDC(bankCode: bankCode, branch: branch))
        let secondCalculatedDC = String(secondDC(accountNumber: accountNumber))
        return checkDigits == (firstCalculatedDC + secondCalculatedDC)
    }
    
    func firstDC(bankCode: String, branch: String) -> Int {
        let bankCodeAndBranch = bankCode + branch
        let multipliers = [4, 8, 5, 10, 9, 7, 3, 6]
        let result = multipliers
            .enumerated()
            .map({ $0.element * (Int(bankCodeAndBranch.substring(with: NSRange(location: $0.offset, length: 1)) ?? "0") ?? 0) })
            .reduce(0, +)
        let finalResult = 11 - (result % 11)
        return finalResult == 10 ? 1 : (finalResult == 11 ? 0 : finalResult)
    }
    
    func secondDC(accountNumber: String) -> Int {
        let multipliers = [1, 2, 4, 8, 5, 10, 9, 7, 3, 6]
        let result = multipliers
            .enumerated()
            .map({ $0.element * (Int(accountNumber.substring(with: NSRange(location: $0.offset, length: 1)) ?? "0") ?? 0) })
            .reduce(0, +)
        let finalResult = 11 - (result % 11)
        return finalResult == 10 ? 1 : (finalResult == 11 ? 0 : finalResult)
    }
    
    func giveMeIbanWeight(str: String, letter: Int) -> String {
        guard str.count > letter else {
            return ""
        }
        let weight: String
        let letraUppercased = String(Array(str.uppercased())[letter])
        switch letraUppercased {
        case "1", "2", "3", "4", "5", "6", "7", "8", "9", "0":
            weight = String(letraUppercased)
        default:
            let weightDictionary = ["A": "10", "B": "11", "C": "12", "D": "13", "E": "14", "F": "15", "G": "16", "H": "17", "I": "18", "J": "19", "K": "20", "L": "21", "M": "22", "N": "23", "O": "24", "P": "25", "Q": "26", "R": "27", "S": "28", "T": "29", "U": "30", "V": "31", "W": "32", "X": "33", "Y": "34", "Z": "35"]
            
            weight = weightDictionary[letraUppercased] ?? ""
        }
        return weight
    }
    
    func isValidESBBAN(_ bban: String) -> Bool {
        let bankCode = bban.substring(0, 4) ?? ""
        let branch = bban.substring(4, 8) ?? ""
        let checkDigits = bban.substring(8, 10) ?? ""
        let accountNumber = bban.substring(10, 20) ?? ""
        let firstCalculatedDC = String(firstDC(bankCode: bankCode, branch: branch))
        let secondCalculatedDC = String(secondDC(accountNumber: accountNumber))
        return checkDigits == (firstCalculatedDC + secondCalculatedDC)
    }
}

extension BankingUtils {
    func calculateESdcIbanFromBBAN(_ bban: String) -> String? {
        let preIban = bban + giveMeIbanWeight(str: "ES", letter: 0) +
            giveMeIbanWeight(str: "ES", letter: 1) + "00"
        guard let ccc = mod97(numericValue: preIban), isValidESBBAN(bban) else { return nil }
        let dcIb = mod97Constant - ccc
        let dcIban = putZerosLeft(str: "\(dcIb)", length: 2)
        return dcIban
    }
}
