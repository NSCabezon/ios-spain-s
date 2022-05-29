import CoreFoundationLib
import QuickSetup
import CoreDomain

final class OneAuthorizationProcessorMainModuleCoordinatorMock {
    
    let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension OneAuthorizationProcessorMainModuleCoordinatorMock: OneAuthorizationProcessorDelegate {
    func authorizationDidFinishSuccessfully() {
        print("Finished correctly")
    }
    
    func authorizationDidFinishWithError(_ error: Error) {
        print("Finished with error \(error)")
    }
}

extension OneAuthorizationProcessorMainModuleCoordinatorMock: ChallengesHandlerDelegate {
    func handle(_ challenge: ChallengeRepresentable, completion: @escaping (ChallengeResult) -> Void) {
        guard challenge.identifier == MockChallenge.pin.identifier else { return completion(.notHandled) }
        let navigationController = UINavigationController()
        let viewController = ChallengeViewController(completion: completion)
        navigationController.viewControllers = [viewController]
        navigationController.modalPresentationStyle = .fullScreen
        UIApplication.shared.keyWindow?.rootViewController?.present(navigationController, animated: true, completion: nil)
    }
    
    func handle(_ challenge: ChallengeRepresentable, authorizationId: String, completion: @escaping (ChallengeResult) -> Void) {
        struct ChallengeVerification: ChallengeVerificationRepresentable {
            
        }
        completion(.handled(ChallengeVerification()))
    }
}

import UIKit

enum MockChallenge: ChallengeRepresentable {
    case pin
    
    var identifier: String {
        switch self {
        case .pin: return "PIN"
        }
    }
}

final class ChallengeViewController: UIViewController {
    
    let completion: (ChallengeResult) -> Void
    
    init(completion: @escaping (ChallengeResult) -> Void) {
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addButton()
    }
    
    func addButton() {
        let button = UIButton()
        button.backgroundColor = .red
        button.setTitle("Press to close", for: .normal)
        button.addTarget(self, action: #selector(dismissChallenge), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        button.heightAnchor.constraint(equalToConstant: 20).isActive = true
        button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    @objc func dismissChallenge() {
        dismiss(animated: true) {
            self.completion(.handled(PinChallengeVerification()))
        }
    }
    
    private struct PinChallengeVerification: ChallengeVerificationRepresentable {
        
    }
}
