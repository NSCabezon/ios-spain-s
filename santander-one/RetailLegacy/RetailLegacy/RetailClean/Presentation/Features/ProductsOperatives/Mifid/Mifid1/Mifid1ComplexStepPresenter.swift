class Mifid1ComplexStepPresenter: Mifid1FillStepPresenter {
    override var mifidStep: MifidStep {
        return .mifid1Complex
    }
    
    override func loadViewData() {
        super.loadViewData()
        
        guard let mifidData = mifidData else { return }
        switch mifidData.mifid1Status {
        case .complex(_, let questionText, let textToValidate),
             .complexMfm(_, let questionText, let textToValidate, _):
            view.questionText = textToValidate
            view.titleLegalText = questionText
        case .none, .simple, .mfm, .simpleMfm:
            break
        }
    }
    
    override func evaluateBeforeShowing(onSuccess: @escaping (Bool) -> Void) {
        super.evaluateBeforeShowing(onSuccess: onSuccess)
        
        guard let mifidData = mifidData else { return }
        switch mifidData.mifid1Status {
        case .complex, .complexMfm:
            onSuccess(true)
        case .none, .simple, .mfm, .simpleMfm:
            onSuccess(false)
        }
    }
}
