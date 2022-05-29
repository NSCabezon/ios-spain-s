import UIKit
import Transfer
import UI
import CoreFoundationLib

protocol OnePayTransferDestinationPresenterProtocol: Presenter, TransferDestinationPresenterProtocol {
    func didTapBack()
    func didTapClose()
    func didTapFaqs()
    func trackFaqEvent(_ question: String, url: URL?)
}

class OnePayTransferDestinationViewController: BaseViewController<OnePayTransferDestinationPresenterProtocol> {
    
    weak var dataViewController: TransferDestinationViewController!
    
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
        let dataViewController = TransferDestinationViewController(presenter: presenter)
        presenter.dataEntryView = dataViewController
        self.view.addSubview(dataViewController.view)
        dataViewController.view.translatesAutoresizingMaskIntoConstraints = false
        dataViewController.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        dataViewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        dataViewController.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        dataViewController.view.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.addChild(dataViewController)
        dataViewController.didMove(toParent: self)
        self.dataViewController = dataViewController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNavigationBar()
    }
    
    func setupNavigationBar() {
        let builder = NavigationBarBuilder(
            style: .sky,
            title: .titleWithHeader(titleKey: "toolbar_title_recipients",
                                    header: .title(key: "toolbar_title_moneyTransfers", style: .default))
        )
        builder.setLeftAction(
            .back(action: #selector(didTapBack))
        )
        builder.setRightActions(
            NavigationBarBuilder.RightAction.close(action: #selector(close)),
            NavigationBarBuilder.RightAction.help(action: #selector(faqs))
            )
        builder.build(on: self, with: nil)
    }
    
    @objc func didTapBack() {
        presenter.didTapBack()
    }
    
    @objc private func close() {
        presenter.didTapClose()
    }
    
    @objc private func faqs() {
        presenter.didTapFaqs()
    }
    
    func showFaqs(_ items: [FaqsItemViewModel]) {
        let data = FaqsViewData(items: items)
        data.show(in: self)
    }
}

extension OnePayTransferDestinationViewController: FaqsViewControllerDelegate {
    func didExpandAnswer(question: String) {
        presenter.trackFaqEvent(question, url: nil)
    }
    
    func didTapAnswerLink(question: String, url: URL) {
        presenter.trackFaqEvent(question, url: url)
    }
}

extension OnePayTransferDestinationViewController: TransferDestinationViewProtocol {
    func setAccountInfo(_ accountViewModel: SelectedAccountHeaderViewModel) {}
    func setIsSpanishResident(_ isResident: Bool) {}
    func setListFavourites(_ viewModels: [ContactViewModel], sepaInfoList: SepaInfoListEntity) {}
    func setLastTransfers(_ viewModels: [EmittedSepaTransferViewModel], isFavouritesCarrouselEnabled: Bool) {}
    func setHiddenLastTransfers() {}
    func updateContinueAction(_ enable: Bool) {}
    func addAliasTextValidation() {}
    func removeAliasTextValidation() {}
    func showInvalidIban(_ error: String) {}
    func hideInvalidIban() {}
    func updateBeneficiaryInfo(_ name: String?, iban: String?, alias: String?, isFavouriteSelected: Bool) {}
    func hideDestinationViews(isEnableResidence: Bool, isEnabledSelectorBusinessDateView: Bool) {}
    func setupPeriodicityModel(with model: SendMoneyPeriodicityViewModel) {}
    func setCountry(_ countryName: String) {}
    func configureIbanWithBankingUtils(_ bankingUtils: BankingUtilsProtocol,
                                       controlDigitDelegate: IbanCccTransferControlDigitDelegate?) {}
    func updateInfo() {}
    func setDateTypeSaved(dateTypeModel: SendMoneyDateTypeFilledViewModel) {}

    var associatedLoadingView: UIViewController {
        return self.dataViewController
    }
    func disableEditingDestinationInformation() {}
}
