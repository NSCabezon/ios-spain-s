import Foundation
import CoreFoundationLib

protocol DirectDebitPresenterProtocol: AnyObject {
    var view: DirectDebitViewProtocol? { get set }
    func viewDidLoad()
    func didSelectDirectDebit()
    func didSelectOpenUrl(with url: String)
}

final class DirectDebitPresenter {
    weak var view: DirectDebitViewProtocol?
    let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    private var configuration: DirectDebitConfiguration {
        return self.dependenciesResolver.resolve(for: DirectDebitConfiguration.self)
    }
    
    private var coordinatorDelegate: DirectDebitCoordinatorDelegate {
        return self.dependenciesResolver.resolve(for: DirectDebitCoordinatorDelegate.self)
    }
    
    private var getAppConfigUseCase: GetDirectDebitUrlsUseCase {
        return self.dependenciesResolver.resolve(for: GetDirectDebitUrlsUseCase.self)
    }
}

extension DirectDebitPresenter {
    func loadAppConfiguration(_ completion: @escaping (_ billsHomePensionUrl: String?, _ billsHomeUnemploymentBenefitUrl: String?) -> Void) {
        MainThreadUseCaseWrapper(
            with: getAppConfigUseCase,
            onSuccess: { response in
                completion(response.billsHomePensionUrl,
                           response.billsHomeUnemploymentBenefitUrl)
        })
    }
    
    func openUrl(with url: String) {
        guard let url = URL(string: url) else { return }
        UIApplication.shared.open(url)
    }
}

extension DirectDebitPresenter: DirectDebitPresenterProtocol {
    
    func viewDidLoad() {
        self.loadAppConfiguration { [weak self] billsHomePensionUrl, billsHomeUnemploymentBenefitUrl  in
            let viewModels = DirectDebitActionsViewModelBuilder()
                .addChangeDirectDebit(self?.configuration.account)
                .addPension(with: billsHomePensionUrl)
                .addUnemploymentBenefit(with: billsHomeUnemploymentBenefitUrl)
                .build()
            self?.view?.setDirectDebitViewModels(viewModels)
        }
    }
    
    func didSelectDirectDebit() {
        self.coordinatorDelegate.didSelectDirectDebit(accountEntity: self.configuration.account)
    }
    
    func didSelectOpenUrl(with url: String) {
        self.coordinatorDelegate.showAlertDialog(
            acceptTitle: localized("generic_button_understand"),
            cancelTitle: nil,
            title: localized("domicile_alert_title_openWeb"),
            body: localized("domicile_alert_text_openWeb"),
            acceptAction: { [weak self] in self?.openUrl(with: url) },
            cancelAction: nil
        )
    }
}
