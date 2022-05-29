//
//  TransferListDataSource.swift
//  SANLibraryV3
//
//  Created by Francisco del Real Escudero on 18/1/22.
//

import SANServicesLibrary
import CoreFoundationLib
import SANSpainLibrary
import CoreDomain

protocol TransferListDataSourceProtocol {
    func loadEmittedTransfers(
        account: AccountRepresentable,
        amountFrom: AmountRepresentable?,
        amountTo: AmountRepresentable?,
        dateFilter: DateFilter,
        pagination: PaginationRepresentable?
    ) -> Result<TransferListResponse, Error>
    
    func getAccountTransactions(
        account: AccountRepresentable,
        pagination: PaginationRepresentable?,
        filter: AccountTransferFilterInput
    ) -> Result<TransferListResponse, Error>
}

struct TransferListDataSource {
    let configurationRepository: ConfigurationRepository
    let environmentProvider: EnvironmentProvider
    let networkManager: NetworkClientManager
    let storage: Storage
}

extension TransferListDataSource: TransferListDataSourceProtocol{
    func loadEmittedTransfers(
        account: AccountRepresentable,
        amountFrom: AmountRepresentable?,
        amountTo: AmountRepresentable?,
        dateFilter: DateFilter,
        pagination: PaginationRepresentable?
    ) -> Result<TransferListResponse, Error> {
        guard case let userRepresentable?? = storage.get(UserDataRepresentable?.self),
              let sessionData: SessionData = storage.get(),
              let authToken: AuthenticationTokenDto = storage.get(),
              let newGlobalPosition: GlobalPositionDTO = storage.get(id: "GlobalPositionV2")
        else { return .failure(RepositoryError.unknown) }
        let requestAccount: AccountRepresentable = newGlobalPosition.accounts?.first(where: {
            guard let lhs = $0.ibanRepresentable,
                  let rhs = account.ibanRepresentable
            else { return false }
            return lhs.equalsTo(other: rhs)
        }) ?? account
        guard let contract = requestAccount.contractRepresentable else { return .failure(RepositoryError.unknown) }
        if let transferListDict: [String: TransferListResponse] = storage.get(id: "TransferEmittedList"),
           let transferEmittedListDTO = transferListDict[contract.fullContract],
           transferEmittedListDTO.pagination == nil {
            return .success(transferEmittedListDTO)
        }
        let nameSpace = "http://www.isban.es/webservices/TRASAN/Consultas_transf_la/F_trasan_consultas_transf_la/"
        let facade = "ACTRASANConsultasTransfLa"
        let request = SoapSpainRequest(
            method: "POST",
            serviceName: "listaEmitidasLa",
            url: environmentProvider.getEnvironment().soapBaseUrl + "/TRASAN_CONSULTAS_TRANSF_ENS/ws/BAMOBI_WS_Def_Listener",
            input: GetEmittedTransfersSoapRequest(
                pagination: pagination as? PaginationDTO,
                amountFrom: amountFrom,
                amountTo: amountTo,
                dateFilter: dateFilter
            )
        )
        let userDataTypes: [ConnectionDataRequestInterceptor.UserDataType] = [
            .withChannelAndCompanyAndCustomContract(userData: userRepresentable, contract: contract)
        ]
        let response = try? self.networkManager.request(
            request,
            requestInterceptors: [
                ConnectionDataRequestInterceptor(isPB: sessionData.isPB, userDataTypes: userDataTypes, specialLanguageServiceNames: self.configurationRepository[\.specialLanguageServiceNames] ?? []),
                BodySoapInterceptor(type: .soapenv, version: .v1, nameSpace: nameSpace, facade: facade),
                AuthorizationSoapInterceptor(token: authToken.token),
                EnvelopeSoapInterceptor(type: .soapenv, nameSpace: nameSpace, facade: facade)
            ],
            responseInterceptors: [
                SoapErrorInterceptor(errorKey: "codigoError", descriptionKey: "descripcionError")
            ]
        )
        let output = response?.flatMap(toXMLDecodable: TransferEmittedListDTO.self)
        let result: Result<TransferListResponse, Error>
        switch output {
        case .success(let dto):
            var dict: [String: TransferListResponse] = [:]
            var transactions: [TransferRepresentable] = dto.transactionDTOs
            let pagination: PaginationRepresentable? = dto.paginationDTO.endList ? nil: dto.paginationDTO
            result = .success(TransferListResponse(
                transactions: transactions,
                pagination: pagination
            ))
            if let transferListDict: [String: TransferListResponse] = storage.get(id: "TransferEmittedList") {
                dict = transferListDict
                if let transferEmittedListDTO = transferListDict[contract.fullContract] {
                    transactions = transferEmittedListDTO.transactions + transactions
                }
            }
            dict[contract.fullContract] = TransferListResponse(
                transactions: transactions,
                pagination: pagination
            )
            storage.store(dict, id: "TransferEmittedList")
        case .failure(let error):
            result = .failure(error)
        case nil:
            result = .failure(RepositoryError.unknown)
        }
        return result
    }
    
