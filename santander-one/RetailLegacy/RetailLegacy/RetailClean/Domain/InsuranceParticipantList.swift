import SANLegacyLibrary

class InsuranceParticipantList: GenericProductList<InsuranceParticipant> {
    static func create(_ from: [InsuranceParticipantDTO]?) -> InsuranceParticipantList {
        let list = from?.compactMap { InsuranceParticipant.create($0) } ?? []
        return self.init(list)
    }
}
