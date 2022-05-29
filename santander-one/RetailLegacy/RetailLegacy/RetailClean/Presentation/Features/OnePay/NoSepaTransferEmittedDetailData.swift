import UIKit.UIPasteboard

class NoSepaTransferEmittedDetailData: BaseTransferDetailData<EmittedNoSepaTransferDetail, TransferEmitted> {
    
    override func makeAccountSection() -> TableModelViewSection {
        let accountSection = TableModelViewSection()
        accountSection.setHeader(modelViewHeader: buildHeader(with: "deliveryDetails_label_originAccount"))
        let vm = AccountConfirmationViewModel(
            accountName: account.getAlias() ?? stringLoader.getString("generic_confirm_associatedAccount").text,
            ibanNumber: account.getIBANShort(),
            amount: account.getLongAmountUI(),
            privateComponent: dependencies)
        accountSection.add(item: vm)
        
        return accountSection
    }
    
    override func makeDetailSection(transferDetail: EmittedNoSepaTransferDetail, transfer: TransferEmitted) -> TableModelViewSection {
        let sectionDetail = TableModelViewSection()
        sectionDetail.setHeader(modelViewHeader: buildHeader(with: "deliveryDetails_label_dataDelivery"))
        
        let header = DetailThreeLinesViewModel(stringLoader.getString("deliveryDetails_label_natStandard"), amount: transferDetail.transferAmount, isFirst: true, isLast: false, info: transfer.concept ?? stringLoader.getString("onePay_label_notConcept").text, dependencies)
        sectionDetail.add(item: header)
        
        sectionDetail.add(item: DetailItemViewModel(stringLoader.getString("deliveryDetails_label_destinationAccounts"), info: transferDetail.payee?.paymentAccountDescription, isFirst: false, isLast: false, isCopyEnabled: true, toolTipDisplayer: toolTipDisplayer, dependencies, shareDelegate: self))
        
        sectionDetail.add(item: DetailItemViewModel(stringLoader.getString("deliveryDetails_label_beneficiary"), info: transfer.beneficiary, isFirst: false, isLast: false, subtitleLines: 2, isCopyEnabled: false, toolTipDisplayer: toolTipDisplayer, dependencies, shareDelegate: self))
        
        if !isNoSepaTransferIban(transferDetail), let beneficiaryAddress = transferDetail.payee?.address, !beneficiaryAddress.isEmpty {
            sectionDetail.add(item: DetailItemViewModel(stringLoader.getString("deliveryDetails_label_beneficiaryAddress"), info: beneficiaryAddress, isFirst: false, isLast: false, isCopyEnabled: false, toolTipDisplayer: toolTipDisplayer, dependencies, shareDelegate: self))
        }
        
        if !isNoSepaTransferIban(transferDetail), let beneficiaryTown = transferDetail.payee?.town, !beneficiaryTown.isEmpty {
            sectionDetail.add(item: DetailItemViewModel(stringLoader.getString("deliveryDetails_label_beneficiaryTown"), info: beneficiaryTown, isFirst: false, isLast: false, isCopyEnabled: false, toolTipDisplayer: toolTipDisplayer, dependencies, shareDelegate: self))
        }
        
        var titleDestinationCountry: String = ""
        if isNoSepaTransferIban(transferDetail) {
            titleDestinationCountry = "deliveryDetails_label_destinationCountry"
        } else {
            titleDestinationCountry = "deliveryDetails_label_destinationCountryToPayement"
        }
        
        if let countryCode = transferDetail.destinationCountryCode, let countryName = sepaInfo.countryFor(countryCode) {
            sectionDetail.add(item: DetailItemViewModel(stringLoader.getString(titleDestinationCountry), info: countryName.camelCasedString, isFirst: false, isLast: false, isCopyEnabled: false, toolTipDisplayer: toolTipDisplayer, dependencies, shareDelegate: self))
        }
        
        if let currencyCode = transfer.amount?.currency?.currencyName, let currency = sepaInfo.currencyFor(currencyCode) {
            sectionDetail.add(item: DetailItemViewModel(stringLoader.getString("deliveryDetails_label_currency"), info: currency, isFirst: false, isLast: false, isCopyEnabled: false, toolTipDisplayer: toolTipDisplayer, dependencies, shareDelegate: self))
        }
        
        let bicSwift: String = transferDetail.payee?.bicSwift ?? ""
        if !isNoSepaTransferIban(transferDetail), !bicSwift.isEmpty {
            sectionDetail.add(item: DetailItemViewModel(stringLoader.getString("deliveryDetails_label_bicSwift"), info: bicSwift, isFirst: false, isLast: false, isCopyEnabled: false, toolTipDisplayer: toolTipDisplayer, dependencies, shareDelegate: self))
        }
        
        if !isNoSepaTransferIban(transferDetail), let bankName = transferDetail.payee?.bankName, !bankName.isEmpty, bicSwift.isEmpty {
            sectionDetail.add(item: DetailItemViewModel(stringLoader.getString("deliveryDetails_label_nameBank"), info: bankName, isFirst: false, isLast: false, isCopyEnabled: false, toolTipDisplayer: toolTipDisplayer, dependencies, shareDelegate: self))
        }
        
        if !isNoSepaTransferIban(transferDetail), let bankAddress = transferDetail.payee?.bankAddress, !bankAddress.isEmpty, bicSwift.isEmpty {
            sectionDetail.add(item: DetailItemViewModel(stringLoader.getString("deliveryDetails_label_bankAddress"), info: bankAddress, isFirst: false, isLast: false, isCopyEnabled: false, toolTipDisplayer: toolTipDisplayer, dependencies, shareDelegate: self))
        }
        
        if !isNoSepaTransferIban(transferDetail), let bankTown = transferDetail.payee?.bankTown, !bankTown.isEmpty, bicSwift.isEmpty {
            sectionDetail.add(item: DetailItemViewModel(stringLoader.getString("deliveryDetails_label_bankTown"), info: bankTown, isFirst: false, isLast: false, isCopyEnabled: false, toolTipDisplayer: toolTipDisplayer, dependencies, shareDelegate: self))
        }
        
        if !isNoSepaTransferIban(transferDetail), let bankCountryName = transferDetail.payee?.bankCountryName, !bankCountryName.isEmpty, bicSwift.isEmpty {
            sectionDetail.add(item: DetailItemViewModel(stringLoader.getString("deliveryDetails_label_bankCountry"), info: bankCountryName, isFirst: false, isLast: false, isCopyEnabled: false, toolTipDisplayer: toolTipDisplayer, dependencies, shareDelegate: self))
        }
        
        sectionDetail.add(item: DetailItemViewModel(stringLoader.getString("deliveryDetails_label_issuanceDate"), info: dependencies.timeManager.toString(date: transferDetail.emisionDate, outputFormat: .dd_MMM_yyyy), isFirst: false, isLast: false, isCopyEnabled: false, toolTipDisplayer: toolTipDisplayer, dependencies, shareDelegate: self))
        
        let detailValueDateViewModel = DetailItemViewModel(stringLoader.getString("deliveryDetails_label_valueDate"), info: dependencies.timeManager.toString(date: transferDetail.valueDate, outputFormat: .dd_MMM_yyyy), isFirst: false, isLast: true, isCopyEnabled: false, toolTipDisplayer: toolTipDisplayer, dependencies, shareDelegate: self)
        sectionDetail.add(item: detailValueDateViewModel)
        
        return sectionDetail
    }
    
