import CoreFoundationLib
import CoreDomain
import Foundation
import Loans
import PdfCommons

protocol ConfirmationAmortizationStepPresenterSpainProtocol: ConfirmationAmortizationStepPresenterModifierProtocol {
    var viewSpain: ConfirmationAmortizationStepViewSpainProtocol? { get set }
    func didTouchCheckBox(isSelected: Bool)
    func didTouchLink()
}

class ConfirmationAmortizationStepPresenterSpain: ConfirmationAmortizationStepPresenter {
    weak var viewSpain: ConfirmationAmortizationStepViewSpainProtocol?

    override func setupConfirmationItems() {
        super.setupConfirmationItems()
        guard let operativeData = operativeData.getPartialAmortization(), operativeData.isNewMortgageLawLoan else { return }
        viewSpain?.addConditionsCheckboxView(isSelected: false)
        self.operativeData.newMortgageLawConditionsReviewed = false
        self.container?.save(self.operativeData)
    }

    override func updateViewState() {
        super.updateViewState()
        guard let partialAmortization = operativeData.getPartialAmortization(), partialAmortization.isNewMortgageLawLoan else { return }
        let isAlreadyReviewed = operativeData.newMortgageLawConditionsReviewed ?? false
        if isAlreadyReviewed {
            viewSpain?.selectCheckBox()
            viewSpain?.enableConfirmButtonSpain()
        } else {
            viewSpain?.disableConfirmButtonSpain()
        }
    }

    private func getPdf() {
        guard let container = container else { return }
        container.handler?.showOperativeLoading { [weak self] in
            guard let self = self,
                  let amortizationType = self.operativeData.getAmortizationType(),
                  let partialAmortization = self.operativeData.getPartialAmortization(),
                  let amount = self.operativeData.getAmortizationAmount() else { return }
            let input = GetNewMortgageLawPDFUseCaseInput(loanPartialAmortization: partialAmortization, amount: amount, amortizationType: amortizationType)
            let useCase = self.dependenciesResolver.resolve(for: GetNewMortgageLawPDFUseCaseProtocol.self)
            Scenario(useCase: useCase, input: input)
                .execute(on: self.dependenciesResolver.resolve())
                .onSuccess { [weak self] result in
                    guard let self = self else { return }
                    self.container?.handler?.hideOperativeLoading {
                        guard let document = result.document.document,
                              let documentData = Data(base64Encoded: document.replace("\n", ""))
                        else {
                            self.container?.showGenericError()
                            return
                        }
                        self.goToPdfViewer(pdfData: documentData)
                    }
                }
                .onError { [weak self] _ in
                    self?.container?.handler?.hideOperativeLoading {
                        self?.container?.showGenericError()
                    }
                }
        }
    }

    func goToPdfViewer(pdfData: Data) {
        self.container?.progressBarAlpha(0)
        self.operativeData.newMortgageLawConditionsReviewed = true
        self.container?.save(self.operativeData)
        let pdfLauncher = self.dependenciesResolver.resolve(for: PDFCoordinatorLauncher.self)
        pdfLauncher.openPDF(pdfData, title: "toolbar_title_conditionsAmortizationPartial", source: .partialAmortization(self.amortizationViewModel?.contractNumber ?? ""))
    }
}

extension ConfirmationAmortizationStepPresenterSpain: ConfirmationAmortizationStepPresenterSpainProtocol {
    func didTouchCheckBox(isSelected: Bool) {
        getPdf()
    }

    func didTouchLink() {
        getPdf()
    }
}
