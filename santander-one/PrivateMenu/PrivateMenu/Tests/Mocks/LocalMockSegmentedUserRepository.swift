import CoreFoundationLib
import OpenCombine
import CoreDomain

@testable import PrivateMenu

//TODO: Este es un local que se ha creado, cambiar por el original MockSegmentedUserRepository cuando esté disponible con todas las variables que necesita.
struct LocalMockSegmentedUserRepository: SegmentedUserRepository {
    let isSmart: Bool? = false
    func getSegmentedUser() -> SegmentedUserDTO? {
        nil
    }
    
    func getSegmentedUserSpb() -> [SegmentedUserTypeDTO]? {
        nil
    }
    
    func getSegmentedUserGeneric() -> [SegmentedUserTypeDTO]? {
        nil
    }
    
    func getCommercialSegment() -> AnyPublisher<CommercialSegmentRepresentable?, Never> {
        Empty().eraseToAnyPublisher()
    }
    
    func remove() {
        
    }
    
    func load(withBaseUrl url: String) {
        
    }
    
    func load(baseUrl: String, publicLanguage: PublicLanguage) {
        
    }
}
