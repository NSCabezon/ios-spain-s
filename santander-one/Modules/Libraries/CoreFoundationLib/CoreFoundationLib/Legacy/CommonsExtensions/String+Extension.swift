//
//  String+Extension.swift
//  CoreFoundationLib
//
//  Created by Jose Ignacio de Juan Díaz on 13/12/21.
//

import Foundation
import CommonCrypto

// MARK: - Public
public extension String {
    var nameInitials: String {
        return split(" ")
            .prefix(2)
            .map({ $0.prefix(1) })
            .joined()
            .uppercased()
    }
    
    var camelCasedString: String {
        return self.capitalizedIgnoringNumbers()
    }
    var isBackSpace: Bool {
        let backSpace = (strcmp(self.cString(using: .utf8), "\\b") == -92)
        return backSpace
    }
    
    var isBlank: Bool {
        return self.allSatisfy { $0.isWhitespace }
    }
    
    var containsEmoji: Bool { contains { $0.isEmoji } }
    
    var htmlToAttributedString: NSAttributedString {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        return (try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)) ?? NSAttributedString()
    }
    var stringToDecimal: Decimal? {
        return Decimal(string: self.replace(" ", "").replace(".", "").replace(",", "."))
    }
    
    var bicSwift11: String {
        return completeRightCharacter(size: 11, char: "X")
    }
    
    var account34: String {
        return completeRightCharacter(size: 34, char: " ")
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
    
    var urlCombinedEncoded: String? {
        let urlCombinedCharacterSet = CharacterSet(charactersIn: " \n\r\"#%/:<>?@[\\]^`'‘{|}").inverted
        return addingPercentEncoding(withAllowedCharacters: urlCombinedCharacterSet)
    }
    
    var words: [String] {
        var words: [String] = []
        enumerateSubstrings(in: startIndex..<endIndex, options: .byWords) { word, _, _, _ in
            guard let word = word else { return }
            words.append(word)
        }
        return words
    }
    
    func deleteAccent() -> String {
        return self.folding(options: .diacriticInsensitive, locale: .current)
    }
    
    func toBool() -> Bool? {
        switch self {
        case "True", "true", "yes", "1":
            return true
        case "False", "false", "no", "0":
            return false
        default:
            return nil
        }
    }
    
    func distanceFromStart(to character: Character) -> Int? {
        guard let index = firstIndex(of: character) else {
            return nil
        }
        return distance(from: startIndex, to: index)
    }
    
    func replaceFirst(_ target: String, _ replacement: String) -> String {
        return self.replacingOccurrences(of: target, with: replacement, range: self.range(of: target))
    }
    
    func split(byLength length: Int) -> [String] {
        return splitByLength(length)
    }
    
    func capitalizedIgnoringNumbers() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: " ")
            .map { $0.first?.isNumber ?? false ? $0.lowercased() : String($0).lowercased().capitalizingFirstLetter() }
            .joined(separator: " ")
    }
    
    func capitalizedBySentence() -> String {
        return self.trim()
            .split(separator: ".")
            .map { String($0).trim().capitalizingFirstLetter() }
            .joined(separator: ". ")
    }
    
    mutating func insert(separator: String, every: Int) {
        indices.reversed().forEach {
            if $0 != startIndex && distance(from: startIndex, to: $0) % every == 0 {
                insert(contentsOf: separator, at: $0)
            }
        }
    }
    
    func inserting(separator: String, every: Int) -> String {
        var string = self
        string.insert(separator: separator, every: every)
        return string
    }
    
    func insertIntegerSeparator(separator: String) -> String {
        let integer = Int(self)
        
        let formatter = NumberFormatter()
        formatter.groupingSeparator = separator
        formatter.numberStyle = .decimal
        
        return formatter.string(for: integer) ?? ""
    }
    
    func filterValidCharacters(characterSet: CharacterSet) -> String {
        let unicodeFiltered = unicodeScalars.filter { (character) -> Bool in
            return characterSet.contains(character)
        }
        let textFiltered = String(unicodeFiltered)
        return textFiltered
    }
    
    func noDoubleWhitespaces() -> String {
        return self.split {$0 == " "}.joined(separator: " ")
    }
    
    func spainTlfFormatted () -> String {
        let pattern = "(0*34|\\+0*34)?((\\s*[0-9]){9})?\\s*"
        do {
            let regEx = try NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(location: 0, length: count)
            let matches = regEx.matches(in: self, options: [], range: range)
            if let match = matches.first, match.numberOfRanges > 2 {
                let totalRange = match.range(at: 0)
                let matchRange = match.range(at: 2)
                if substring(with: totalRange) == self, let result = substring(with: matchRange)?.notWhitespaces() {
                    return "+34 \(result)"
                }
            }
        } catch {}
        return self
    }
    
    func tlfWithoutPrefix () -> String {
        let pattern = "(0*34|\\+0*34)?((\\s*[0-9]){9})?\\s*"
        do {
            let regEx = try NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(location: 0, length: count)
            let matches = regEx.matches(in: self, options: [], range: range)
            if let match = matches.first, match.numberOfRanges > 2 {
                let totalRange = match.range(at: 0)
                let matchRange = match.range(at: 2)
                if substring(with: totalRange) == self, let result = substring(with: matchRange)?.notWhitespaces() {
                    return result
                }
            }
        } catch {}
        return self
    }
    
    func tlfwithValidaRecargaMovilOTP () -> String {
        var phone = self.tlfWithoutPrefix()
        if phone.count > 3 {
            phone.insert("-", at: phone.index(phone.startIndex, offsetBy: 2))
        }
        return phone
    }
    
    func tlfFormatted () -> String {
        let pattern = "(0*34|\\+0*34)?((\\s*[0-9]){9})?\\s*"
        do {
            let regEx = try NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(location: 0, length: count)
            let matches = regEx.matches(in: self, options: [], range: range)
            if let match = matches.first, match.numberOfRanges > 2 {
                let totalRange = match.range(at: 0)
                let matchRange = match.range(at: 2)
                if substring(with: totalRange) == self, let result = substring(with: matchRange)?.notWhitespaces() {
                    return result.splitByLength(3).joined(separator: " ")
                }
            }
        } catch {}
        return self
    }
    
    func notWhitespaces() -> String {
        let components = self.components(separatedBy: .whitespacesAndNewlines)
        return components.joined(separator: "")
    }
    
    func obfuscateNumber(withNumberOfAsterisks: Int? = 4) -> String {
        let pattern = "(0*34|\\+0*34|\\(0*34\\))?([0-9][0-9])[0-9]{5}([0-9][0-9])"
        let text = notWhitespaces()
        do {
            let regEx = try NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(location: 0, length: text.count)
            let matches = regEx.matches(in: text, options: [], range: range)
            if let match = matches.first, match.numberOfRanges > 3 {
                let matchRange = match.range(at: 2)
                let lastMatchRange = match.range(at: 3)
                let asterisks = withNumberOfAsterisks ?? 4
                if let result = text.substring(with: matchRange)?.notWhitespaces(), let lastResult = text.substring(with: lastMatchRange)?.notWhitespaces() {
                    var output = result
                    for _ in 0 ... asterisks-1 {
                        output += "*"
                    }
                    return "\(output)\(lastResult)"
                }
            }
        } catch {}
        return self
    }
    
    func obfuscateNumberFirstSixDigits() -> String {
        let pattern = "[0-9]{6}([0-9][0-9][0-9])"
        let text = notWhitespaces()
        do {
            let regEx = try NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(location: 0, length: text.count)
            let matches = regEx.matches(in: text, options: [], range: range)
            if let match = matches.first, match.numberOfRanges > 1 {
                let matchRange = match.range(at: 1)
                if let result = text.substring(with: matchRange)?.notWhitespaces() {
                    return "******\(result)"
                }
            }
        } catch {}
        return self
    }
    
    func htmlToAttributedStringWithOptions(_ options: [NSAttributedString.Key: Any]) -> NSAttributedString {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        
        if let attributedString = try? NSAttributedString(data: data,
                                                          options: [.documentType: NSAttributedString.DocumentType.html,
                                                                    .characterEncoding: String.Encoding.utf8.rawValue],
                                                          documentAttributes: nil) {
            let string = NSMutableAttributedString(attributedString: attributedString)
            if let color = options[.foregroundColor] {
                string.addAttributes([.foregroundColor: color],
                                     range: NSRange(location: 0, length: string.length))
            }
            
            if let font = options[.font] as? UIFont {
                var comps = font.fontName.components(separatedBy: "-")
                comps.removeLast(1)
                comps.append("-Bold")
                let boldName = comps.reduce("") { $0 + $1 }
                let boldFont = UIFont(name: boldName, size: font.pointSize)
                
                string.enumerateAttribute(.font,
                                          in: NSRange(location: 0, length: string.length),
                                          options: NSAttributedString.EnumerationOptions(rawValue: 0),
                                          using: { (value, range, _) -> Void in
                    if let oldFont = value as? UIFont, oldFont.fontName.lowercased().contains("bold") {
                        string.removeAttribute(.font, range: range)
                        string.addAttribute(.font, value: boldFont as Any, range: range)
                    } else {
                        string.addAttribute(.font, value: font, range: range)
                    }
                })
            }
            if let lastCharacter = string.string.last, lastCharacter == "\n" {
                string.deleteCharacters(in: NSRange(location: string.length-1, length: 1))
            }
            return string
        }
        return NSAttributedString()
    }
    
    func isValidEmail() -> Bool {
        do {
            let regex = try NSRegularExpression(pattern: "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}", options: .caseInsensitive)
            return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
        } catch {
            return false
        }
    }
    
    func match(regex: NSRegularExpression, options: NSRegularExpression.MatchingOptions = []) -> Bool {
        return regex.matches(in: self, options: options, range: NSRange(location: 0, length: count)).isEmpty == false
    }
    
    func replace(regex: NSRegularExpression, options: NSRegularExpression.MatchingOptions = [], replacement: String) -> String {
        var result = self
        regex.matches(in: self, options: options, range: NSRange(location: 0, length: count)).compactMap { Range<String.Index>($0.range, in: self) }.forEach { result.replaceSubrange($0, with: replacement) }
        return result
    }
    
    func matches(regex: NSRegularExpression, options: NSRegularExpression.MatchingOptions = []) -> [String] {
        return regex.matches(in: self, options: options, range: NSRange(location: 0, length: count))
            .flatMap { result in
                return Array(0..<result.numberOfRanges).compactMap { return Range<String.Index>(result.range(at: $0), in: self) }
            }.map { String(self[$0])  }
    }
    
    func asterisk() -> String {
        let totalLenght: Int = count
        let lenght: Int = totalLenght > 4 ? totalLenght - 4: totalLenght
        let end: String = String(suffix(totalLenght - lenght))
        let asterisks: String = String(repeating: "*", count: lenght)
        return asterisks + end
    }
    
    func withMaxSize(_ size: Int, truncateTail: Bool = false) -> String {
        guard self.count > size else { return self }
        var string = self.substring(0, size) ?? ""
        string.append(truncateTail && self.count > size ? "..." : "")
        return string
    }
    
    func indexDistance(of character: Character) -> Int? {
        guard let index = firstIndex(of: character) else {
            return nil
        }
        
        return distance(from: startIndex, to: index)
    }

    func toDate(dateFormat format: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        return dateFormatter.date(from: self)!
    }
    
    func asEventCode() -> String? {
        let stringComponents = self.components(separatedBy: "/")
        if stringComponents.count >= 3 {
            return stringComponents[3]
        } else {
            return nil
        }
    }
    
    func append(prefix: String) -> String {
        if self.contains(prefix) { return self }
        return "\(prefix)\(self)"
    }
    
    func replace(_ target: String, _ replacement: String) -> String {
        return self.replacingOccurrences(of: target, with: replacement)
    }
    
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func splitByLength(_ length: Int) -> [String] {
        return stride(from: 0, to: self.count, by: length).map {
            let start = self.index(self.startIndex, offsetBy: $0)
            let end = self.index(start, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
            return String(self[start..<end])
        }
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
    
    func completeRightCharacter(size: Int, char: String = "") -> String {
        var temp = ""
        for _ in (0..<size - self.count) {
            temp = temp + char
        } 
        return self + temp
    }
    
    func indexes(of occurrence: String) -> [Int] {
        var indices = [Int]()
        var position = startIndex
        while let range = range(of: occurrence, options: .caseInsensitive, range: position..<endIndex) {
            let ind = distance(from: startIndex,
                               to: range.lowerBound)
            indices.append(ind)
            let offset = occurrence.distance(from: occurrence.startIndex,
                                             to: occurrence.endIndex) - 1
            guard let after = index(range.lowerBound,
                                    offsetBy: offset,
                                    limitedBy: endIndex) else {
                break
            }
            position = index(after: after)
        }
        return indices
    }
    
    func ranges(of searchString: String) -> [Range<String.Index>] {
        let indexesList = indexes(of: searchString)
        let count = searchString.count
        return indexesList.map({ index(startIndex, offsetBy: $0)..<index(startIndex, offsetBy: $0+count) })
    }
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    // you can use this if your string comes in a big block and is seperated in /n
    func toUppercaseAtSentenceBoundary() -> String {
        var result = ""
        if self.contains("\n") {
            self.uppercased().enumerateSubstrings(in: self.startIndex..<self.endIndex, options: .bySentences) { (sub, _, _, _)  in
                result += String(sub!.prefix(1))
                result += String(sub!.dropFirst(1)).lowercased()
            }
        } else {
            result += String(self.prefix(1))
            result += String(self.dropFirst(1)).lowercased()
        }
        return result as String
    }
    
    func cutString() -> String {
        let index = self.index(self.startIndex, offsetBy: 3)
        let mySubString = self.prefix(upTo: index)
        let myString = String(mySubString)
        return myString
    }
    
    func convertHtml() -> NSAttributedString{
        guard let data = data(using: .utf16) else { return NSAttributedString() }
        do{
            return try NSAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
        }catch{
            return NSAttributedString()
        }
    }
    
    var dataDecoded: String? {
        guard let decodedData = Data(base64Encoded: self) else {
            return nil
        }
        let decodedString = NSString(data: decodedData as Data, encoding: String.Encoding.utf8.rawValue)
        return decodedString as String?
    }
    
    var isNotEmpty: Bool {
        return !self.isEmpty
    }
    
    var trimed: String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func match(inAny occurrences: [String]) -> Bool {
        return occurrences.anyMatch(with: self)
    }
    
    func match(withPattern pattern: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return false
        }
        let range = NSRange(location: 0, length: self.count)
        return regex.firstMatch(in: self, options: [], range: range) != nil
    }
    
    var linkedInPattern: String {
        return "^http[s]?://(linkedin.com|.+\\.linkedin.com)/in/(.*)$"
    }
    
}