    func getAccountTransactions(
        account: AccountRepresentable,
        pagination: PaginationRepresentable?,
        filter: AccountTransferFilterInput
    ) -> Result<TransferListResponse, Error> {
        guard case let userRepresentable?? = storage.get(UserDataRepresentable?.self),
              let sessionData: SessionData = storage.get(),
              let authToken: AuthenticationTokenDto = storage.get(),
              let account = account as? AccountDTO,
              let oldContract = account.oldContract,
              case let appInfo?? = configurationRepository[\.appInfo]
        else { return .failure(RepositoryError.unknown) }
        guard let contract = account.contractRepresentable else { return .failure(RepositoryError.unknown) }
        let accountIdentifier = contract.formattedValue + filter.string
        if let transferListDict: [String: TransferListResponse] = storage.get(id: "TransferReceivedList"),
           let transferReceivedListDTO = transferListDict[contract.fullContract],
           transferReceivedListDTO.pagination == nil {
            return .success(transferReceivedListDTO)
        }
        let nameSpace = "http://www.isban.es/webservices/BAMOBI/Cuentas/F_bamobi_cuentas_lip/internet/"
        let facade = "BAMOBICTA"
        let serviceName = filter.dateFilter == nil ? "listaMovCuentas_LIP": "listaMovCuentasFechas_LIP"
        let request = SoapSpainRequest(
            method: "POST",
            serviceName: serviceName,
            url: environmentProvider.getEnvironment().soapBaseUrl + "/SCH_BAMOBI_WS_ENS/ws/BAMOBI_WS_Def_Listener",
            input: GetAccountTransactionsSoapRequest(
                filter: filter,
                contract: oldContract,
                pagination: pagination as? PaginationDTO
            )
        )
        let userDataTypes: [ConnectionDataRequestInterceptor.UserDataType] = [
            .withMarcoChannelAndCompanyAndMultiContract(userData: userRepresentable)
        ]
        let specialLanguageServiceNames = configurationRepository[\.specialLanguageServiceNames] ?? []
        let response = try? self.networkManager.request(
            request,
            requestInterceptors: [
                HeaderDataRequestInterceptor(
                    isPB: sessionData.isPB,
                    specialLanguageServiceNames: specialLanguageServiceNames,
                    version: appInfo
                ),
                ConnectionDataRequestInterceptor(
                    isPB: sessionData.isPB,
                    userDataTypes: userDataTypes,
                    specialLanguageServiceNames: specialLanguageServiceNames
                ),
                BodySoapInterceptor(
                    type: .soapenv,
                    version: .v1,
                    nameSpace: nameSpace,
                    facade: facade
                ),
                AuthorizationSoapInterceptor(token: authToken.token),
                EnvelopeSoapInterceptor(type: .soapenv, nameSpace: nameSpace, facade: facade)
            ],
            responseInterceptors: [
                SoapErrorInterceptor(errorKey: "codigoError", descriptionKey: "descripcionError")
            ]
        )
        let output = response?.flatMap(toXMLDecodable: AccountTransactionsListDTO.self)
        let result: Result<TransferListResponse, Error>
        switch output {
        case .success(let dto):
            var dict: [String: TransferListResponse] = [:]
            var transactions: [TransferRepresentable] = dto.transactionDTOs
            let pagination: PaginationRepresentable? = dto.pagination.endList ? nil: dto.pagination
            result = .success(TransferListResponse(
                transactions: transactions,
                pagination: pagination
            ))
            if let transferListDict: [String: TransferListResponse] = storage.get(id: "TransferReceivedList") {
                dict = transferListDict
                if let transferReceivedListDTO = transferListDict[contract.fullContract] {
                    transactions = transferReceivedListDTO.transactions + transactions
                }
            }
            dict[contract.fullContract] = TransferListResponse(
                transactions: transactions,
                pagination: pagination
            )
            storage.store(dict, id: "TransferReceivedList")
        case .failure(let error):
            result = .failure(error)
        case nil:
            result = .failure(RepositoryError.unknown)
        }
        return result
    }
}
