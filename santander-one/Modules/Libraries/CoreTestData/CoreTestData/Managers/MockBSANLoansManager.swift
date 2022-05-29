import SANLegacyLibrary
import CoreDomain

struct MockBSANLoansManager: BSANLoansManager {
    
    let mockDataInjector: MockDataInjector

    public init(mockDataInjector: MockDataInjector) {
        self.mockDataInjector = mockDataInjector
    }
    
    func getLoanTransactions(forLoan loan: LoanDTO, dateFilter: DateFilter?, pagination: PaginationDTO?) throws -> BSANResponse<LoanTransactionsListDTO> {
        let dto = self.mockDataInjector.mockDataProvider.loansData.getLoanTransactions
        return BSANOkResponse(dto)
    }
    
    func getLoanDetail(forLoan loan: LoanDTO) throws -> BSANResponse<LoanDetailDTO> {
        let dto = self.mockDataInjector.mockDataProvider.loansData.getLoanDetail
        return BSANOkResponse(dto)
    }
    
    func getLoanTransactionDetail(forLoan loan: LoanDTO, loanTransaction: LoanTransactionDTO) throws -> BSANResponse<LoanTransactionDetailDTO> {
        let dto = self.mockDataInjector.mockDataProvider.loansData.getLoanTransactionDetail
        return BSANOkResponse(dto)
    }
    
    func removeLoanDetail(loanDTO: LoanDTO) throws -> BSANResponse<Void> {
        return BSANOkEmptyResponse()
    }
    
    func confirmChangeAccount(loanDTO: LoanDTO, accountDTO: AccountDTO, signatureDTO: SignatureDTO) throws -> BSANResponse<Void> {
        return BSANOkEmptyResponse()
    }
    
    func getLoanPartialAmortization(loanDTO: LoanDTO) throws -> BSANResponse<LoanPartialAmortizationDTO> {
        let dto = self.mockDataInjector.mockDataProvider.loansData.getLoanPartialAmortization
        return BSANOkResponse(dto)
    }
    
    func validatePartialAmortization(loanPartialAmortizationDTO: LoanPartialAmortizationDTO, amount: AmountDTO, amortizationType: PartialAmortizationType) throws -> BSANResponse<LoanValidationDTO> {
        let dto = self.mockDataInjector.mockDataProvider.loansData.validatePartialAmortization
        return BSANOkResponse(dto)
    }
    
    func confirmPartialAmortization(loanPartialAmortizationDTO: LoanPartialAmortizationDTO, amount: AmountDTO, amortizationType: PartialAmortizationType, loanValidationDTO: LoanValidationDTO, signatureDTO: SignatureDTO) throws -> BSANResponse<Void> {
        return BSANOkEmptyResponse()
    }
    
    func changeLoanAlias(_ loan: LoanDTO, newAlias: String) throws -> BSANResponse<Void> {
        return BSANOkEmptyResponse()
    }
}
