protocol MifidView: ViewControllerProxy {
    
}

protocol MifidPresenterProtocol: class, OperativeStepProgressProtocol {
    var mifidStep: MifidStep { get }
    var stepView: MifidView { get }
    var container: MifidContainerProtocol? { get set }
    
    func evaluateBeforeShowing(onSuccess: @escaping (Bool) -> Void)
}

class MifidPresenter<View, Navigator, Contract>: PrivatePresenter<View, Navigator, Contract>, MifidPresenterProtocol where View: BaseViewController<Contract> {
    
    var container: MifidContainerProtocol?
    
    var stepView: MifidView {
        guard let stepView = view as? MifidView else {
            fatalError()
        }
        return stepView
    }
    
    var number: Int {
        return mifidStep.rawValue
    }
    
    var shouldShowProgress: Bool {
        return true
    }
    
    override var barButtons: [RightBarButton] {
        get {
            return mifidStep.presentation == .inNavigation ? [.close] : []
        }
        //swiftlint:disable unused_setter_value
        set {
            
        }
        //swiftlint:enable unused_setter_value
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        container?.delegate?.mifidWillShow(self)
    }
    
    var mifidStep: MifidStep {
        fatalError()
    }
    
    func evaluateBeforeShowing(onSuccess: @escaping (Bool) -> Void) {
        onSuccess(true)
    }
}

extension MifidPresenter: CloseButtonAwarePresenterProtocol {
    func closeButtonTouched() {
        container?.cancelOperativeTouched()
    }
}
