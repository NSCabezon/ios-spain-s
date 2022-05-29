import SANLegacyLibrary
import CoreFoundationLib
import Foundation

class DownloadPdfBillUseCase: UseCase<DownloadPdfBillUseCaseInput, DownloadPdfBillUseCaseOkOutput, StringErrorOutput> {
    
    private let provider: BSANManagersProvider
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    
    override func executeUseCase(requestValues: DownloadPdfBillUseCaseInput) throws -> UseCaseResponse<DownloadPdfBillUseCaseOkOutput, StringErrorOutput> {
        let bill = requestValues.bill
        let ibanDTO = IBANDTO(ibanString: bill.linkedAccount)
       
        let accountResponse = try getLinkedAccount(provider: provider, ibanDTO: ibanDTO)
        
        guard accountResponse.isSuccess(), let accountDTO = try accountResponse.getResponseData() else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        
        var enableBillAndTaxesRemedy: Bool {
            let appConfigRepository = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
            return appConfigRepository.getBool(BillsConstants.enableBillAndTaxesRemedy) ?? false
        }
        
        let responsePdf = try provider
            .getBsanBillTaxesManager()
            .downloadPdfBill(account: accountDTO,
                             bill: bill.billDTO,
                             enableBillAndTaxesRemedy: enableBillAndTaxesRemedy)
        
        guard responsePdf.isSuccess(),
              let documentDTO = try responsePdf.getResponseData(),
              let document = DocumentDO(dto: documentDTO).document
        else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        
        guard let documentData = convert(base64Document: document) else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        
        return UseCaseResponse.ok(DownloadPdfBillUseCaseOkOutput(document: documentData))
    }
}

struct DownloadPdfBillUseCaseInput {
    let bill: Bill
}

struct DownloadPdfBillUseCaseOkOutput {
    let document: Data
}

extension DownloadPdfBillUseCase: Base64PDFDocumentConverter {}
extension DownloadPdfBillUseCase: AssociatedAccountRetriever {}