// MARK: - Subscripts
public extension String {
    subscript(offsetBy: Int) -> String {
        return String(self[index(startIndex, offsetBy: offsetBy)])
    }
    
    subscript(range: Range<Int>) -> String {
        let lower = index(startIndex, offsetBy: range.lowerBound)
        let upper = index(startIndex, offsetBy: range.lowerBound + range.upperBound)
        let stringRange = Range<String.Index>(uncheckedBounds: (lower: lower, upper: upper))
        return String(self[stringRange])
    }
    
    subscript(range: ClosedRange<Int>) -> String {
        let lower = index(startIndex, offsetBy: range.lowerBound)
        let upper = index(startIndex, offsetBy: range.lowerBound + range.upperBound + 1)
        let stringRange = Range<String.Index>(uncheckedBounds: (lower: lower, upper: upper))
        return String(self[stringRange])
    }
}


// MARK: - Crypto
public extension String {
    func keyFromPassword(password: String) -> Data? {
        let length = kCCKeySize3DES
        var key = password
        
        while key.count < length {
            key += password
        }
        
        if password.count > length {
            key = password.substring(0, length-1)!
        }
        
        return key.data(using: .utf8)
    }
    
    func ivFromPassword(password: String) -> Data? {
        let length = 8
        var key = password
        
        while key.count < length {
            key += password
        }
        
        if password.count > length {
            key = password.substring(0, length-1)!
        }
        
        return key.data(using: .utf8)
    }
    
