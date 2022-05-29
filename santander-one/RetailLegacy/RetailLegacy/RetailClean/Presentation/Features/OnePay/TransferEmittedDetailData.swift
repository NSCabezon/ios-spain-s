import UIKit.UIPasteboard

class TransferEmittedDetailData: BaseTransferDetailData<EmittedTransferDetail, TransferEmitted> {
    
    override func makeAccountSection() -> TableModelViewSection {
        let accoutSection = TableModelViewSection()
        accoutSection.setHeader(modelViewHeader: buildHeader(with: "deliveryDetails_label_originAccount"))
        let vm = AccountConfirmationViewModel(
            accountName: account.getAlias() ?? stringLoader.getString("generic_confirm_associatedAccount").text,
            ibanNumber: account.getIBANShortLisboaStyle(),
            amount: account.getLongAmountUI(),
            privateComponent: dependencies)
        accoutSection.add(item: vm)
        return accoutSection
    }
    
    override func makeDetailSection(transferDetail: EmittedTransferDetail, transfer: TransferEmitted) -> TableModelViewSection {
        let sectionDetail = TableModelViewSection()
        sectionDetail.setHeader(modelViewHeader: buildHeader(with: "deliveryDetails_label_dataDelivery"))
        let isLocal = transferDetail.beneficiary?.countryCode.lowercased() == "es"
        let transferTitle =  isLocal ? stringLoader.getString("deliveryDetails_label_national") : stringLoader.getString("deliveryDetails_label_international")
        let concept = transfer.concept ?? stringLoader.getString("onePay_label_notConcept").text
        let header = DetailThreeLinesViewModel(transferTitle, amount: transferDetail.transferAmount, isFirst: true, isLast: false, info: concept, dependencies)
        sectionDetail.add(item: header)
        let fields: [DetailItemViewModel] = EmittedField.allCases.map { DetailItemViewModel(stringLoader.getString($0.titleKey), info: $0.infoFrom(transferDetail, transfer: transfer, sepaInfo: sepaInfo, timeManager: dependencies.timeManager), isFirst: false, isLast: $0 == EmittedField.allCases.last, subtitleLines: $0.numberOfLines, isCopyEnabled: $0.isCopyEnabled, toolTipDisplayer: toolTipDisplayer, dependencies, shareDelegate: self) }
        sectionDetail.addAll(items: fields)
        return sectionDetail
    }
}

extension TransferEmittedDetailData: TransferDetailDataType {
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
            if let pdfContent = generateSepaPfdContent() {
                presenter.showPDF(pdfContent)
            }
        case 1:
            showReemittedTransferLauncher(transferDetail: transferDetail, transfer: transfer, account: originAccount, delegate: presenter)
        default:
            break
        }
    }
    
    func viewLoaded() {
        dependencies.trackerManager.trackScreen(screenId: TrackerPagePrivate.EmittedTransferDetail().page, extraParameters: [:])
    }
    
    private func generateSepaPfdContent() -> String? {
        guard let originAccountAlias = account.getAlias(),
            let originAccountIBAN = transferDetail.origin?.getAsterisk(),
            let destinationIBAN = transferDetail.beneficiary?.getAsterisk() else {
                return nil
        }
        
        let builder = TransferPDFBuilder(stringLoader: dependencies.stringLoader, timeManager: dependencies.timeManager)
        builder.addHeader(title: "pdf_title_summaryOnePay", office: nil, date: transferDetail.emisionDate)
        builder.addAccounts(originAccountAlias: originAccountAlias, originAccountIBAN: originAccountIBAN, destinationAccountAlias: transferDetail.beneficiaryName ?? "", destinationAccountIBAN: destinationIBAN)
        builder.addTransferInfo([
            (key: "summary_item_amount", value: transfer.amount),
            (key: "summary_item_concept", value: transferConcept(currentConcept: transfer.concept)),
            (key: "summary_item_periodicity", value: transferPeriodicity()),
            (key: "summary_item_transactionDate", value: dependencies.timeManager.toString(date: transfer.executedDate, outputFormat: .dd_MMM_yyyy))
            ])
        builder.addExpenses([
            (key: "summary_item_commission", value: transferDetail.fees),
            (key: "summary_item_amountToDebt", value: transferDetail.totalAmount)
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
    
    private func transferPeriodicity() -> String? {
        // Android is doing it this way
        guard transferDetail.origin != transferDetail.beneficiary else {
            return nil
        }
        
        return dependencies.stringLoader.getString("summary_label_timely").text
    }
}

extension TransferEmittedDetailData: ReemittedTransferLauncher {}

extension TransferEmittedDetailData: ShareInfoHandler {
    func shareInfoWithCode(_ code: Int?) {
        guard let ibanNumber = transferDetail.beneficiary?.ibanPapel else { return }
        shareDelegate?.shareContent(ibanNumber)
    }
}

extension TransferEmittedDetailData {
    enum EmittedField: CaseIterable {
        case destinationAccount
        case beneficiary
        case destinationCountry
        case currency
        case emisionDate
        case valueDate
        case fees
        case totalAmount
        
        var titleKey: String {
            switch self {
            case .destinationAccount:
                return "deliveryDetails_label_destinationAccounts"
            case .beneficiary:
                return "deliveryDetails_label_beneficiary"
            case .destinationCountry:
                return "deliveryDetails_label_destinationCountry"
            case .currency:
                return "deliveryDetails_label_currency"
            case .emisionDate:
                return "deliveryDetails_label_issuanceDate"
            case .valueDate:
                return "deliveryDetails_label_valueDate"
            case .fees:
                return "deliveryDetails_label_commission"
            case .totalAmount:
                return "deliveryDetails_label_amountToDebt"
            }
        }
        
        var isCopyEnabled: Bool {
            return self == .destinationAccount
        }
        
        var numberOfLines: Int {
            switch self {
            case .beneficiary:
                return 2
            default:
                return 1
            }
        }
        
        func infoFrom(_ transferDetail: EmittedTransferDetail, transfer: TransferEmitted, sepaInfo: SepaInfoList, timeManager: TimeManager) -> String? {
            switch self {
            case .beneficiary:
                return transfer.beneficiary?.camelCasedString
            case .destinationAccount:
                return transferDetail.beneficiary?.formatted
            case .destinationCountry:
                return sepaInfo.getSepaCountryInfo(transferDetail.beneficiary?.countryCode).name
            case .currency:
                return sepaInfo.getSepaCurrencyInfo(transfer.amount?.currency?.currencyName).name
            case .emisionDate:
                return timeManager.toString(date: transferDetail.emisionDate, outputFormat: .dd_MMM_yyyy)
            case .valueDate:
                return timeManager.toString(date: transferDetail.valueDate, outputFormat: .dd_MMM_yyyy)
            case .fees:
                return transferDetail.fees?.getFormattedAmountUI()
            case .totalAmount:
                return transferDetail.totalAmount?.getFormattedAmountUI()
            }
        }
    }
}