    private func isNoSepaTransferIban(_ transferDetail: EmittedNoSepaTransferDetail) -> Bool {
        let country: SepaCountryInfo = sepaInfo.getSepaCountryInfo(transferDetail.destinationCountryCode)
        let currency: SepaCurrencyInfo = sepaInfo.getSepaCurrencyInfo(transferDetail.transferAmount.currency?.currencyName)
        
        return country.sepa && currency != SepaCurrencyInfo.createEuro()
    }
    
    private func generateNoSepaPfdContent() -> String? {
        let builder = TransferPDFBuilder(stringLoader: dependencies.stringLoader, timeManager: dependencies.timeManager)
        guard let originAccountAlias = account.getAlias(),
            let destinationAccount = transferDetail.payee?.paymentAccountDescription else {
                return nil
        }
        let shortDestinationAccount = destinationAccount.asterisk()
        builder.addHeader(title: "pdf_title_summaryOnePay", office: nil, date: transferDetail.emisionDate)
        builder.addAccounts(originAccountAlias: originAccountAlias, originAccountIBAN: account.getAsteriskIban(), destinationAccountAlias: transferDetail.payee?.name ?? "", destinationAccountIBAN: shortDestinationAccount)
        var destinationCountry: String?
        if let destinationCountryCode = transferDetail.destinationCountryCode {
            destinationCountry = sepaInfo.countryFor(destinationCountryCode)
        }
        var bicSwift: String?
        var bankName: String?
        if !isNoSepaTransferIban(transferDetail) {
            bicSwift = transferDetail.payee?.bicSwift
            bankName = transferDetail.payee?.bankName
        }
        builder.addTransferInfo([
            (key: "summary_label_destinationCountryToPayement", value: destinationCountry?.capitalized),
            (key: "summary_label_bicSwift", value: bicSwift),
            (key: "summary_item_nameBank", value: bankName),
            (key: "summary_item_amount", value: transferDetail.transferAmount),
            (key: "summary_item_concept", value: transferConcept(currentConcept: transferDetail.concept1)),
            (key: "summary_item_periodicity", value: dependencies.stringLoader.getString("summary_label_timely").text),
            (key: "summary_item_transactionDate", value: dependencies.timeManager.toString(date: transferDetail.valueDate, outputFormat: .dd_MMM_yyyy))
            ])

        return builder.build()
    }
    private func transferConcept(currentConcept: String?) -> String {
        let concept: String
        if let transferConcept = currentConcept, !transferConcept.isEmpty {
            concept = transferConcept
        } else {
            concept = dependencies.stringLoader.getString("onePay_label_notConcept").text
        }
        return concept
    }
    
}

