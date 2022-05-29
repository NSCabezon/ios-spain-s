import CoreDomain

public protocol BSANFundsManager {
    func getFundTransactions(forFund fund: FundDTO, dateFilter: DateFilter?, pagination: PaginationDTO?) throws -> BSANResponse<FundTransactionsListDTO>
    func getFundDetail(forFund fundDTO : FundDTO) throws -> BSANResponse<FundDetailDTO>
    func getFundTransactionDetail(forFund fundDTO : FundDTO, fundTransactionDTO : FundTransactionDTO) throws -> BSANResponse<FundTransactionDetailDTO>
    func validateFundSubscriptionAmount(fundDTO: FundDTO, amountDTO: AmountDTO) throws -> BSANResponse<FundSubscriptionDTO>
    func validateFundSubscriptionShares(fundDTO: FundDTO, sharesNumber: Decimal) throws -> BSANResponse<FundSubscriptionDTO>
    func confirmFundSubscriptionAmount(fundDTO: FundDTO, amountDTO: AmountDTO, fundSubscriptionDTO: FundSubscriptionDTO, signatureDTO: SignatureDTO) throws -> BSANResponse<FundSubscriptionConfirmDTO>
    func confirmFundSubscriptionShares(fundDTO: FundDTO, sharesNumber: Decimal, fundSubscriptionDTO: FundSubscriptionDTO, signatureDTO: SignatureDTO) throws -> BSANResponse<FundSubscriptionConfirmDTO>
    func validateFundTransferTotal(originFundDTO: FundDTO, destinationFundDTO: FundDTO) throws -> BSANResponse<FundTransferDTO>
    func validateFundTransferPartialByAmount(originFundDTO: FundDTO, destinationFundDTO: FundDTO, amountDTO: AmountDTO) throws -> BSANResponse<FundTransferDTO>
    func validateFundTransferPartialByShares(originFundDTO: FundDTO, destinationFundDTO: FundDTO, sharesNumber: Decimal) throws -> BSANResponse<FundTransferDTO>
    func confirmFundTransferTotal(originFundDTO: FundDTO, destinationFundDTO: FundDTO, fundTransferDTO: FundTransferDTO, signatureDTO: SignatureDTO) throws -> BSANResponse<Void>
    func confirmFundTransferPartialByAmount(originFundDTO: FundDTO, destinationFundDTO: FundDTO, fundTransferDTO: FundTransferDTO, amountDTO: AmountDTO, signatureDTO: SignatureDTO) throws -> BSANResponse<Void>
    func confirmFundTransferPartialByShares(originFundDTO: FundDTO, destinationFundDTO: FundDTO, fundTransferDTO: FundTransferDTO, signatureDTO: SignatureDTO) throws -> BSANResponse<Void>
    func changeFundAlias(_ fund: FundDTO, newAlias: String) throws -> BSANResponse<Void>
}
