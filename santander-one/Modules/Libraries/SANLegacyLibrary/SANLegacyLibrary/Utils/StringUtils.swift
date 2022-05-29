import Foundation

extension String {
    
    func indexDistance(of character: Character) -> Int? {
        guard let index = firstIndex(of: character) else {
            return nil
        }
        return distance(from: startIndex, to: index)
    }
    
    func substring(with nsrange: NSRange) -> String? {
        guard let range = Range(nsrange, in: self) else {
            return nil
        }
        return String(self[range])
    }
    
    func substring(_ beginIndex: Int, _ endIndex: Int) -> String? {
        return substring(with: NSRange(location: beginIndex, length: endIndex - beginIndex))
    }
    
    func substring(_ beginIndex: Int) -> String? {
        return substring(with: NSRange(location: beginIndex, length: self.count - beginIndex))
    }
    
    
    func substring(to: PartialRangeUpTo<Int>) -> String {
        return String(self[..<index(startIndex, offsetBy: to.upperBound)])
    }
    
    
    func replace(_ target: String, _ replacement: String) -> String {
        return self.replacingOccurrences(of: target, with: replacement)
    }
    
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func splitByLength(_ length: Int) -> [String] {
        guard length > 0 else { return [self] }
        var result = [String]()
        var msg = self
        let numberOfIterations = Int(ceil( Double(msg.count) / Double(length) ))
        for _ in 0 ..< numberOfIterations where !msg.isEmpty {
            let splitIndex = min(msg.count, length)
            result.append(String(msg.prefix(splitIndex)))
            msg = String(msg.suffix(msg.count - splitIndex))
        }
        return result
    }
    
    func split(_ value: String) -> [String] {
        return self.components(separatedBy: value)
    }
    
    
    func toDate(dateFormat format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        return dateFormatter.date(from: self)
    }
    
    public var account34: String {
        return completeRightCharacter(size: 34, char: " ")
    }
    
    func completeRightCharacter(size: Int, char: String = "") -> String {
        var temp = ""
        for _ in (0..<size - self.count) {
            temp = temp + char
        }
        return self + temp
    }
    
    public var bicSwift11: String {
        return completeRightCharacter(size: 11, char: "X")
    }
    
    var hexStringToString: String {
        var chars = [Character]()
        var final = ""
        
        for c in self {
            chars.append(c)
        }
        
        let numbers = stride(from: 0, to: chars.count, by: 2).map {
            strtoul(String(chars[$0 ..< $0+2]), nil, 16)
        }
        
        for (_, num) in numbers.enumerated() {
            if let unicode = UnicodeScalar(Int(num)) {
                final.append(Character(unicode))
            }
        }
        
        return final
    }
}
