import SANLegacyLibrary
import CoreFoundationLib
import Foundation

class GetCardPdfTransactionUseCase: UseCase<GetCardPdfTransactionUseCaseInput, GetCardPdfTransactionUseCaseOkOutput, GetCardPdfTransactionUseCaseErrorOutput> {

    private let dependenciesResolver: DependenciesResolver
    private let provider: BSANManagersProvider
    private let accountDescriptorRepository: AccountDescriptorRepositoryProtocol

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.accountDescriptorRepository = dependenciesResolver.resolve(for: AccountDescriptorRepositoryProtocol.self)
        self.provider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    
    override func executeUseCase(requestValues: GetCardPdfTransactionUseCaseInput) throws -> UseCaseResponse<GetCardPdfTransactionUseCaseOkOutput, GetCardPdfTransactionUseCaseErrorOutput> {
        let cardDto = requestValues.card.cardDTO
        let dateFilterDTO = requestValues.dateFilter.dto
        let iconCards = (self.accountDescriptorRepository.getAccountDescriptor()?.iberiaIconCardsArray ?? [])
        let type = requestValues.card.getProductType()
        let subType = requestValues.card.getProductSubtype()
        let isIberiaIcon = !iconCards.filter({$0.type == type && $0.subType == subType}).isEmpty
        let response = try provider.getBsanCardsManager().checkCardExtractPdf(cardDTO: cardDto, dateFilter: dateFilterDTO, isPCAS: isIberiaIcon)
        if response.isSuccess(), let documentDTO = try response.getResponseData() {
            guard let document = DocumentDO(dto: documentDTO).document else {
                return UseCaseResponse.error(GetCardPdfTransactionUseCaseErrorOutput(nil, errorType: .common))
            }
            
            guard let documentData = convert(base64Document: document) else {
                return UseCaseResponse.error(GetCardPdfTransactionUseCaseErrorOutput(nil, errorType: .common))
            }
            return UseCaseResponse.ok(GetCardPdfTransactionUseCaseOkOutput(document: documentData))
        } else {
            let error = GetCardPdfTransactionUseCaseErrorOutput(try response.getErrorMessage(),
                                                                errorType: GetCardPdfTransactionUseCaseErrorType.typeFrom(code: try response.getErrorCode()))
            return UseCaseResponse.error(error)
        }
    }
}

extension GetCardPdfTransactionUseCase: Base64PDFDocumentConverter {}

struct GetCardPdfTransactionUseCaseInput {
    let dateFilter: DateFilterDO
    let card: Card
}

struct GetCardPdfTransactionUseCaseOkOutput {
    let document: Data
}

enum GetCardPdfTransactionUseCaseErrorType {
    case common
    case extractNotAvailable
    
    static func typeFrom(code: String?) -> GetCardPdfTransactionUseCaseErrorType {
        if code == "SCCCOR_02" {
            return .extractNotAvailable
        }
        return .common
    }
}

class GetCardPdfTransactionUseCaseErrorOutput: StringErrorOutput {
    let errorType: GetCardPdfTransactionUseCaseErrorType
    
    init(_ errorDesc: String?, errorType: GetCardPdfTransactionUseCaseErrorType) {
        self.errorType = errorType
        super.init(errorDesc)
    }
}
