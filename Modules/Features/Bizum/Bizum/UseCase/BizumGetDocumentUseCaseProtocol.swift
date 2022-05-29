//
//  BizumGetDocumentUseCaseProtocol.swift
//  Bizum
//
//  Created by José Carlos Estela Anguita on 18/3/21.
//

import CoreFoundationLib
import SANLegacyLibrary

protocol BizumGetDocumentUseCaseProtocol {
    var dependenciesResolver: DependenciesResolver { get }
    func getDocumentWithCheckPayment(_ checkPayment: BizumCheckPaymentEntity) throws -> BizumDocumentEntity?
}

extension BizumGetDocumentUseCaseProtocol {
    
    /// Gets the user document by applying the Chain of Responsibility design pattern.
    /// Firstly, we try to load from Redsys. If the service is not available or it fails, we delegate it to the next handler (LoadPersonBasicData)
    /// - Throws: Service error
    /// - Returns: The BizumDocumentEntity that represents the Document type & code to be used in all Bizum Operatives
    func getDocumentWithCheckPayment(_ checkPayment: BizumCheckPaymentEntity) throws -> BizumDocumentEntity? {
        let loadDocumentByPersonBasicData = LoadDocumentByBasicPersonDataHandler(
            dependenciesResolver: self.dependenciesResolver,
            next: nil
        )
        let loadDocumentsByRedsys = LoadDocumentByRedsysHandler(
            dependenciesResolver: self.dependenciesResolver,
            next: loadDocumentByPersonBasicData,
            checkPayment: checkPayment
        )
        return try loadDocumentsByRedsys.handle()
    }
}

private protocol LoadDocumentHandler {
    var next: LoadDocumentHandler? { get }
    var dependenciesResolver: DependenciesResolver { get }
    func handle() throws -> BizumDocumentEntity?
}

extension LoadDocumentHandler {
    var bsanManagersProvider: BSANManagersProvider {
        return self.dependenciesResolver.resolve()
    }
    var appConfigRepository: AppConfigRepositoryProtocol {
        return self.dependenciesResolver.resolve()
    }
}

private struct LoadDocumentByBasicPersonDataHandler: LoadDocumentHandler {
    
    let dependenciesResolver: DependenciesResolver
    let next: LoadDocumentHandler?
    
    func handle() throws -> BizumDocumentEntity? {
        let response = try self.bsanManagersProvider.getBsanPersonDataManager().loadBasicPersonData()
        guard response.isSuccess() else {
            return nil
        }
        let data = try response.getResponseData()
        return data.map(BizumDocumentEntity.init) ?? nil
    }
}

private struct LoadDocumentByRedsysHandler: LoadDocumentHandler {
    
    let dependenciesResolver: DependenciesResolver
    let next: LoadDocumentHandler?
    let checkPayment: BizumCheckPaymentEntity
 
    func handle() throws -> BizumDocumentEntity? {
        let isGetRedsysDocumentEnabled = self.appConfigRepository.getBool(BizumConstants.isBizumRedsysDocumentIDEnabled) ?? false
        if isGetRedsysDocumentEnabled {
            guard let response = try? self.bsanManagersProvider.getBSANBizumManager().getRedsysUserDocument(input: BizumGetRedsysDocumentInputParams(phoneNumber: self.checkPayment.phone ?? "")), response.isSuccess() else {
                return try self.next?.handle()
            }
            let data = try response.getResponseData()
            return try data.map(BizumDocumentEntity.init) ?? self.next?.handle()
        } else {
            return try self.next?.handle()
        }
    }
}
