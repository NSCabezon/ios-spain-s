import Foundation
import CoreFoundationLib

protocol CardPdfLauncher: class, CardOptionLauncherType {
    var operativePresentationDelegate: OperativeLauncherPresentationDelegate? { get }
    func pdf(forCard card: Card, month: String)
    func didCancelMonthSelection()
}

extension CardPdfLauncher {
    func dateForPdf(product: Card) {
        let configuration: PdfMonthConfiguration = PdfMonthConfiguration(numberOfMonths: 12, localeManager: dependencies.timeManager)
        let input: GetPdfExtractMonthNumberUseCaseInput = GetPdfExtractMonthNumberUseCaseInput(configuration: configuration)
        let useCase = dependencies.useCaseProvider.getPdfExtractMonthNumberUseCase(input: input)
        
        UseCaseWrapper(with: useCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: errorHandler, onSuccess: { [weak self] response in
            guard let self = self else { return }
            let placeholder: StringPlaceholder = StringPlaceholder(.name, product.getAlias())
            self.dependencies.navigatorProvider.productHomeNavigator.goToMonthsSelection(card: product, months: response.months, delegate: self, placeholders: [placeholder])
        }, onError: { [weak self] error in
            self?.operativePresentationDelegate?.hideOperativeLoading {
                self?.operativePresentationDelegate?.showOperativeAlertError(keyTitle: nil, keyDesc: error?.getErrorDesc(), completion: nil)
            }
        })
    }
    
    func pdf(forCard card: Card, month: String) {
        operativePresentationDelegate?.startOperativeLoading(completion: {})
        guard
            let monthSelected = dependencies.timeManager.fromString(input: month, inputFormat: .MMMM_YYYY),
            let halfMonthSelected = Date.halfMonth(monthSelected),
            let nextMonth = Date.getNextMonth(monthSelected),
            let halfNextMonth = Date.halfMonth(nextMonth) else { return }
        
        let dateFilter = DateFilterDO.formDate(halfMonthSelected, to: halfNextMonth)

        let input = GetCardPdfTransactionUseCaseInput(dateFilter: dateFilter, card: card)
        let useCase = dependencies.useCaseProvider.getCardPdf(input: input)
        
        UseCaseWrapper(with: useCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: errorHandler, onSuccess: { [weak self] response in
            self?.operativePresentationDelegate?.hideOperativeLoading {
                self?.dependencies.navigatorProvider.productHomeNavigator.goToPdf(with: response.document, pdfSource: .cardPDFExtract)
            }
            }, onError: { [weak self] error in
                self?.operativePresentationDelegate?.hideOperativeLoading {
                    let errorKey: String?
                    if case .extractNotAvailable? = error?.errorType {
                        errorKey = "generic_alert_notAvailablePdfExtract"
                    } else {
                        errorKey = error?.getErrorDesc()
                    }
                    self?.operativePresentationDelegate?.showOperativeAlertError(keyTitle: self?.dependencies.stringLoader.getString("").text,
                                                                                 keyDesc: errorKey,
                                                                                 completion: nil)
                }
        })
    }
    
    func didCancelMonthSelection() {
    }
}
