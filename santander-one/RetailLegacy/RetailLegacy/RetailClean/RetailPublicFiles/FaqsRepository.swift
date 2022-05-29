import CoreFoundationLib
import Foundation

struct FaqsRepository: BaseRepository {
    
    typealias T = FaqsListDTO
    
    let datasource: FullDataSource<FaqsListDTO, CodableParser<FaqsListDTO>>
    
    init(netClient: NetClient, assetsClient: AssetsClient, fileClient: FileClient) {
        let parameters = BaseDataSourceParameters(relativeURL: "/apps/SAN/", fileName: "faqs.json")
        let parser = CodableParser<FaqsListDTO>()
        datasource = FullDataSource<FaqsListDTO, CodableParser<FaqsListDTO>>(netClient: netClient,
                                                                             assetsClient: assetsClient,
                                                                             fileClient: fileClient,
                                                                             parser: parser,
                                                                             parameters: parameters)
    }
}

extension FaqsRepository: FaqsRepositoryProtocol {
    func getFaqsList() -> FaqsListDTO? {
        return get()
    }

    func getFaqsList(_ type: FaqsType) -> [FaqDTO] {
        switch type {
        case .billPaymentOperative:
            return get()?.billPaymentOperative ?? []
        case .bizumHome:
            return get()?.bizumHome ?? []
        case .emittersPaymentOperative:
            return get()?.emittersPaymentOperative ?? []
        case .generic:
            return get()?.generic ?? []
        case .globalSearch:
            return get()?.globalSearch ?? []
        case .helpCenter:
            return get()?.helpCenter ?? []
        case .internalTransferOperative:
            return get()?.internalTrasnferOperative ?? []
        case .nextSettlementCreditCard:
            return get()?.nextSettlementCreditCard ?? []
        case .transferOperative:
            return get()?.transferOperative ?? []
        case .transfersHome:
            return get()?.transfersHome ?? []
        case .santanderKey:
            return get()?.santanderKey ?? []
        }
    }
}
