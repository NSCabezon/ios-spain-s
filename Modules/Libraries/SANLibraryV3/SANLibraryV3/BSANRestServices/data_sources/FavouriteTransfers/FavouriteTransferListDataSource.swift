import Foundation
import SANLegacyLibrary

class FavouriteTransferListDataSource: FavouriteTransferListDataSourceProtocol {
    let sanRestServices: SanRestServices
    private let serviceName = "favoritas"
    private let basePath = "/api/v1/transferencias/"
    private let bsanDataProvider: BSANDataProvider

    init(sanRestServices: SanRestServices, bsanDataProvider: BSANDataProvider) {
        self.sanRestServices = sanRestServices
        self.bsanDataProvider = bsanDataProvider
    }
    
    func loadFavouriteTransferList() throws -> BSANResponse<[PayeeDTO]> {
        let bsanEnvironment: BSANEnvironmentDTO = try self.bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.microURL else {
            return BSANErrorResponse(nil)
        }
        let url = source + self.basePath + self.serviceName
        let response = try deserializeResponse(url)
        guard let transfers = try response.getResponseData()?.favouriteTransfers.compactMap({ self.convertInPayeeDTO($0) }) else {
            return BSANErrorResponse(Meta.createKO())
        }
        return BSANOkResponse(transfers)
    }
}

private extension FavouriteTransferListDataSource {
    func deserializeResponse(_ url: String) throws -> BSANResponse<FavouriteTransferListDTO> {
        return try self.executeRestCallWithoutParams(
            serviceName: serviceName,
            serviceUrl: url,
            contentType: .queryString,
            requestType: .get,
            headers:  ["X-Santander-Channel": "RML", "Content-Type": "application/json"],
            responseEncoding: .utf8)
    }
    
    func convertInPayeeDTO(_ fav: FavouriteTransferDTO) -> PayeeDTO {
        let decimalAmount = Decimal(fav.amount ?? 0.0)
        let currencyType = CurrencyType(fav.currency ?? "") ?? SharedCurrencyType.default
        let currencyDTO = CurrencyDTO(currencyName: fav.currency ?? "", currencyType: currencyType)
        var payeeDTO = PayeeDTO()
        payeeDTO.beneficiary = fav.alias
        payeeDTO.transferAmount = AmountDTO(value: decimalAmount, currency: currencyDTO)
        payeeDTO.codPayee = fav.beneficiaryCode
        payeeDTO.iban = IBANDTO(ibanString: fav.destinationAccount ?? "")
        payeeDTO.beneficiaryBAOName = fav.beneficiaryName ?? ""
        payeeDTO.actingTypeCode = fav.actingType ?? ""
        payeeDTO.actingNumber = fav.actingCode ?? ""
        payeeDTO.accountType = fav.accountType ?? ""
        payeeDTO.destinationAccount = fav.accountType?.uppercased() == "C" ? fav.bicBeneficiary ?? "" : fav.destinationAccount ?? ""
        payeeDTO.recipientType = fav.destinationType ?? ""
        return payeeDTO
    }
}

