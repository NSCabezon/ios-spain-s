import Foundation

public class DocumentValidator {
    public typealias Result = (idType: IdType?, isValid: Bool)
    private let regexWarehouse: RegexWarehouse
    
    public init() {
        self.regexWarehouse = RegexWarehouse()
    }
    
    public func validate(_ document: String) -> Bool {
        return validate(document).isValid
    }
    
    public func validate(_ document: String) -> Result {
        guard document.isEmpty == false else {
            return (idType: nil, isValid: false)
        }
        let normalized = document.uppercased().replace(regex: regexWarehouse.regex(.spaces), replacement: "")
        guard let documentType = IdType(document: normalized, warehouse: regexWarehouse) else {
            return (idType: nil, isValid: false)
        }
        
        let isValid: Bool
        switch documentType {
        case .dni:
            isValid = validateDNI(dni: normalized)
        case .specialNif:
            isValid = validateSpecialNIF(nif: normalized)
        case .cif:
            isValid = validateCIF(cif: normalized)
        case .nie:
            isValid = validateNIE(nie: normalized)
        }
        return (idType: documentType, isValid: isValid)
    }
    
    private func validateDNI(dni: String) -> Bool {
        return validateNIF(nif: dni, length: dni.count)
    }
    
    private func validateSpecialNIF(nif: String) -> Bool {
        let prepared = prepareForValidation(document: nif, replacements: [("K", ""), ("L", ""), ("M", "")])
        return validateNIF(nif: prepared, length: 8)
    }
    
    private func validateNIE(nie: String) -> Bool {
        let prepared = prepareForValidation(document: nie, replacements: [("X", "0"), ("Y", "1"), ("Z", "2")])
        return validateNIF(nif: prepared, length: nie.count)
    }
    
    private func validateNIF(nif: String, length: Int) -> Bool {
        guard length == nif.count, !nif.containsEmoji else {
            return false
        }
        let nifLetters = "TRWAGMYFPDXBNJZSQVHLCKE"
        let number = nif[0...length-2]
        guard let conversion = Int(number) else {
            return false
        }
        let controlLetter = nifLetters[conversion % nifLetters.count]
        let letter = nif[nif.count - 1]
        return letter == controlLetter
    }
    
    private typealias Replacement = (String, String)
    
    private func prepareForValidation(document: String, replacements: [Replacement]) -> String {
        guard let first = document.first else {
            return document
        }
        var document = document
        for replacement in replacements {
            if String(first) == replacement.0 {
                document = replacement.1 + document.dropFirst()
                break
            }
        }
        return document
    }
    
    public func validateCIF(cif: String) -> Bool {
        guard cif.count == 9, !cif.containsEmoji else {
            return false
        }
        
        let valueCif = String(cif[cif.index(after: cif.startIndex) ..< cif.index(before: cif.endIndex)])
        var suma = 0
        
        var currIndex = valueCif.index(after: valueCif.startIndex)
        while currIndex < valueCif.endIndex {
            if Int(String(valueCif[currIndex..<valueCif.index(after: currIndex)])) != nil {
                suma += Int(String(valueCif[currIndex..<valueCif.index(after: currIndex)]))!
                currIndex = valueCif.index(currIndex, offsetBy: 2)
            } else {
                return false
            }
        }
        
        var suma2 = 0
        
        var currIndex2 = valueCif.startIndex
        while currIndex2 < valueCif.endIndex {
            let result = Int(String(valueCif[currIndex2..<valueCif.index(after: currIndex2)]))! * 2
            
            if result > 9 {
                suma2 += digitsSum(result)
            } else {
                suma2 += result
            }
            
            if currIndex2 != valueCif.index(before: valueCif.endIndex) {
                currIndex2 = valueCif.index(currIndex2, offsetBy: 2)
            } else {
                break
            }
        }
        
        let totalSum = suma + suma2
        
        let unidadStr = "\(totalSum)"
        var unidadInt = 10 - Int(String(unidadStr[unidadStr.index(before: unidadStr.endIndex) ..< unidadStr.endIndex]))!
        
        let primerCaracter = String(cif[..<cif.index(after: cif.startIndex)]).uppercased()
        let lastchar = String(cif[cif.index(before: cif.endIndex)...]).uppercased()
        var lastcharchar = lastchar[lastchar.startIndex]
        if Int(lastchar) != nil {
            lastcharchar = Character(UnicodeScalar(64 + Int(lastchar)!)!)
        }
        
        if "FJKNPQRSUVW".contains(primerCaracter) {
            let value = Character(UnicodeScalar(64+unidadInt)!)
            if value == lastcharchar {
                return true
            }
        } else if "XYZ".contains(primerCaracter) {
            return validateNIE(nie: cif)
            
        } else if "ABCDEFGHLM".contains(primerCaracter) {
            if unidadInt == 10 {
                unidadInt = 0
            }
            
            let unidadChar = Character(UnicodeScalar(64 + unidadInt)!)
            let lastSubstring = String(cif[cif.index(before: cif.endIndex)...])
            if "\(unidadInt)" == lastSubstring {
                return true
            }
            
            if unidadChar == lastSubstring[lastSubstring.startIndex] {
                return true
            }
        } else {
            return validateDNI(dni: cif)
        }
        
        return false
    }
    
    // Sum digits values for Int <= 100
    private func digitsSum(_ value: Int) -> Int {
        var currentResult: Int = 0
        var currentValue = value
        
        if currentValue <= 100 && currentValue > 10 {
            currentResult += currentValue%10
            currentValue /= 10
            currentResult += currentValue
            return currentResult
        }
        
        if currentValue == 10 {
            currentResult += 1
            return currentResult
        }
        
        return currentResult
    }
}

extension DocumentValidator {
    public enum IdType {
        case dni
        case specialNif
        case cif
        case nie
        
        init?(document: String, warehouse: RegexWarehouse) {
            switch document {
            case document where document.match(regex: warehouse.regex(.dni)):
                self = .dni
            case document where document.match(regex: warehouse.regex(.specialNif)):
                self = .specialNif
            case document where document.match(regex: warehouse.regex(.cif)):
                self = .cif
            case document where document.match(regex: warehouse.regex(.nie)):
                self = .nie
            default:
                return nil
            }
        }
    }
    
    enum Regex: String, CaseIterable {
        case dni = "^(\\d{1,8})[A-Z]$"
        case specialNif = "^([KLM]\\d{7})[A-Z]$"
        case cif = "^([ABCDEFGHJKLMNPQRSUVW])(\\d{7})([0-9A-J])$"
        case nie = "^[XYZ]\\d{7,8}[A-Z]$"
        case spaces = "\\s"
        case abehLetters = "[ABEH]"
        case kpqsLetters = "[KPQS]"
    }
    
    struct RegexWarehouse {
        private let regexs: [Regex: NSRegularExpression]
        init() {
            func createRegexs() -> [Regex: NSRegularExpression] {
                var regexs = [Regex: NSRegularExpression]()
                Regex.allCases.map { regId -> (Regex, NSRegularExpression?) in
                    (regId, try? NSRegularExpression(pattern: regId.rawValue, options: []))
                    }.forEach { regexs[$0.0] = $0.1 }
                
                return regexs
            }
            
            self.regexs = createRegexs()
        }
        
        func regex(_ regex: Regex) -> NSRegularExpression {
            guard let regularExpression = regexs[regex] else {
                fatalError("Regex not registered")
            }
            return regularExpression
        }
    }
}
