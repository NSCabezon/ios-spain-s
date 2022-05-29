class Mifid1MfmStepPresenter: Mifid1FillStepPresenter {
    private var mfmIndex: Int = 0
    private var clausules: [(questionTextMfm: String, textToValidateMfm: String)] = []
    
    override var mifidStep: MifidStep {
        return .mfm
    }
    
    override func loadViewData() {
        super.loadViewData()
        
        guard let mifidData = mifidData else { return }
        switch mifidData.mifid1Status {
        case .mfm(let clausules),
             .simpleMfm(_, let clausules),
             .complexMfm(_, _, _, let clausules):
            self.clausules = clausules
            view.questionText = clausules[0].textToValidateMfm
            view.titleLegalText = clausules[0].questionTextMfm
        case .none, .simple, .complex:
            break
        }
    }
    
    override func evaluateBeforeShowing(onSuccess: @escaping (Bool) -> Void) {
        super.evaluateBeforeShowing(onSuccess: onSuccess)
        
        guard let mifidData = mifidData else { return }
        switch mifidData.mifid1Status {
        case .mfm, .simpleMfm, .complexMfm:
            onSuccess(true)
        case .none, .simple, .complex:
            onSuccess(false)
        }
    }
    
    override func continueAction() {
        guard let confirmation = view.confirmationQuestionText else { return }
        
        if !confirmation.isEmpty && confirmation == view.questionText {
            mfmIndex += 1
            guard mfmIndex < clausules.count else {
                container?.mifidStepFinished(presenter: self)
                return
            }
            view.questionText = clausules[mfmIndex].textToValidateMfm
            view.titleLegalText = clausules[mfmIndex].questionTextMfm
            view.confirmationQuestionText = ""
        } else {
            showErrorValidation()
        }
    }
}
