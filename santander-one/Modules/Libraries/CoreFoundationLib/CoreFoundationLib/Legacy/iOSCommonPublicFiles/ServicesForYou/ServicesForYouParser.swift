import Foundation


public struct ServicesForYouParser: Parser {    
    public init() { }
    
    public func serialize(_ responseString: String) -> ServicesForYouDTO? {
        guard let jsonData = responseString.data(using: .utf8) else {
            return nil
        }
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(ServicesForYouDTO.self, from: jsonData)
        } catch let error {
            print("❌ Fail to serialize JSON ➡️ \(String(describing: ServicesForYouParser.self)) with error \(error.localizedDescription)")
            return nil
        }
    }
    
    public func deserialize(_ data: ServicesForYouDTO) -> String? {
        let jsonDataEncode = try? JSONEncoder().encode(data)
        
        if let jsonData = jsonDataEncode, let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        return nil
    }
}
