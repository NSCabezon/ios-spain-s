protocol OperativeSignatureStep: OperativeStep {
}

extension OperativeSignatureStep {
    var presentationType: StepPresentation {
        return .inNavigation
    }
    var showsBack: Bool {
        return true
    }
    var showsCancel: Bool {
        return true
    }
}

struct OperativeSimpleSignature: OperativeSignatureStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.operativeSimpleSignaturePresenter
    }
    
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct LisboaSignatureWithToken: OperativeSignatureStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.lisboaOperativeSignatureWithTokenPresenter
    }
    
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct OperativeSignatureWithToken: OperativeSignatureStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.operativeSignatureWithTokenPresenter
    }
    
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct OperativeOTP: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        let presenter = presenterProvider.operativeOtpPresenter
        return presenter
    }
    
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct OperativeSummary: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = false
    var showsCancel: Bool = false
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.operativeSummaryPresenter
    }
    
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct OperativeWithdrawMoneySummary: OperativeStep {
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = false
    var showsCancel: Bool = false
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        return presenterProvider.withdrawMoneySummaryPresenter
    }
    
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct OperativeFinishedDialog: OperativeStep {
    var presentationType: StepPresentation = .modal
    var showsBack: Bool = false
    var showsCancel: Bool = false
    var number: Int
    
    var dialogTitle: LocalizedStylableText?
    var dialogMessage: LocalizedStylableText?
    var acceptButton: LocalizedStylableText?
    
    var presenter: OperativeStepPresenterProtocol {
        let presenter = presenterProvider.operativeFinishedDialogPresenter
        presenter.dialogTitle = dialogTitle
        presenter.dialogMessage = dialogMessage
        presenter.acceptTitle = acceptButton
        
        return presenter
    }
    
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}

struct ProductSelectionStep<Profile: OperativeProductSelectionProfile>: OperativeStep {
    
    var presentationType: StepPresentation = .inNavigation
    var showsBack: Bool = true
    var showsCancel: Bool = true
    var number: Int
    var presenter: OperativeStepPresenterProtocol {
        let presenter: OperativeProductSelectionPresenter<Profile> = presenterProvider.operativeProductSelectionPresenter()
        presenter.profile = Profile(operativeStep: presenter)
        return presenter
    }
    private let presenterProvider: PresenterProvider
    
    init(presenterProvider: PresenterProvider, number: Int) {
        self.presenterProvider = presenterProvider
        self.number = number
    }
}