    func transformData(inputData: Data, operation: CCOperation, password32: String) -> Data? {
        
        guard let key24 = password32.substring(0, 24) else {
            return nil
        }
        
        let key = keyFromPassword(password: key24)
        guard let newPass = password32.substring(24) else {
            return nil
        }
        
        let iv = ivFromPassword(password: newPass)
        let outputData: NSMutableData? = NSMutableData(length: inputData.count + kCCBlockSize3DES)
        
        guard let keyData = key, let ivData = iv, let strongOutputData = outputData else {
            return nil
        }
        
        var outLenght: size_t = strongOutputData.length
        let result = CCCrypt(operation, CCAlgorithm(kCCAlgorithm3DES), CCOptions(kCCOptionPKCS7Padding), NSData(data: keyData).bytes, keyData.count, NSData(data: ivData).bytes, NSData(data: inputData).bytes, inputData.count, strongOutputData.mutableBytes, strongOutputData.length, &outLenght)
        
        if result != kCCSuccess {
            return nil
        }
        
        strongOutputData.length = outLenght
        return strongOutputData as Data
    }
    
    func encryptWithKey(keyString: String) -> String {
        guard let data = self.data(using: .utf8) else {
            return ""
        }
        
        guard let encryptedData: Data = transformData(inputData: data, operation: CCOperation(kCCEncrypt), password32: keyString) else {
            return ""
        }
        let base64string = encryptedData.base64EncodedString()
        return base64string
    }
    
