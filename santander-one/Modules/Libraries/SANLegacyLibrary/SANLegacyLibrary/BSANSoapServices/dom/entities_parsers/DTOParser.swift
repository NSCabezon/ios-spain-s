import Foundation
import Fuzi

open class DTOParser {
    
    public var logTag: String {
        return String(describing: type(of: self))
    }
    
    public init () {}
    
    public static func safeBoolean(_ valor: String?) -> Bool {
        if let valor = valor, valor.count != 0 {
            return ("S" == valor.trim().uppercased() || "TRUE" == valor.trim().uppercased())
        }
        
        if valor != nil {
            BSANLogger.e(DTOParser().logTag, "safeBoolean -> \(valor ?? "")")
        }
        
        return false        
    }
    
    public static func safeInteger(_ valor: String?) -> Int? {
        if let value = valor, !value.trim().isEmpty {
            return Int(value)
        }
        return nil
    }
    
    public static func safeLong(_ valor: String?) -> Int64? {
        if let value = valor, !value.trim().isEmpty {
            return Int64(value)
        }
        return nil
    }
    
    public static func safeDecimal(_ valor: String?) -> Decimal? {
        if let value = valor, !value.trim().isEmpty {
            return Decimal(string: value)
        }
        return nil
    }
    
    public static func safePositions(_ posiciones: String?) -> [Int]? {
        if let posiciones = posiciones, !posiciones.trim().isEmpty {
            let posicionesArray: [String] = posiciones.split(" ")
            var posicionesIntArray: [Int] = []
            for s in posicionesArray {
                let posicion = Int(s)
                posicionesIntArray.append(posicion ?? 0)
            }
            return posicionesIntArray
        }
        return nil
    }
}
