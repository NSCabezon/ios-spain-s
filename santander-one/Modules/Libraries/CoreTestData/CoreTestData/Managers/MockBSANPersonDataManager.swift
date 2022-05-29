import SANLegacyLibrary

struct MockBSANPersonDataManager: BSANPersonDataManager {
    
    let mockDataInjector: MockDataInjector

    public init(mockDataInjector: MockDataInjector) {
        self.mockDataInjector = mockDataInjector
    }
    
    func loadBasicPersonData() throws -> BSANResponse<PersonBasicDataDTO> {
        let dto = self.mockDataInjector.mockDataProvider.personalAreaData.getPersonBasicDataMock
        return BSANOkResponse(dto)
    }
    
    func loadPersonDataList(clientDTOs: [ClientDTO]) throws -> BSANResponse<Void> {
        fatalError()
    }
    
    func getPersonData(accountDTO: AccountDTO) throws -> BSANResponse<PersonDataDTO> {
        fatalError()
    }
}
