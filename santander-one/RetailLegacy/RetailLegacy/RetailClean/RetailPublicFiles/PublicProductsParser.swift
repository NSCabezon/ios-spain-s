import Foundation
import CoreFoundationLib

public class PublicProductsParser: Parser {
    
    var logTag: String {
        return String(describing: type(of: self))
    }
    
    public func deserialize(_ data: PublicProductsDTO) -> String? {
        let jsonDataEncode = try? JSONEncoder().encode(data)
        
        if let jsonData = jsonDataEncode, let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        return nil
    }
    
    public func serialize(_ responseString: String) -> PublicProductsDTO? {
        guard let data = responseString.data(using: .utf8) else { return nil }
        
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(PublicProductsDTO.self, from: data)
        } catch let error {
            RetailLogger.e(logTag, "❌ Fail to serialize JSON ➡️ \(String(describing: PublicProductsDTO.self)) with error \(error.localizedDescription)")
            return nil
        }
    }
    
}
