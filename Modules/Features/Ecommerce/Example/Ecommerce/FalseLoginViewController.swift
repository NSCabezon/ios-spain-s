import Ecommerce
import CoreFoundationLib
import UIKit
import UI

final class FalseLoginViewController: UIViewController {
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var icnSantader: UIImageView!
    @IBOutlet weak var icnFingerprint: UIImageView!
    @IBOutlet weak var icnMenu: UIImageView!
    @IBOutlet weak var icnBalance: UIImageView!
    @IBOutlet weak var icnKeyboard: UIImageView!
    @IBOutlet weak var icnSantanderKey: UIImageView!
    private let coordinator: EcommerceModuleCoordinator
    private let dependenciesResolver: DependenciesResolver
    
    init(coordinator: EcommerceModuleCoordinator, dependenciesResolver: DependenciesResolver) {
        self.coordinator = coordinator
        self.dependenciesResolver = dependenciesResolver
        super.init(nibName: "FalseLogin", bundle: .main)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundImage.image = Assets.image(named: "bg_nature_5")
        icnSantader.image = Assets.image(named: "icnSanWhite")
        icnFingerprint.image = Assets.image(named: "icnFingerprintLogin")
        icnMenu.image = Assets.image(named: "iconMenuWhite")
        icnBalance.image = Assets.image(named: "icnBalance")
        icnKeyboard.image = Assets.image(named: "icnKeyboardLogin")
        icnSantanderKey.image = Assets.image(named: "icnSantanderKeyLock")
    }
    
    @IBAction func didTapSantanderKey(_ sender: Any) {
        Scenario(useCase: SaveTokenPushUseCase(dependenciesResolver: dependenciesResolver), input: SaveTokenPushUseCaseInput(token: "hola".data(using: .utf8)!))
            .execute(on: DispatchQueue.main)
            .onSuccess { [weak self] in
                // Try Ecommerce:
                self?.coordinator.start(.mainDefault)
                // Try Fintech:
//                let mock = FintechUserAuthenticationMock()
//                self?.coordinator.start(.fintechTPPConfirmation(mock))
            }
    }
}

private class FintechUserAuthenticationMock: FintechUserAuthenticationRepresentable {
    var magicPhrase: String?
    var clientId: String? = "1"
    var responseType: String? = "0"
    var state: String? = "tarta"
    var scope: String? = ""
    var redirectUri: String? = "Uri"
    var token: String? = "7"
}