extension NoSepaTransferEmittedDetailData: TransferDetailDataType {
    
    var title: String? {
        return stringLoader.getString("toolbar_title_deliveryDetails").text
    }
    
    var actionTitle: [LocalizedStylableText] {
        var result = [LocalizedStylableText]()
        result.append(stringLoader.getString("generic_button_viewPdf"))
        result.append(stringLoader.getString("generic_button_reuse"))
        return result
    }
    
    func executeAction(_ position: Int, in presenter: TransferDetailPresenter) {
        switch position {
        case 0:
            guard let pdfContent = generateNoSepaPfdContent() else {
                return
            }
            presenter.showPDF(pdfContent)
        case 1:
            showReemittedNoSepaTransfer(presenter: presenter)
        default:
            break
        }
    }
    
    private func showReemittedNoSepaTransfer(presenter: TransferDetailPresenter) {
        showReemittedNoSepaTransfer(transferDetail: transferDetail, account: originAccount, delegate: presenter, launchedFrom: .emittedTransfer, accountType: nil)
    }
    
    func viewLoaded() {
        dependencies.trackerManager.trackScreen(screenId: TrackerPagePrivate.EmittedTransferDetail().page, extraParameters: [:])
    }
    
}

extension NoSepaTransferEmittedDetailData: ReemittedTransferLauncher {}

extension NoSepaTransferEmittedDetailData: ShareInfoHandler {
    func shareInfoWithCode(_ code: Int?) {
        guard let ibanNumber = transferDetail.payee?.paymentAccountDescription else { return }
        shareDelegate?.shareContent(ibanNumber)
    }
}

extension NoSepaTransferEmittedDetailData: ReemittedNoSepaTransferLauncher {}
