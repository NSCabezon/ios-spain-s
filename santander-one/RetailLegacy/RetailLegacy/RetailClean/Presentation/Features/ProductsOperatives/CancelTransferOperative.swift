//

import Foundation
import CoreFoundationLib

class CancelTransferOperative: Operative {
    
    let dependencies: PresentationComponent
    
    init(dependencies: PresentationComponent) {
        self.dependencies = dependencies
    }
    
    // MARK: - Operative
    
    var isShareable = true
    var needsReloadGP = false
    var steps = [OperativeStep]()
    var opinatorPage: OpinatorPage? {
        return .cancelScheduledTransfer
    }
    
    var giveUpOpinatorPage: OpinatorPage? {
        return .cancelTransfer
    }
    
    var finishedOperativeNavigator: StopOperativeProtocol {
        return dependencies.navigatorProvider.toHomeTransferNavigator()
    }
    
    weak var container: OperativeContainerProtocol? {
        didSet {
            buildSteps()
        }
    }
    
    func performSetup(for delegate: OperativeLauncherPresentationDelegate, container: OperativeContainerProtocol, success: @escaping () -> Void) {
        let operativeData: CancelTransferOperativeData = container.provideParameter()
        
        guard let scheduledTransferDetail = operativeData.scheduledTransferDetail else { return }
        let scheduledTransfer = operativeData.transferScheduled
        let account = operativeData.account
        
        let input = SetUpCancelTransferUseCaseInput(transferScheduled: scheduledTransfer, account: account, scheduledTransferDetail: scheduledTransferDetail)
        
        UseCaseWrapper(with: dependencies.useCaseProvider.getSetUpCancelTransferUseCase(input: input), useCaseHandler: dependencies.useCaseHandler, errorHandler: delegate.errorOperativeHandler, onSuccess: { result in
            
            var operativeData: CancelTransferOperativeData = container.provideParameter()
            operativeData.scheduledTransferDetail = result.scheduledTransferDetail
            
            container.saveParameter(parameter: operativeData)
            container.saveParameter(parameter: result.operativeConfig)
            container.saveParameter(parameter: result.signatureToken)
            
            success()
            
            }, onError: { error in
                delegate.hideOperativeLoading {
                    delegate.showOperativeAlertError(keyTitle: nil, keyDesc: error?.getErrorDesc(), completion: nil)
                }
        })
    }
    
    func performSignature(for presenter: GenericPresenterErrorHandler, completion: @escaping (Bool, GenericErrorSignatureErrorOutput?) -> Void) {
        guard let container = container else {
            return
        }
        let signatureFilled: SignatureFilled<SignatureWithToken> = container.provideParameter()
        let parameter: CancelTransferOperativeData = self.containerParameter()
        guard let scheduledTransferDetail = parameter.scheduledTransferDetail else { return }
        let scheduledTransfer = parameter.transferScheduled
        
        let input = ConfirmCancelTransferSignUseCaseInput(account: parameter.account, signatureWithToken: signatureFilled.signature, scheduledTransfer: scheduledTransfer, scheduledTransferDetail: scheduledTransferDetail)
        
        let useCase = dependencies.useCaseProvider.getConfirmCancelTransferSignUseCase(input: input)
        UseCaseWrapper(with: useCase, useCaseHandler: dependencies.useCaseHandler, errorHandler: presenter, onSuccess: { _ in
            completion(true, nil)
        }, onError: { error in
            completion(false, error)
        })
    }
    
    func getSummaryTitle() -> LocalizedStylableText {
        let parameter: CancelTransferOperativeData = self.containerParameter()
        
        guard parameter.transferScheduled.isPeriodic else {
            return dependencies.stringLoader.getString("summary_title_cancelOnePay")
        }
        
        return dependencies.stringLoader.getString("summary_title_removedPeriodicOnePay")
    }
    
