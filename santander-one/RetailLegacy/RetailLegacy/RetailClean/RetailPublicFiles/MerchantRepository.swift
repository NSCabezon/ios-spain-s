//
//  MerchantRepository.swift
//  RetailLegacy
//
//  Created by César González Palomino on 04/03/2021.
//

import Foundation
import CoreFoundationLib

struct MerchantRepository: BaseRepository {
    
    typealias T = MerchantListDTO
    
    let datasource: FullDataSource<MerchantListDTO, CodableParser<MerchantListDTO>>
    
    init(netClient: NetClient, assetClient: AssetsClient, fileClient: FileClient) {
        let parameters = BaseDataSourceParameters(relativeURL: "/apps/SAN/", fileName: "merchant.json")
        let parser = CodableParser<MerchantListDTO>()
        datasource = FullDataSource<MerchantListDTO, CodableParser<MerchantListDTO>>(
            netClient: netClient,
            assetsClient: assetClient,
            fileClient: fileClient,
            parser: parser,
            parameters: parameters)
    }
}

extension MerchantRepository: MerchantRepositoryProtocol {
    
    func getMerchantList() -> MerchantListDTO? {
        return self.get()
    }
}
