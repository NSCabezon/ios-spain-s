import IntentsUI

@available(iOS 12.0, *)
class IntentViewController: UIViewController, INUIHostedViewControlling {
    
    private lazy var dependencies: SiriDependenciesUI = {
        return SiriDependenciesUI(rootViewController: self)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
        
    // MARK: - INUIHostedViewControlling
    func configureView(for parameters: Set<INParameter>, of interaction: INInteraction, interactiveBehavior: INUIInteractiveBehavior, context: INUIHostedViewContext, completion: @escaping (Bool, Set<INParameter>, CGSize) -> Void) {
        let result = dependencies.navigatorProvider.mainNavigator.start(withParameters: MainPresentationParameters(interaction: interaction))
        completion(result.handled, result.parameters, result.size)
    }
}
