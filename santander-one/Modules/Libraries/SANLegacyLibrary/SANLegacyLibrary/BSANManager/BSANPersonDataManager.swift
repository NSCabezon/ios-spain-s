public protocol BSANPersonDataManager {
    func loadBasicPersonData() throws -> BSANResponse<PersonBasicDataDTO>
    func loadPersonDataList(clientDTOs: [ClientDTO]) throws -> BSANResponse<Void>
    func getPersonData(accountDTO: AccountDTO) throws -> BSANResponse<PersonDataDTO>
}
