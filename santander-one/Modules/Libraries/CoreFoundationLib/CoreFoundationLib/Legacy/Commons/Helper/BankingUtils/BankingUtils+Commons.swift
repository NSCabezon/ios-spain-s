//
//  BankingUtils+Commons.swift
//  Commons
//
//  Created by Boris Chirino Fernandez on 9/6/21.
//

extension BankingUtils {
    func integerize(iban: NSString) -> Int? {
        var range = NSRange(location: 0, length: iban.length)
        for index in 0...range.length {
            if iban.character(at: index).description != "0" {
                break
            }
            range.location = index + 1
            range.length -= 1
        }
        return Int(iban.substring(with: range))
    }
    
    func putZerosLeft( str: String, length: Int) -> String {
        let count = str.count
        guard count < length else {
            return str
        }
        var zeros = ""
        for _ in 0..<count {
            zeros += "0"
        }
        zeros += str
        return zeros
    }
    
    func mod97(numericValue: String) -> Int? {
        var value = numericValue as NSString
        var result: NSString = ""
        var nString: NSString
        var range = NSRange(location: 0, length: 0)
        while value.length > 0 {
            let length = value.length
            if result.length > 0 {
                range.location = 0
                range.length = min(length, 7)
            } else {
                range.location = 0
                range.length = min(length, 9)
            }
            nString = result.appending(value.substring(with: range)) as NSString
            range.location = range.length
            range.length = length - range.length
            value = value.substring(with: range) as NSString
            if let nonIntegerToInt = integerize(iban: nString) {
                result = NSString(format: "%02d", (nonIntegerToInt % 97))
            }
        }
        return integerize(iban: result)
    }
}

// MARK: - String extension
public extension String {
    func passesMod97Check() -> Bool {
        guard self.count >= 4 else {
            return false
        }
        let uppercase = self.uppercased()
        let pattern = "^[0-9A-Z]*$"
        guard uppercase.range(of: pattern, options: .regularExpression) != nil else {
            return false
        }
        return (uppercase.mod97() == 1)
    }
}

private extension String {
    func mod97() -> Int {
        let symbols: [Character] = Array(self)
        let swapped = symbols.dropFirst(4) + symbols.prefix(4)
        let mod: Int = swapped.reduce(0) { (previousMod, char) in
            guard let value = Int(String(char), radix: 36) else { return 0 } // "0" => 0, "A" => 10, "Z" => 35
            let factor = value < 10 ? 10 : 100
            return (factor * previousMod + value) % 97
        }
        return mod
    }
}
