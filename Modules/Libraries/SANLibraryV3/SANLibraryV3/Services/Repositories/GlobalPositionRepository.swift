import SANServicesLibrary
import CoreFoundationLib
import SANLegacyLibrary
import SANSpainLibrary
import OpenCombine
import CoreDomain

struct GlobalPositionNetworkRepository {
    let bsanPGManager: BSANPGManager
    let storage: Storage
    
    init(storage: Storage, bsanPGManager: BSANPGManager) {
        self.storage = storage
        self.bsanPGManager = bsanPGManager
    }
}

extension GlobalPositionNetworkRepository: SpainGlobalPositionRepository {
    func loadGlobalPositionV2(onlyVisibleProducts: Bool, isPB: Bool) -> AnyPublisher<GlobalPositionDataRepresentable, Error> {
        return Future { promise in
            do {
                let response = try bsanPGManager.loadGlobalPositionV2(
                    onlyVisibleProducts: onlyVisibleProducts,
                    isPB: isPB
                )
                let convertedResponse: Result<GlobalPositionDataRepresentable, Error> = try BSANResponseConverter.convert(response: response)
                promise(convertedResponse)
            } catch let error {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
}
