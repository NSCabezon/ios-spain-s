import Foundation

typealias OperativeProductSelectionPresenterStep = OperativeStepPresenterProtocol & OperativeLauncherPresentationDelegate

protocol OperativeProductSelectionProfile: class {
    
    associatedtype Product: GenericProduct
    
    init(operativeStep: OperativeProductSelectionPresenterStep)
    var operativeStep: OperativeProductSelectionPresenterStep? { get set }
    func products() -> [Product]
    func selected(_ index: Int)
    func evaluateBeforeShowing(completion: @escaping (Bool) -> Void)
    func setupHeader(for section: TableModelViewSection)
    func title() -> String
    func subtitle() -> String
    var screenIdProductSelection: String? { get }
}

extension OperativeProductSelectionProfile {
    
    func containerParameter<T: OperativeParameter>() -> T {
        guard let container = operativeStep?.container else {
            fatalError()
        }
        return container.provideParameter()
    }
    
    func saveParameter<T: OperativeParameter>(_ parameter: T) {
        operativeStep?.container?.saveParameter(parameter: parameter)
    }
    
    func evaluateBeforeShowing(completion: @escaping (Bool) -> Void) {
        completion(true)
    }
    
    func setupHeader(for section: TableModelViewSection) {
        // Nothing to do here
    }
    
    func title() -> String {
        let parameter: ProductSelection<Product> = containerParameter()
        return parameter.titleKey
    }
    
    func subtitle() -> String {
        let parameter: ProductSelection<Product> = containerParameter()
        return parameter.subTitleKey
    }
}

typealias AccountOperativeProductSelectionProfile = DefaultOperativeProductSelectionProfile<Account>

class DefaultOperativeProductSelectionProfile<Product: GenericProduct>: OperativeProductSelectionProfile {
    var screenIdProductSelection: String? {
        return operativeStep?.container?.operative.screenIdProductSelection
    }
    
    weak var operativeStep: OperativeProductSelectionPresenterStep?
    
    required init(operativeStep: OperativeProductSelectionPresenterStep) {
        self.operativeStep = operativeStep
    }
    
    func products() -> [Product] {
        let parameter: ProductSelection<Product> = containerParameter()
        return parameter.list
    }
    
    func selected(_ index: Int) {
        operativeStep?.startOperativeLoading { [weak self] in
            guard let strongSelf = self, let operativeStep = strongSelf.operativeStep, let container = operativeStep.container else { return }
            let parameter: ProductSelection<Product> = strongSelf.containerParameter()
            parameter.productSelected = parameter.list[index]
            strongSelf.saveParameter(parameter)
            container.operative.performSetup(
                for: operativeStep,
                container: container,
                success: { [weak self] in
                    self?.operativeStep?.hideOperativeLoading { [weak self] in
                        guard let strongSelf = self, let presenter = strongSelf.operativeStep else { return }
                        container.stepFinished(presenter: presenter)
                    }
                }
            )
        }
    }
    
    func evaluateBeforeShowing(completion: @escaping (Bool) -> Void) {
        let selection: ProductSelection<Product> = containerParameter()
        if selection.productSelected == nil {
            completion(true)
        } else {
            completion(false)
        }
    }
}
