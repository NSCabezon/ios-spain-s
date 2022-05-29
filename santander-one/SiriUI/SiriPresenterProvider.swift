@available(iOS 12.0, *)
class SiriPresenterProvider {
    var noTokenPresenter: NoTokenPresenterProtocol {
        return NoTokenPresenter()
    }
    
    var noManagerPresenter: NoManagerPresenterProtocol {
        return NoManagerPresenter()
    }
    
    func getManagerPresenter(withIntentResponse intentResponse: CallToManagerIntentResponse) -> ManagerPresenterProtocol {
        return ManagerPresenter(intentResponse: intentResponse)
    }
}
