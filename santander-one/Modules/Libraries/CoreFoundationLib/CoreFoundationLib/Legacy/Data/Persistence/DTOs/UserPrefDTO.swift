public class UserPrefDTO: Codable {
    public var userId: String
    public var pgUserPrefDTO: PGUserPrefDTO = PGUserPrefDTO()
    public var isUserPb: Bool = false
    public var coachmarksPref = [String]()
    public var frequentOperativePrefDTO: [FrequentOperativePrefDTO]?
    
    public var isMigrationSuccess: Bool = false
    
    public init(userId: String) {
        self.userId = userId
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        userId = try container.decode(String.self, forKey: .userId)
        pgUserPrefDTO = try container.decode(PGUserPrefDTO.self, forKey: .pgUserPrefDTO)
        isUserPb = try container.decode(Bool.self, forKey: .isUserPb)
        coachmarksPref = try container.decode([String].self, forKey: .coachmarksPref)
        frequentOperativePrefDTO = try container.decodeIfPresent([FrequentOperativePrefDTO].self, forKey: .frequentOperativePrefDTO)
        isMigrationSuccess = try container.decodeIfPresent(Bool.self, forKey: .isMigrationSuccess) ?? false
    }
}

// MARK: Codable
extension UserPrefDTO {
    enum CodingKeys: String, CodingKey {
        case userId
        case pgUserPrefDTO
        case frequentOperativePrefDTO
        case isUserPb
        case coachmarksPref
        case isMigrationSuccess
    }
}
