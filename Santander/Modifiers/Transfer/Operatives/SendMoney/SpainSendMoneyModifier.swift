import Operative
import TransferOperatives
import CoreFoundationLib
import OpenCombine

final class SpainSendMoneyModifier {
    
    private let dependenciesResolver: DependenciesResolver
    private var subscriptions: Set<AnyCancellable> = []
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        bindInternationalSendMoney()
    }
    
    var isEnabledChangeCountry: Bool = false
}

private extension SpainSendMoneyModifier {
    func bindInternationalSendMoney() {
        let booleanFeatureFlag: BooleanFeatureFlag = dependenciesResolver.resolve()
        booleanFeatureFlag.fetch(CoreFeatureFlag.internationalSendMoney)
            .sink { [unowned self] result in
                self.isEnabledChangeCountry = result
            }
            .store(in: &subscriptions)
    }
}

extension SpainSendMoneyModifier: SendMoneyModifierProtocol {
    var selectionDateOneFilterViewModel: SelectionDateOneFilterViewModel? {
        let labelViewModel = OneLabelViewModel(type: .normal, mainTextKey: "transfer_label_periodicity")
        let viewModel = SelectionDateOneFilterViewModel(oneLabelViewModel: labelViewModel, options: ["sendMoney_tab_today", "sendMoney_tab_chooseDay", "sendMoney_tab_periodic"])
        return viewModel
    }
    
    var freqOneInputSelectViewModel: OneInputSelectViewModel? {
        return OneInputSelectViewModel(status: .activated, infoLabelKey: "sendMoney_label_periodicity", pickerData: [SendMoneyPeriodicityTypeViewModel.month.text, SendMoneyPeriodicityTypeViewModel.quarterly.text, SendMoneyPeriodicityTypeViewModel.semiannual.text], selectedInput: 0)
    }
    
    var bussinessOneInputSelectViewModel: OneInputSelectViewModel? {
        return OneInputSelectViewModel(status: .activated, pickerData: ["sendMoney_label_previousWorkingDay", "sendMoney_label_laterWorkingDay"], selectedInput: 0)
    }
    
    var isDescriptionRequired: Bool {
        return false
    }
    
    func getSendMoneyPeriodicityType(_ index: Int) -> SendMoneyPeriodicityTypeViewModel {
        switch index {
        case 0:
            return .month
        case 1:
            return .quarterly
        case 2:
            return .semiannual
        default:
            return .month
        }
    }
    
    func getTransferTypeStep(dependencies: DependenciesInjector & DependenciesResolver) -> OperativeStep? {
        return SendMoneyTransferTypeStep(dependencies: dependencies)
    }
    
    func transferTypeFor(onePayType: OnePayTransferType, subtype: String) -> String {
        if case OnePayTransferType.national = onePayType {
            return subtype
        } else {
            return SpainTransferType.standard.serviceString
        }
    }
    
    func isConfirmationEmailEnabled(_ sendMoneyDateType: SendMoneyDateTypeViewModel) -> Bool {
        switch sendMoneyDateType {
        case .now:
            return true
        case .day, .periodic:
            return false
        }
    }
    
    var giveUpOpinator: String {
        return "APP-RET-transfer-ABANDON-ES"
    }
    
    var favoriteGiveUpOpinator: String {
        return "APP-RET-fav-transfer-ABANDON-ES"
    }
    
    func isCurrencyEditable(_ operativeData: SendMoneyOperativeData) -> Bool {
        guard operativeData.destinationSelectionType == .newRecipient else {
            return false
        }
        return isEnabledChangeCountry
    }
    
    var expensesItems: [SendMoneyNoSepaExpensesProtocol] {
        [
            SpainNoSepaTransferExpenses.payer,
            SpainNoSepaTransferExpenses.shared,
            SpainNoSepaTransferExpenses.beneficiary
        ]
    }
    
    func getScaSteps(dependencies: DependenciesInjector & DependenciesResolver) -> [OperativeStep] {
        return [SignatureStep(dependenciesResolver: dependencies), OTPStep(dependenciesResolver: dependencies)]
    }
    
    var maxProgressBarSteps: Int {
        return 8
    }
}
