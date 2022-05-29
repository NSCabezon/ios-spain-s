//
//  TipsRepository.swift
//  RetailClean
//
//  Created by Luis Escámez Sánchez on 30/01/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//

import Foundation
import CoreFoundationLib

struct LoadingTipsRepository: BaseRepository {
    
    typealias T = LoadingTipsListDTO
    
    let datasource: FullDataSource<LoadingTipsListDTO, CodableParser<LoadingTipsListDTO>>
    
    init(netClient: NetClient, assetClient: AssetsClient, fileClient: FileClient) {
        let parameters = BaseDataSourceParameters(relativeURL: "/apps/SAN/", fileName: "loadingTips.json")
        let parser = CodableParser<LoadingTipsListDTO>()
        datasource = FullDataSource<LoadingTipsListDTO, CodableParser<LoadingTipsListDTO>>(netClient: netClient, assetsClient: assetClient, fileClient: fileClient, parser: parser, parameters: parameters)
    }
}

extension LoadingTipsRepository: LoadingTipsRepositoryProtocol {
    
    func getLoadingTips() -> LoadingTipsListDTO? {
        return self.get()
    }
}
