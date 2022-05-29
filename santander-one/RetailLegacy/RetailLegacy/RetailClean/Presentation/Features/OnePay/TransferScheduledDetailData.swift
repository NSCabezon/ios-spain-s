import UIKit.UIPasteboard

class TransferScheduledDetailData: BaseTransferDetailData<ScheduledTransferDetail, TransferScheduled> {
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
    
    override func makeDetailSection(transferDetail: ScheduledTransferDetail, transfer: TransferScheduled) -> TableModelViewSection {
        
        let sectionDetail = TableModelViewSection()
        sectionDetail.setHeader(modelViewHeader: buildHeader(with: "deliveryDetails_label_dataDelivery"))
        let transferTitle =  stringLoader.getString("detailsOnePay_label_standardProgrammed")
        let header = DetailThreeLinesViewModel(transferTitle, amount: transferDetail.transferAmount, isFirst: true, isLast: false, info: transfer.concept, dependencies)
        sectionDetail.add(item: header)
        
        let fields: [DetailItemViewModel] = ScheduledField.allCases.compactMap { field in
            guard let info = field.infoFrom(transferDetail, transfer: transfer, sepaInfo: sepaInfo, stringLoader: stringLoader, timeManager: dependencies.timeManager) else {
                return nil
            }
            return DetailItemViewModel(stringLoader.getString(field.titleKey), info: info, isFirst: false, isLast: false, subtitleLines: field.numberOfLines, isCopyEnabled: field.isCopyEnabled, toolTipDisplayer: toolTipDisplayer, dependencies, shareDelegate: self)
        }
        fields.last?.isLast = true
        sectionDetail.addAll(items: fields)
        
        return sectionDetail
    }
    
}

extension TransferScheduledDetailData: ModifyDeferredTransferLauncher, ModifyPeriodicTransferLauncher {}

extension TransferScheduledDetailData: TransferDetailDataType {
    
    var title: String? {
        return stringLoader.getString("toolbar_title_deliveryDetails").text
    }
    
    var actionTitle: [LocalizedStylableText] {
        return [stringLoader.getString("generic_buttom_delete"), stringLoader.getString("generic_buttom_edit")]
    }
    
    func executeAction(_ position: Int, in presenter: TransferDetailPresenter) {
        switch position {
        case 0:
            presenter.navigator.goToCancelTransferConfirmation(transferScheduled: transfer, scheduledTransferDetail: transferDetail, account: account, operativeDelegate: presenter)
        case 1:
            if !transfer.isPeriodic {
                showModifyDeferredTransfer(account: account, transfer: transfer, scheduledTransferDetail: transferDetail, delegate: presenter)
            } else {
                showModifyPeriodicTransfer(account: account, transfer: transfer, scheduledTransferDetail: transferDetail, delegate: presenter)
            }
        default:
            break
        }
    }
    
    func viewLoaded() {
        dependencies.trackerManager.trackScreen(
            screenId: TrackerPagePrivate.ScheduledTransferDetail().page,
            extraParameters: [
                TrackerDimensions.scheduledTransferType: transfer.periodicTrackerDescription
            ]
        )
    }
}

extension TransferScheduledDetailData: ShareInfoHandler {
    func shareInfoWithCode(_ code: Int?) {
        guard let ibanNumber = transferDetail.beneficiary?.ibanPapel else { return }
        shareDelegate?.shareContent(ibanNumber)
    }
}

extension TransferScheduledDetailData {
    
    enum ScheduledField: CaseIterable {
        case destinationAccount
        case beneficiary
        case destinationCountry
        case currency
        case frequency
        case validFrom
        case nextEmisionDate
        case endDate
        
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
            case .frequency:
                return "detailsOnePay_label_periodicy"
            case .validFrom:
                return "deliveryDetails_label_issuanceDate"
            case .nextEmisionDate:
                return "detailsOnePay_label_nextIssuanceDate"
            case .endDate:
                return "detailsOnePay_label_endDate"
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
        
        func infoFrom(_ transferDetail: ScheduledTransferDetail, transfer: TransferScheduled, sepaInfo: SepaInfoList, stringLoader: StringLoader, timeManager: TimeManager) -> String? {
            switch self {
            case .beneficiary:
                return transferDetail.beneficiaryName
            case .destinationAccount:
                return transferDetail.beneficiary?.formatted
            case .destinationCountry:
                return sepaInfo.getSepaCountryInfo(transferDetail.beneficiary?.countryCode).name
            case .currency:
                return sepaInfo.getSepaCurrencyInfo(transfer.amount?.currency?.currencyName).name
            case .frequency:
                guard transfer.isPeriodic else {
                    return stringLoader.getString("summary_label_timely").text
                }
                switch transfer.periodicalType {
                case .monthly?:
                    return stringLoader.getString("summary_label_monthly").text
                case .trimestral?:
                    return stringLoader.getString("summary_label_quarterly").text
                case .semiannual?:
                    return stringLoader.getString("summary_label_sixMonthly").text
                default:
                    return nil
                }
            case .nextEmisionDate:
                guard transfer.isPeriodic else { return nil }
                return timeManager.toString(date: transferDetail.nextExecutionDate, outputFormat: .dd_MMM_yyyy)
            case .validFrom:
                guard !transfer.isPeriodic else { return nil }
                return timeManager.toString(date: transfer.endDate, outputFormat: .dd_MMM_yyyy)
            case .endDate:
                guard transfer.isPeriodic else { return nil }
                if transferDetail.endDate?.getYear() == 9999 {
                    return stringLoader.getString("detailsOnePay_label_indefinite").text
                }
                return timeManager.toString(date: transferDetail.endDate, outputFormat: .dd_MMM_yyyy)
            }
        }
    }
    
}
