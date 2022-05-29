import CoreFoundationLib
import SANLegacyLibrary
import Foundation

typealias PdfMonths = [String]

class GetPdfExtractMonthNumberUseCase: UseCase<GetPdfExtractMonthNumberUseCaseInput, GetPdfExtractMonthNumberUseCaseOkOutput, StringErrorOutput> {
    private let provider: BSANManagersProvider
    
    init(managersProvider: BSANManagersProvider) {
        self.provider = managersProvider
    }
    
    override func executeUseCase(requestValues: GetPdfExtractMonthNumberUseCaseInput) throws -> UseCaseResponse<GetPdfExtractMonthNumberUseCaseOkOutput, StringErrorOutput> {
        
        guard let months = extractMonths(withConfiguration: requestValues.configuration) else {
            return UseCaseResponse.error(StringErrorOutput(""))
        }
        
        return UseCaseResponse.ok(GetPdfExtractMonthNumberUseCaseOkOutput(months: months))
    }
    
    private func extractMonths(withConfiguration config: PdfMonthConfiguration) -> PdfMonths? {
        
        var months = [String]()
        for i in 0..<config.numberOfMonths {
            guard let month = Date.getPreviousMonth(i) else { return nil }
            guard let m = config.localeManager.toString(date: month, outputFormat: .MMMM_YYYY) else { return nil }
            months.append(m)
        }
        
        return months
    }
    
}

struct GetPdfExtractMonthNumberUseCaseInput {
    let configuration: PdfMonthConfiguration
}

struct GetPdfExtractMonthNumberUseCaseOkOutput {
    let months: PdfMonths
}

struct PdfMonthConfiguration {
    let numberOfMonths: Int
    let localeManager: TimeManager
}