    func getSummarySubtitle() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryInfo() -> [SummaryItemData]? {
        let parameter: CancelTransferOperativeData = containerParameter()
        
        var result: [SummaryItemData] = []
        
        guard let scheduledTransferDetail = parameter.scheduledTransferDetail else { return nil }
        let scheduledTransfer = parameter.transferScheduled
        let account = parameter.account
        
        result.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_originAccountTransfer"), value: account.getAliasAndInfo()))
        result.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_amount"), value: scheduledTransfer.amount?.getFormattedAmountUI() ?? ""))
        
        let concept: String
        if let transferConcept = scheduledTransfer.concept, !transferConcept.isEmpty {
            concept = transferConcept
        } else {
            concept = dependencies.stringLoader.getString("onePay_label_genericProgrammed").text
        }
        
        result.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_concept"), value: concept))
        result.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_periodicity"), value: dependencies.stringLoader.getString(scheduledTransfer.keyForPeriodicalType).text))
        
        if scheduledTransfer.isPeriodic {
            if let nextExecutionDate = dependencies.timeManager.toString(date: scheduledTransferDetail.nextExecutionDate, outputFormat: .dd_MMM_yyyy) {
                result.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_nextIssuanceDate"), value: nextExecutionDate))
            }
            result.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_startDate"), value: dependencies.timeManager.toString(date: scheduledTransferDetail.dateValidFrom, outputFormat: .dd_MMM_yyyy) ?? "" ))
            result.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_endDate"), value: dependencies.timeManager.toString(date: scheduledTransferDetail.endDate, outputFormat: .dd_MMM_yyyy) ?? dependencies.stringLoader.getString("summary_label_indefinite").text))
        } else {
            result.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_issuanceDate"), value: dependencies.timeManager.toString(date: scheduledTransferDetail.nextExecutionDate, outputFormat: .dd_MMM_yyyy) ?? "" ))
            
        }
        
        result.append(SimpleSummaryData(field: dependencies.stringLoader.getString("summary_item_beneficiary"), value: scheduledTransferDetail.beneficiaryName ?? ""))
        
        return result
    }
    
    func getAdditionalMessage() -> LocalizedStylableText? {
        return nil
    }
    
    func getSummaryContinueButtonText() -> LocalizedStylableText? {
        return dependencies.stringLoader.getString("generic_button_continue")
    }
    
    struct Notifications {
        static let operativeDidFinish = Notification.Name(rawValue: "CancelTransferOperativeNotifications.OperativeDidFinish")
    }
    
    func operativeDidFinish() {
        NotificationCenter.default.post(name: CancelTransferOperative.Notifications.operativeDidFinish, object: self)
    }
    
    // MARK: - Tracker
    
    var screenIdSignature: String? {
        return TrackerPagePrivate.CancelScheduledTransferSignature().page
    }
    
    var screenIdSummary: String? {
        return TrackerPagePrivate.CancelScheduledTransferSummary().page
    }
    
    private func typeCancelTransferParameters() -> [String: String]? {
        let operativeData: CancelTransferOperativeData = containerParameter()
        return [
            TrackerDimensions.scheduledTransferType: operativeData.transferScheduled.periodicTrackerDescription
        ]
    }
    
    var extraParametersForTrackerError: [String: String]? {
        return typeCancelTransferParameters()
    }
    
    func getTrackParametersSummary() -> [String: String]? {
        return typeCancelTransferParameters()
    }
    
    func getTrackParametersSignature() -> [String: String]? {
        return typeCancelTransferParameters()
    }
    
    func getExtraTrackShareParametersSummary() -> [String: String]? {
        return typeCancelTransferParameters()
    }
}

private extension CancelTransferOperative {
    
    private func buildSteps() {
        guard let presenterProvider = container?.presenterProvider else {
            return
        }
        let factory = OperativeStepFactory(presenterProvider: presenterProvider)
        add(step: factory.createStep() as OperativeSignatureWithToken)
        add(step: factory.createStep() as OperativeSummary)
    }
}
