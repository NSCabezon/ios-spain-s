import Foundation
import CoreDomain

public struct CardMovementLocationDTO: Decodable {
    public let date: Date?
    public let amount: Decimal?
    public let concept: String?
    public let address: String?
    public let location: String?
    public let category: String?
    public let subcategory: String?
    public let latitude: Double?
    public let longitude: Double?
    public let postalCode: String?
    public let status: String?
    
    private enum CodingKeys: String, CodingKey {
        case date
        case amount
        case concept
        case address
        case location
        case category
        case subcategory
        case latitude = "lat"
        case longitude = "lng"
        case postalCode = "postal_code"
        case status
    }
    
    public init(locationDTO: CardMovementLocationDTO, latitude: Double, longitude: Double) {
        self.date = locationDTO.date
        self.amount = locationDTO.amount
        self.concept = locationDTO.concept
        self.address = locationDTO.address
        self.location = locationDTO.location
        self.category = locationDTO.category
        self.subcategory = locationDTO.subcategory
        self.postalCode = locationDTO.postalCode
        self.latitude = latitude
        self.longitude = longitude
        self.status = locationDTO.status
    }
    
    public init(locationRepresentable: CardMovementLocationRepresentable, latitude: Double, longitude: Double) {
        self.date = locationRepresentable.date
        self.amount = locationRepresentable.amountRepresentable?.value
        self.concept = locationRepresentable.concept
        self.address = locationRepresentable.address
        self.location = locationRepresentable.location
        self.category = locationRepresentable.category
        self.subcategory = locationRepresentable.subcategory
        self.postalCode = locationRepresentable.postalCode
        self.latitude = latitude
        self.longitude = longitude
        self.status = locationRepresentable.status
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitudeString = try container.decode(String.self, forKey: .latitude)
        guard let latitude = Double(latitudeString) else {
            throw NSError()
        }
        self.latitude = latitude
        let longitudeString = try container.decode(String.self, forKey: .longitude)
        guard let longitude = Double(longitudeString) else {
            throw NSError()
        }
        self.longitude = longitude
        let dateString = try? container.decode(String.self, forKey: .date)
        if let dateStringUnwrapped = dateString {
            self.date = DateFormats.toDate(string: dateStringUnwrapped, output: DateFormats.TimeFormat.YYYYMMDD_HHmmss)
        } else {
            self.date = nil
        }
        let amountString = try? container.decode(String.self, forKey: .amount)
        self.amount = DTOParser.safeDecimal(amountString)
        self.concept = try? container.decode(String.self, forKey: .concept)
        self.address = try? container.decode(String.self, forKey: .address)
        self.location = try? container.decode(String.self, forKey: .location)
        self.category = try? container.decode(String.self, forKey: .category)
        self.subcategory = try? container.decode(String.self, forKey: .subcategory)
        self.postalCode = try? container.decode(String.self, forKey: .postalCode)
        self.status = try? container.decode(String.self, forKey: .status)
    }
}

extension CardMovementLocationDTO: CardMovementLocationRepresentable {
    public var amountRepresentable: AmountRepresentable? {
        guard let amount = amount else {
            return nil
        }
        return AmountDTO(value: amount, currency: .create(.eur))
    }
}
