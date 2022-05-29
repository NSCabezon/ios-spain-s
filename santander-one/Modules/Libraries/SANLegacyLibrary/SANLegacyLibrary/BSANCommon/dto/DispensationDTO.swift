import Foundation

public struct DispensationDTO: Codable {
    public var descFechaHoraPet: Date?
    public var numMensaje: String?
    public var descPAN: String?
    public var descFechaHoraExp: Date?
    public var numEstado: String?
    public var impAdisp: AmountDTO?
    public var decryptedData: DecryptedDataDTO?
    
    public init() {}
}
