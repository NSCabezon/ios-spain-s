import UI
import UIKit
import CoreFoundationLib
import Foundation
import OpenCombine
import UIOneComponents
import ESUI
import Operative

final class SKRegisteredAnotherDeviceViewController: UIViewController, GenericErrorDialogPresentationCapable {
    @IBOutlet var imageviewLock: UIImageView!
    @IBOutlet var buttonLink: OneFloatingButton!
    @IBOutlet var buttonLater: OneAppLink!
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var labelSubtitle: UILabel!
    @IBOutlet var buttonMoreInfo: UIButton!
    @IBOutlet var buttonClose: UIButton!
    @IBOutlet var viewGradient: OneGradientView!

    private let viewModel: SKRegisteredAnotherDeviceViewModel
    private var subscriptions: Set<AnyCancellable> = []
    private let dependencies: SKRegisteredAnotherDeviceDependenciesResolver
    private let errorView = OneOperativeAlertErrorView()

    init(dependencies: SKRegisteredAnotherDeviceDependenciesResolver) {
        self.dependencies = dependencies
        self.viewModel = dependencies.resolve()
        super.init(nibName: "SKRegisteredAnotherDeviceViewController", bundle: .module)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setAppearance()
        setAccessibilityIds()
        bind()
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        setPopGestureEnabled(false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
        setPopGestureEnabled(true)
    }

    @IBAction func didTapMoreInfo(_ sender: Any) {
        showBottomSheet()
    }

    @IBAction func didTapClose(_ sender: Any) {
        viewModel.close()
    }

    @IBAction func didTapLink(_ sender: Any) {
        viewModel.didSelectLinkButton()
    }

    @IBAction func didTouchLater(_ sender: Any) {
        viewModel.didSelectLaterButton()
    }
}

private extension SKRegisteredAnotherDeviceViewController {
    func setAppearance() {
        setButtons()
        setGradientView()
        setMessage()
    }

    func setGradientView() {
        viewGradient.setupType(.oneGrayGradient(direction: .bottomToTop))
    }

    func setMessage() {
        imageviewLock.image = ESAssets.image(named: "one_icn_san_key_danger")
        let configuration = LocalizedStylableTextConfiguration(font: .santander(family: .headline, type: .bold, size: 24), alignment: NSTextAlignment(CTTextAlignment.center))
        let inDevice = viewModel.checkSKinDevice()
        labelTitle.configureText(withLocalizedString: inDevice ? localized("sanKey_title_userRegisteredDevice") : localized("sanKey_title_registeredAnotherDevice"), andConfiguration: configuration)
        labelTitle.textColor = .lisboaGray
        let configurationBody = LocalizedStylableTextConfiguration(font: .santander(family: .headline, type: .regular, size: 24), alignment: NSTextAlignment(CTTextAlignment.center))
        labelSubtitle.configureText(withLocalizedString:  inDevice ? localized("sanKey_text_linkYourDevice") : localized("sanKey_text_linkNewDevice"), andConfiguration: configurationBody)
        labelSubtitle.textColor = .lisboaGray
    }

    func setButtons() {
        buttonMoreInfo.setTitle(localized("ganeric_label_knowMore"), for: .normal)
        buttonMoreInfo.setTitleColor(.darkTorquoise, for: .normal)
        buttonMoreInfo.titleLabel?.font = UIFont.santander(family: .text, type: .bold, size: 14)
        buttonMoreInfo.titleLabel?.numberOfLines = 1
        buttonClose.setImage(ESAssets.image(named: "one_icn_close"), for: .normal)
        buttonClose.tintColor = .black
        buttonLink.configureWith(
            type: .primary,
            size: .medium(
                OneFloatingButton.ButtonSize.MediumButtonConfig(
                    title: localized("sanKey_button_activateSanKey"),
                    icons: .none,
                    fullWidth: false)),
            status: .ready)
        buttonLater.configureButton(
            type: .primary,
            style: OneAppLink.ButtonContent(
                text: localized("generic_button_inAnotherMoment"),
                icons: OneAppLink.ButtonContent.ButtonIcons.none))
    }

    func bind() {
        bindLoading()
        bindError()
        bindAlertView()
    }

    func bindLoading() {
        viewModel.state
            .case { SKRegisteredAnotherDeviceState.showLoading }
            .sink {[unowned self] show in
                show ? self.buttonLink.setLoadingStatus(.loading) : self.buttonLink.setLoadingStatus(.ready)
            }.store(in: &subscriptions)
    }
    
    func bindError() {
        viewModel.state
            .case(SKRegisteredAnotherDeviceState.showError)
            .sink { [unowned self] errorViewModel in
                guard var errorViewModel = errorViewModel else {
                    self.showGenericErrorDialog(withDependenciesResolver: dependencies.external.resolve())
                    return
                }
                
                errorView.setData(errorViewModel)
                BottomSheet().show(in: self,
                                   type: .custom(height: nil, isPan: true, bottomVisible: true),
                                   component: errorViewModel.typeBottomSheet,
                                   view: errorView)
            }.store(in: &subscriptions)
    }
    
    func bindAlertView() {
        errorView.publisher
            .case(ReactiveOneOperativeAlertErrorViewState.didTapAcceptButton)
            .sink { [unowned self] action in
                dismiss(animated: true) {
                    action?()
                }
            }.store(in: &subscriptions)
    }

    func setAccessibilityIds() {
        self.imageviewLock.accessibilityIdentifier = AccessibilitySKRegisteredAnotherDevice.imageView
        self.labelTitle.accessibilityIdentifier = AccessibilitySKRegisteredAnotherDevice.labelTitle
        self.labelTitle.accessibilityIdentifier = AccessibilitySKRegisteredAnotherDevice.labelSubtitle
        self.buttonMoreInfo.accessibilityIdentifier = AccessibilitySKRegisteredAnotherDevice.moreInfoButton
        self.buttonClose.accessibilityIdentifier = AccessibilitySKRegisteredAnotherDevice.closeButton
    }

    func showBottomSheet() {
        guard let navigation = navigationController else { return }
        let bottomSheet = BottomSheet()
        bottomSheet.show(in: navigation, type: .custom(isPan: true), component: .all, view: SKFirstScreenKnowMore())
    }
}
