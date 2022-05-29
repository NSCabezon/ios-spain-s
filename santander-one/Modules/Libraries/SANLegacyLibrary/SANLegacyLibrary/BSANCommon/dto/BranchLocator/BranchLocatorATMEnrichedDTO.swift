//

import Foundation

public struct BranchLocatorATMEnrichedDTO: BranchLocatorBaseDTO  {
    public let code: String
    public let location: LocationDTO
    public let distance: Double
    public let merchantCsb: Int
    public let branchCsb: Int
    public let atmOrder: Int
    public let stateAtmName: String?
    public let dispensation: Bool?
    public let caj10: Bool?
    public let caj20: Bool?
    public let caj50: Bool?
    public let deposit: Bool?
    public let stateDeposit: Bool?
    public let contactless: Bool?
    public let barsCode: Bool?
    
    enum CodingKeys: String, CodingKey {
        case code
        case location
        case distance = "distanceInKm"
        case merchantCsb, branchCsb, atmOrder, stateAtmName
        case dispensation, caj10, caj20, caj50, deposit, stateDeposit, contactless, barsCode
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        code = try values.decode(String.self, forKey: .code)
        location = try values.decode(LocationDTO.self, forKey: .location)
        merchantCsb = try values.decode(Int.self, forKey: .merchantCsb)
        branchCsb = try values.decode(Int.self, forKey: .branchCsb)
        atmOrder = try values.decode(Int.self, forKey: .atmOrder)
        stateAtmName = try values.decodeIfPresent(String.self, forKey: .stateAtmName)
        dispensation = BranchLocatorATMEnrichedDTO.getAdaptedValueFromCodingKey(.dispensation, container: values)
        caj10 = BranchLocatorATMEnrichedDTO.getAdaptedValueFromCodingKey(.caj10, container: values)
        caj20 = BranchLocatorATMEnrichedDTO.getAdaptedValueFromCodingKey(.caj20, container: values)
        caj50 = BranchLocatorATMEnrichedDTO.getAdaptedValueFromCodingKey(.caj50, container: values)
        deposit = BranchLocatorATMEnrichedDTO.getAdaptedValueFromCodingKey(.deposit, container: values)
        stateDeposit = BranchLocatorATMEnrichedDTO.getAdaptedValueFromCodingKey(.stateDeposit, container: values)
        contactless = BranchLocatorATMEnrichedDTO.getAdaptedValueFromCodingKey(.contactless, container: values)
        barsCode = BranchLocatorATMEnrichedDTO.getAdaptedValueFromCodingKey(.barsCode, container: values)
        distance = try values.decode(Double.self, forKey: .distance)
    }
}

private extension BranchLocatorATMEnrichedDTO {
    static func getAdaptedValueFromCodingKey(_ codingKey: BranchLocatorATMEnrichedDTO.CodingKeys, container: KeyedDecodingContainer<BranchLocatorATMEnrichedDTO.CodingKeys>) ->  Bool? {
        do {
            guard let optionalValue = try container.decodeIfPresent(String.self, forKey: codingKey) else {
                return nil
            }
            return optionalValue == "OK" ? true : false
        } catch {
            return nil
        }
    }
}