    func decryptWithKey(keyString: String) -> String {
        guard let base64String = Data(base64Encoded: self) else {
            return ""
        }
        
        guard let decryptedData: Data = transformData(inputData: base64String, operation: CCOperation(kCCDecrypt), password32: keyString) else {
            return ""
        }
        
        return String(data: decryptedData, encoding: String.Encoding.utf8) ?? ""
    }
}

public extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return ceil(boundingBox.width)
    }
    
    func height(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [kCTFontAttributeName as NSAttributedString.Key: font], context: nil)
        
        return ceil(boundingBox.height)
    }
}

// MARK: Base 64 extension

public extension String {
    func getEncodeString(withOptions options: Data.Base64EncodingOptions = []) -> String? {
        guard let utf8string = self.data(using: .utf8) else { return nil }
        let base64EncodedString = utf8string.base64EncodedString(options: options)
        return base64EncodedString
    }
    
    func isEmoji() -> Bool {
        guard self != "" else {return false}
        let emojiRanges = [
            (8205, 11093),
            (12336, 12953),
            (65039, 65039),
            (126980, 129685)
        ]
        let codePoint = self.unicodeScalars[self.unicodeScalars.startIndex].value
        for emojiRange in emojiRanges {
            if codePoint >= emojiRange.0 && codePoint <= emojiRange.1 {
                return true
            }
        }
        return false
    }
}

public extension Sequence where Iterator.Element == String {
    /**
     Find any occurences of given string in any part of every item. This func is CASE and ACCENT INSENSITIVE
     */
    func anyMatch(with occurrence: String) -> Bool {
        return contains(where: { element in
            return occurrence.range(of: element, options: [.diacriticInsensitive, .caseInsensitive], range: nil, locale: nil) != nil
        })
    }
}

// -MARK: Substring

public extension String {
    
    func substring(ofLast last: Int) -> String? {
        return substring(self.count - last)
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
    
}
