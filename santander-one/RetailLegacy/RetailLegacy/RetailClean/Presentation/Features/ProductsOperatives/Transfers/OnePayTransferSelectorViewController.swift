import UIKit
import Transfer
import UI
import CoreFoundationLib

protocol OnePayTransferSelectorPresenterProtocol: Presenter, TransferGenericAmountEntryPresenterProtocol {
    var dependenciesResolver: DependenciesResolver { get }
    func didTapBack(amount: String?, concept: String?)
    func didTapFaqs()
    func didTapClose()
    func trackFaqEvent(_ question: String, url: URL?)
}

class OnePayTransferSelectorViewController: BaseViewController<OnePayTransferSelectorPresenterProtocol> {
    
    weak var entryDataViewController: TransferGenericAmountEntryViewController!
    
    override class var storyboardName: String {
        return "TransferOperatives"
    }
        
    override var progressBarBackgroundColor: UIColor? {
        return .sky30
    }
    
    override var navigationBarStyle: NavigationBarBuilder.Style {
        return .sky
    }
    
    override func prepareView() {
        super.prepareView()
        let entryDataViewController = TransferGenericAmountEntryViewController(presenter: presenter, dependenciesResolver: self.dependenciesResolver)
        presenter.dataEntryView = entryDataViewController
        self.view.addSubview(entryDataViewController.view)
        entryDataViewController.view.translatesAutoresizingMaskIntoConstraints = false
        entryDataViewController.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        entryDataViewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        entryDataViewController.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        entryDataViewController.view.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.addChild(entryDataViewController)
        entryDataViewController.didMove(toParent: self)
        self.entryDataViewController = entryDataViewController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
    }
    
    func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .titleWithHeader(titleKey: "toolbar_title_amount",
                                    header: .title(key: "toolbar_title_moneyTransfers", style: .default))
        )
        builder.setLeftAction(.back(action: #selector(didTapBack)))
        builder.setRightActions(
            NavigationBarBuilder.RightAction.close(action: #selector(close)),
            NavigationBarBuilder.RightAction.help(action: #selector(faqs))
        )
        builder.build(on: self, with: nil)
    }
    
    @objc func didTapBack() {
        let parameter = entryDataViewController.getAmountAndConcept()
        presenter.didTapBack(amount: parameter.0, concept: parameter.1)
    }
    
    @objc func faqs() {
        presenter.didTapFaqs()
    }
    
    @objc func close() {
        presenter.didTapClose()
    }
}

extension OnePayTransferSelectorViewController: FaqsViewControllerDelegate {
    func didExpandAnswer(question: String) {
        presenter.trackFaqEvent(question, url: nil)
    }
    
    func didTapAnswerLink(question: String, url: URL) {
        presenter.trackFaqEvent(question, url: url)
    }
}

extension OnePayTransferSelectorViewController: TransferGenericAmountEntryViewProtocol {
    
    func showInvalidAmount(_ error: String) {
        // This is not neccessary, the good ViewController is TransferGenericAmountEntryViewController
    }

    func clearInvalidAmount() {
        // This is not neccessary, the good ViewController is TransferGenericAmountEntryViewController
    }

    func updateContinueAction(_ enable: Bool) {
        // This is not neccessary, the good ViewController is TransferGenericAmountEntryViewController
    }

    func setLocationsCandidates(_ locations: [PullOfferLocation: OfferEntity]) {
        // This is not neccessary, the good ViewController is TransferGenericAmountEntryViewController
    }
    
    func setCountryAndCurrencyInfo(_ sepaInfoList: SepaInfoListEntity, countrySelected: SepaCountryInfoEntity, currencySelected: SepaCurrencyInfoEntity) {
        // This is not neccessary, the good ViewController is TransferGenericAmountEntryViewController
    }    
    func setAccountInfo(_ accountViewModel: SelectedAccountHeaderViewModel) {
        // This is not neccessary, the good ViewController is TransferGenericAmountEntryViewController
    }
    var associatedLoadingView: UIViewController {
        return self.entryDataViewController
    }
    func showFaqs(_ items: [FaqsItemViewModel]) {
        let data = FaqsViewData(items: items)
        data.show(in: self)
    }
    
    func setAmountAndConcept(amount: Decimal?, concept: String?) {
        // This is not neccessary, the good ViewController is TransferGenericAmountEntryViewController
    }
    
    func disableDestinationCountrySelection() {
    }
    
    func disableAmountSelection() {
    }
}

private extension OnePayTransferSelectorViewController {
    var dependenciesResolver: DependenciesResolver {
        return self.presenter.dependenciesResolver
    }
}

extension OnePayTransferSelectorViewController: DialogViewPresentationCapable {
    public var associatedDialogView: UIViewController {
        self
    }
    
    func showAlertInternationalTransfer(action: @escaping () -> Void) {
        let text = localized(key: "onePayIntSepa_title_collectionsAndPays")
        let descriptionTextConfiguration =
            LocalizedStylableTextConfiguration(font: UIFont.santander(size: 27),
                                               textStyles: [.init(start: 0,
                                                                  length: text.text.count,
                                                                  attribute: .color(hex: "000000"))],
                                               alignment: .center,
                                               lineHeightMultiple: 0.7,
                                               lineBreakMode: .byWordWrapping)
        HapticTrigger.alert()
        showDialog(items: [.styledConfiguredText(text,
                                                 configuration: descriptionTextConfiguration),
                           .text("onePayIntSepa_label_collectionsAndPays")],
                   image: nil,
                   action: .some(.init(title: "generic_button_understand",
                                       style: .red,
                                       action: action)),
                   isCloseOptionAvailable: false)
    }
}

