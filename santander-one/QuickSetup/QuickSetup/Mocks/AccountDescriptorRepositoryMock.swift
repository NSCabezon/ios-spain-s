//
//  AccountDescriptorRepositoryMock.swift
//  QuickSetup
//
//  Created by José María Jiménez Pérez on 7/6/21.
//

import CoreFoundationLib

public final class AccountDescriptorRepositoryMock: BaseRepository, AccountDescriptorRepositoryProtocol {
    
    public typealias T = AccountDescriptorArrayDTO
    public let datasource: FullDataSource<AccountDescriptorArrayDTO, AccountDescriptorParser>
    
    public init(netClient: NetClient, assetsClient: AssetsClient, fileClient: FileClient) {
        let parameters = BaseDataSourceParameters(relativeURL: "apps/SAN/", fileName: "accountsInfo.xml")
        let parser = AccountDescriptorParser()
        datasource = FullDataSource<AccountDescriptorArrayDTO, AccountDescriptorParser>(netClient: netClient, assetsClient: assetsClient, fileClient: fileClient, parser: parser, parameters: parameters)
    }
    
    public func getAccountDescriptor() -> AccountDescriptorArrayDTO? {
        return self.get()
    }
}
