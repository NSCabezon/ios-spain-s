import UI
import UIKit
import Foundation
import OpenCombine
import ESUI
import UIOneComponents
import Operative

final class SKAuthorizationViewController: UIViewController, GenericErrorDialogPresentationCapable {

    private let viewModel: SKAuthorizationViewModel
    private var subscriptions: Set<AnyCancellable> = []
    private let dependencies: SKAuthorizationDependenciesResolver
    private let errorView = OneOperativeAlertErrorView()
    
    init(dependencies: SKAuthorizationDependenciesResolver) {
        self.dependencies = dependencies
        self.viewModel = dependencies.resolve()
        super.init(nibName: "SKAuthorizationViewController", bundle: .module)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        setAppearance()
        setupView()
        setAccessibilityIds()
        bind()
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
//    @IBAction func continueButtonPressed(_ sender: Any) {
//        self.viewModel.didTapContinueButton()
//    }
}

private extension SKAuthorizationViewController {
    func setAppearance() {
    }
    
    func setupView() {
    }
    
    func bind() {
        bindButtons()
        bindLoading()
        bindError()
    }
    
    func bindButtons() {
//        headerView
//            .didTapInMoreInfo
//            .sink {[unowned self] _ in
//                self.showBottomSheet()
//            }.store(in: &subscriptions)
//
//        videoView
//            .didTapVideo
//            .sink {[unowned self] _ in
//                self.viewModel.didTapVideo()
//            }.store(in: &subscriptions)
    }
    
    func bindLoading() {
        viewModel.state
            .case { AuthorizationState.showLoading }
            .sink {[unowned self] show in
      //          show ? self.continueButton.setLoadingStatus(.loading) : self.continueButton.setLoadingStatus(.ready)
            }.store(in: &subscriptions)
    }

    func bindError() {
//        viewModel.state
//            .case(OnboardingState.showError)
//            .sink { [unowned self] errorViewModel in
//                guard var errorViewModel = errorViewModel else {
//                    self.showGenericErrorDialog(withDependenciesResolver: dependencies.external.resolve())
//                    return
//                }
//                if errorViewModel.floatingButtonAction == nil {
//                    errorViewModel.floatingButtonAction = resetView
//                }
//                errorView.setData(errorViewModel)
//                BottomSheet().show(in: self,
//                                   type: .custom(height: nil, isPan: true, bottomVisible: true),
//                                   component: errorViewModel.typeBottomSheet,
//                                   view: errorView)
//            }.store(in: &subscriptions)
    }
    
    func setAccessibilityIds() {
  //      self.descriptionLabel.accessibilityIdentifier = AccessibilitySkAutorization.descriptionLabel
    }    
}
