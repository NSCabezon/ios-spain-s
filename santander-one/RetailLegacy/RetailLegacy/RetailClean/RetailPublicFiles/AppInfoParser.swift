import Foundation
import CoreFoundationLib

public class AppInfoParser: Parser {
    
    var logTag: String {
        return String(describing: type(of: self))
    }
        
    public func deserialize(_ parseable: AppInfoDTO) -> String? {
        return "\(parseable.getVersions.description.replacingOccurrences(of: "[", with: "{").replacingOccurrences(of: "]", with: "}"))"
    }
    
    public func serialize(_ responseString: String) -> AppInfoDTO? {
        guard let data = responseString.data(using: .utf8) else { return nil }
        
        do {
            guard let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
                return nil
            }
            
            guard json.count > 0 else {
                return nil
            }
            
            var output = [String: [String: String]]()
            for (key, value) in json {
                if let elem = value as? [String: String] {
                    var innerElem = [String: String]()
                    for (innerKey, innerValue) in elem {
                        innerElem[innerKey] = innerValue
                    }
                    output[key] = innerElem
                }
            }
            
            return AppInfoDTO(versions: output)
        } catch {
            RetailLogger.e(logTag, "Failed to serialize JSON.")
        }
        
        return nil
    }
    
}
