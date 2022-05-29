import SANLegacyLibrary
import CoreDomain

struct MockBSANFundsManager: BSANFundsManager {
    func getFundTransactions(forFund fund: FundDTO, dateFilter: DateFilter?, pagination: PaginationDTO?) throws -> BSANResponse<FundTransactionsListDTO> {
        fatalError()
    }
    
    func getFundDetail(forFund fundDTO: FundDTO) throws -> BSANResponse<FundDetailDTO> {
        fatalError()
    }
    
    func getFundTransactionDetail(forFund fundDTO: FundDTO, fundTransactionDTO: FundTransactionDTO) throws -> BSANResponse<FundTransactionDetailDTO> {
        fatalError()
    }
    
    func validateFundSubscriptionAmount(fundDTO: FundDTO, amountDTO: AmountDTO) throws -> BSANResponse<FundSubscriptionDTO> {
        fatalError()
    }
    
    func validateFundSubscriptionShares(fundDTO: FundDTO, sharesNumber: Decimal) throws -> BSANResponse<FundSubscriptionDTO> {
        fatalError()
    }
    
    func confirmFundSubscriptionAmount(fundDTO: FundDTO, amountDTO: AmountDTO, fundSubscriptionDTO: FundSubscriptionDTO, signatureDTO: SignatureDTO) throws -> BSANResponse<FundSubscriptionConfirmDTO> {
        fatalError()
    }
    
    func confirmFundSubscriptionShares(fundDTO: FundDTO, sharesNumber: Decimal, fundSubscriptionDTO: FundSubscriptionDTO, signatureDTO: SignatureDTO) throws -> BSANResponse<FundSubscriptionConfirmDTO> {
        fatalError()
    }
    
    func validateFundTransferTotal(originFundDTO: FundDTO, destinationFundDTO: FundDTO) throws -> BSANResponse<FundTransferDTO> {
        fatalError()
    }
    
    func validateFundTransferPartialByAmount(originFundDTO: FundDTO, destinationFundDTO: FundDTO, amountDTO: AmountDTO) throws -> BSANResponse<FundTransferDTO> {
        fatalError()
    }
    
    func validateFundTransferPartialByShares(originFundDTO: FundDTO, destinationFundDTO: FundDTO, sharesNumber: Decimal) throws -> BSANResponse<FundTransferDTO> {
        fatalError()
    }
    
    func confirmFundTransferTotal(originFundDTO: FundDTO, destinationFundDTO: FundDTO, fundTransferDTO: FundTransferDTO, signatureDTO: SignatureDTO) throws -> BSANResponse<Void> {
        fatalError()
    }
    
    func confirmFundTransferPartialByAmount(originFundDTO: FundDTO, destinationFundDTO: FundDTO, fundTransferDTO: FundTransferDTO, amountDTO: AmountDTO, signatureDTO: SignatureDTO) throws -> BSANResponse<Void> {
        fatalError()
    }
    
    func confirmFundTransferPartialByShares(originFundDTO: FundDTO, destinationFundDTO: FundDTO, fundTransferDTO: FundTransferDTO, signatureDTO: SignatureDTO) throws -> BSANResponse<Void> {
        fatalError()
    }
    
    func changeFundAlias(_ fund: FundDTO, newAlias: String) throws -> BSANResponse<Void> {
        fatalError()
    }
}
