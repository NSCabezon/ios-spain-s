//

import Foundation

public class UserSegmentOld: NSObject, NSCoding {
    public let segmentoBDP: String?
    public let segmentoComercial: String?
    public let indColectivoS: Bool?
    public let indColectivoRenunAcc: Bool?
    public let indColectivoCarenciaOGracia: Bool?
    public let indColectivoSAutonomo: Bool?
    public let indColectivoSEmpresas: Bool?
    public let colectivo123Smart: Bool?
    public let colectivo123SmartFree: Bool?
    public let colectivoAutonomoPrem: Bool?
    public let colectivoAutonomoFree: Bool?
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(segmentoBDP, forKey: "segmentoBDP")
        aCoder.encode(segmentoComercial, forKey: "segmentoComercial")
        aCoder.encode(indColectivoS, forKey: "indColectivoS")
        aCoder.encode(indColectivoRenunAcc, forKey: "indColectivoRenunAcc")
        aCoder.encode(indColectivoCarenciaOGracia, forKey: "indColectivoCarenciaOGracia")
        aCoder.encode(indColectivoSAutonomo, forKey: "indColectivoSAutonomo")
        aCoder.encode(indColectivoSEmpresas, forKey: "indColectivoSEmpresas")
        aCoder.encode(colectivo123Smart, forKey: "colectivo123Smart")
        aCoder.encode(colectivo123SmartFree, forKey: "colectivo123SmartFree")
        aCoder.encode(colectivoAutonomoPrem, forKey: "colectivoAutonomoPrem")
        aCoder.encode(colectivoAutonomoFree, forKey: "colectivoAutonomoFree")
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.segmentoBDP = aDecoder.decodeObject(forKey: "segmentoBDP") as? String
        self.segmentoComercial = aDecoder.decodeObject(forKey: "segmentoComercial") as? String
        self.indColectivoS = aDecoder.decodeObject(forKey: "indColectivoS") as? Bool
        self.indColectivoRenunAcc = aDecoder.decodeObject(forKey: "indColectivoRenunAcc") as? Bool
        self.indColectivoCarenciaOGracia = aDecoder.decodeObject(forKey: "indColectivoCarenciaOGracia") as? Bool
        self.indColectivoSAutonomo = aDecoder.decodeObject(forKey: "indColectivoSAutonomo") as? Bool
        self.indColectivoSEmpresas = aDecoder.decodeObject(forKey: "indColectivoSEmpresas") as? Bool
        self.colectivo123Smart = aDecoder.decodeObject(forKey: "colectivo123Smart") as? Bool
        self.colectivo123SmartFree = aDecoder.decodeObject(forKey: "colectivo123SmartFree") as? Bool
        self.colectivoAutonomoPrem = aDecoder.decodeObject(forKey: "colectivoAutonomoPrem") as? Bool
        self.colectivoAutonomoFree = aDecoder.decodeObject(forKey: "colectivoAutonomoFree") as? Bool
    }
}
