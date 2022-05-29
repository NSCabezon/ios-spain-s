import Foundation
import CoreFoundationLib

class PDFViewerPresenter: PrivatePresenter<PDFViewerViewController, VoidNavigator, PDFViewerPresenterProtocol> {
    
    let documentData: Data
    let title: LocalizedStylableText?
    let pdfSource: PdfSource
    
    init(pdf: Data, pdfSource: PdfSource, title: String, dependencies: PresentationComponent, sessionManager: CoreSessionManager, navigator: VoidNavigator) {
        self.documentData = pdf
        self.pdfSource = pdfSource
        self.title = dependencies.stringLoader.getString(title)
        super.init(dependencies: dependencies, sessionManager: sessionManager, navigator: navigator)
        self.barButtons = [.share]
    }
    
    override func loadViewData() {
        super.loadViewData()
        
    }
    
    func shareButtonPressed() {
        let caseInput = GetTempPdfUseCaseInput(data: documentData, newFilename: shareFilename)
        let useCase = dependencies.useCaseProvider.getTempPdfUseCase(input: caseInput)
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] response in
            self?.view.showActivity(with: [response.pdfDocument])
        })
    }
}

extension PDFViewerPresenter: PDFViewerPresenterProtocol {
    
    var pdfDocument: DocumentPDF? {
        let pdfDocumet = DocumentPDF(fileData: documentData)
        return pdfDocumet
    }
    
    var pdfData: Data {
        return documentData
    }
    
    var shareFilename: String {
        let filenameByDefault: String = "File.pdf"
        switch pdfSource {
        case .chatInbenta:
            return createPDFFileName(for: "agentChat_label_exportPdf")
        case .accountTransactionDetail:
            return createPDFFileName(for: "accountTrasactionDetail_title_pdf")
        case .cardPDFExtract, .cardTransactionsDetail:
            return createPDFFileName(for: "cardStatement_title_pdf")
        case .bizum:
            return createPDFFileName(for: "bizum_label_bizumPdf")
        case .unknown:
            return filenameByDefault
        case .nosepa:
            return createPDFFileName(for: "feesRates_title_pdf")
        case .summary:
            return filenameByDefault
        case .accountHome:
            return filenameByDefault
        case .transferSummary:
            return createPDFFileName(for: "transferDetail_title_pdf")
        case .bill:
            return createPDFFileName(for: "billDetail_title_pdf")
        case .sanflix:
            //TODO: To change to final URL Sanflix
            return createPDFFileName(for: "***SanflixPDF")
        case .partialAmortization(let loanNumber):
            return createPDFFileName(for: "partialAmortization_title_pdf", with: loanNumber.replacingOccurrences(of: "-", with: ""))
        }
    }
}

private extension PDFViewerPresenter {
    private func createPDFFileName(for key: String, with value: String = "") -> String {
        let date = dependencies.timeManager.toString(date: Date(), outputFormat: TimeFormat.dd_MM_yyyy_HH_mm, timeZone: .local) ?? ""
        let stringPlaceholders = [StringPlaceholder(.date, date), StringPlaceholder(.value, value)]
        let fileName: LocalizedStylableText = stringLoader.getString(key, stringPlaceholders)
        return fileName.text
    }
}
