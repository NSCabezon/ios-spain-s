import SANLegacyLibrary

struct MockBSANUserSegmentManager: BSANUserSegmentManager {
    
    let mockInjector: MockDataInjector
    
    func getUserSegment() throws -> BSANResponse<UserSegmentDTO> {
        return BSANOkResponse(mockInjector.mockDataProvider.userSegment.segment)
    }
    
    func loadUserSegment() throws -> BSANResponse<UserSegmentDTO> {
        fatalError()
    }
    
    func saveIsSelectUSer(_ isSelect: Bool) {
        
    }
    
    func isSelectUser() throws -> Bool {
        fatalError()
    }
    
    func saveIsSmartUser(_ isSmart: Bool) {
        
    }
    
    func isSmartUser() throws -> Bool {
        fatalError()
    }
}
