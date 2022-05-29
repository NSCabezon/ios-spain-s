import Foundation

/// Generic class to create parser for 'Codable' types
public class CodableParser<Parseable: Codable>: Parser {
    
    var logTag: String {
        return String(describing: type(of: self))
    }
    
    public init() { }
    
    public func serialize(_ responseString: String) -> Parseable? {
        guard let jsonData = responseString.data(using: .utf8) else {
            return nil
        }
        do {
            let decoder = JSONDecoder()
            if let dateParseable = Parseable.self as? DateParseable.Type {
                decoder.dateDecodingStrategy = .custom(dateParseable.decode)
            }
            return try decoder.decode(Parseable.self, from: jsonData)
        } catch {
            RetailLogger.e(logTag, "❌ Fail to serialize JSON ➡️ \(String(describing: Parseable.self)) with error \(error.localizedDescription)")
            return nil
        }
    }
     
    public func deserialize(_ data: Parseable) -> String? {
        let encoder = JSONEncoder()
        if let dateParseable = Parseable.self as? DateParseable.Type {
            encoder.dateEncodingStrategy = .custom(dateParseable.encoding)
        }
        do {
            let jsonDataEncode = try encoder.encode(data)
            guard let jsonString = String(data: jsonDataEncode, encoding: .utf8) else { return nil }
            return jsonString
        } catch {
            RetailLogger.e(logTag, "❌ Fail to deserialize ➡️ \(String(describing: Parseable.self)) with error \(error.localizedDescription)")
        }
        return nil
    }
}
