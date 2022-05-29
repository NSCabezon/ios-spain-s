import Foundation

public class PullOffersDataDTO: Codable {
    private var rules: ThreadSafeProperty<[String: Bool]>
    private var offers: ThreadSafeProperty<[String: String]>
    
    public init() {
        self.rules = ThreadSafeProperty([:])
        self.offers = ThreadSafeProperty([:])
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rules = try container.decode([String: Bool].self, forKey: .rules)
        let offers = try container.decode([String: String].self, forKey: .offers)
        self.rules = ThreadSafeProperty(rules)
        self.offers = ThreadSafeProperty(offers)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(rules.value, forKey: .rules)
        try container.encode(offers.value, forKey: .offers)
    }
    
    enum CodingKeys: CodingKey {
        case rules, offers
    }
    
    func setRule(identifier: String, isValid: Bool) {
        rules.value[identifier] = isValid
    }
    
    func isValidRule(identifier: String) -> Bool? {
        return rules.value[identifier]
    }
    
    func setOffer(location: String, offerId: String?) {
        offers.value[location] = offerId
    }
    
    func getOffer(location: String) -> String? {
        return offers.value[location]
    }
    
    func removeOffer(location: String) {
        offers.value.removeValue(forKey: location)
    }
    
    func reset() {
        rules.value.removeAll()
        offers.value.removeAll()
    }
}
