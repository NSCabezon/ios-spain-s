import Foundation

public class BSANAssemble {

    public let facade: String
    public let endPoint: String
    public let acronym: String

    convenience init(_ facade: String, _ endPoint: String) {
        self.init(facade, endPoint, "")
    }

    init(_ facade: String, _ endPoint: String, _ acronym: String) {
        BSANLogger.d(String(describing: type(of:self)), "Facade: \(facade)")
        BSANLogger.d(String(describing: type(of:self)), "Endpoint: \(endPoint)")
        BSANLogger.d(String(describing: type(of:self)), "Acronym: \(acronym)")
        self.facade = facade
        self.endPoint = endPoint
        self.acronym = acronym
    }
    
}
