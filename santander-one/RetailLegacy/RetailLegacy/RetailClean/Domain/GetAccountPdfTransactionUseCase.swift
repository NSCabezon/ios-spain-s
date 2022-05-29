import SANLegacyLibrary
import CoreFoundationLib
import Foundation

class GetAccountPdfTransactionUseCase: UseCase<GetAccountPdfTransactionUseCaseInput, GetAccountPDFTransactionUseCaseOkOutput, StringErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: GetAccountPdfTransactionUseCaseInput) throws -> UseCaseResponse<GetAccountPDFTransactionUseCaseOkOutput, StringErrorOutput> {
        
        let accountDTO = requestValues.account.accountDTO
        let transactionDTO = requestValues.transaction.dto
        
        let response = try provider.getBsanAccountsManager().checkAccountMovementPdf(accountDTO: accountDTO, accountTransactionDTO: transactionDTO)
        guard response.isSuccess() else {
            return .error(StringErrorOutput(try response.getErrorMessage()))
        }
        
        let documentDTO = try checkRepositoryResponse(response)
        guard let document = DocumentDO(dto: documentDTO).document else {
            return .error(StringErrorOutput(nil))
        }
        
        guard let documentData = convert(base64Document: document) else {
            return .error(StringErrorOutput(nil))
        }
    
        return .ok(GetAccountPDFTransactionUseCaseOkOutput(document: documentData))
    }
}

extension GetAccountPdfTransactionUseCase: Base64PDFDocumentConverter {}

struct GetAccountPdfTransactionUseCaseInput {
    let account: Account
    let transaction: AccountTransaction
}

struct GetAccountPDFTransactionUseCaseOkOutput {
    let document: Data
}

protocol Base64PDFDocumentConverter {
    func convert(base64Document document: String) -> Data?
}

extension Base64PDFDocumentConverter {
    func convert(base64Document document: String) -> Data? {
        return Data(base64Encoded: document)
    }
}
