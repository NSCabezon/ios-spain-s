import CoreFoundationLib

class CardOperativesPresenterProvider {
    
    var selectTypeBlockCardPresenter: SelectTypeBlockCardPresenter {
        return SelectTypeBlockCardPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    var insertPhoneSignUpCesCardPresenter: InsertPhoneSignUpCesCardPresenter {
        return InsertPhoneSignUpCesCardPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    var mobileTopUpPresenter: MobileTopUpPresenter {
        return MobileTopUpPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    var mobileTopUpConfirmationPresenter: OperativeStepPresenterProtocol {
        return MobileToUpConfirmationPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    var withdrawMoneyConfigurationPresenter: WithdrawMoneyConfigurationPresenter {
        return WithdrawMoneyConfigurationPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.withdrawMoneyNavigator)
    }
    
    var withdrawMoneyHistoricalPresenter: WithdrawMoneyHistoricalPresenter {
        return WithdrawMoneyHistoricalPresenter(dispositionsPresenter: withdrawMoneyHistoricalTransactionsPresenter, sessionManager: sessionManager, dependencies: dependencies, navigator: navigatorProvider.withdrawMoneyHistoricalNavigator)
    }
    
    var historicalDispensationDetailPresenter: HistoricalDispensationDetailPresenter {
        return HistoricalDispensationDetailPresenter(dispositionDetailInfo: dispositionDetailInfoPresenter, dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    private var dispositionDetailInfoPresenter: DispositionDetailInfoPresenter {
        return DispositionDetailInfoPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.productDetailNavigator)
    }

    private var withdrawMoneyHistoricalTransactionsPresenter: WithdrawMoneyHistoricalTransactionsPresenter {
        return WithdrawMoneyHistoricalTransactionsPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.productHomeNavigator)
    }
    
    var payOffSetupPresenter: PayOffPresenter {
        return PayOffPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    var payOffResumePresenter: PayOffResumePresenter {
        return PayOffResumePresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    var directMoneyInputPresenter: DirectMoneyInputPresenter {
        return DirectMoneyInputPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    var directMoneyConfirmationPresenter: DirectMoneyConfirmationPresenter {
        return DirectMoneyConfirmationPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    var chargeDischargeCardAccountSelectionPresenter: ChargeDischargeCardAccountSelectionPresenter {
        return ChargeDischargeCardAccountSelectionPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    var chargeDischargeAmountInputPresenter: ChargeDischargeCardInputAmountPresenter {
        return ChargeDischargeCardInputAmountPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    var chargeDischargeCardConfirmationPresenter: ChargeDischargeCardConfirmationPresenter {
        return ChargeDischargeCardConfirmationPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    var inputDataPayLaterCardPresenter: InputDataPayLaterCardPresenter {
        return InputDataPayLaterCardPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    var confirmationPayLaterCardPresenter: PayLaterCardConfirmationPresenter {
        return PayLaterCardConfirmationPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    var selectCardModifyFormPresenter: SelectCardModifyPaymentFormPresenter {
        return SelectCardModifyPaymentFormPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.cardChangePaymentMethodNavigator)
    }
    
    var confirmationCardModifyFormPresenter: ModifyPaymentCardConfirmationPresenter {
        return ModifyPaymentCardConfirmationPresenter(dependencies: dependencies, sessionManager: sessionManager, navigator: navigatorProvider.voidNavigator)
    }
    
    let navigatorProvider: NavigatorProvider
    let sessionManager: CoreSessionManager
    let dependencies: PresentationComponent
    
    init(navigatorProvider: NavigatorProvider, sessionManager: CoreSessionManager, dependencies: PresentationComponent) {
        self.navigatorProvider = navigatorProvider
        self.sessionManager = sessionManager
        self.dependencies = dependencies
    }
}
