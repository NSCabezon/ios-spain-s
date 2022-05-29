import Foundation

protocol TransferSubTypeCommissionDataSourceProtocol: RestDataSource {
    func loadTransferTypeComissions(params: TransferSubTypeComissionRequestParams) throws -> BSANResponse<TransferSubTypeCommissionDTO>
}
