@available(iOS 12.0, *)
protocol ManagerPresenterProtocol: class {
    var title: String? { get }
    var photo: String? { get }
    var name: String? { get }
    var phone: String? { get }
    var info: String? { get }
}

@available(iOS 12.0, *)
class ManagerPresenter {
    private let intentResponse: CallToManagerIntentResponse
    
    init(intentResponse: CallToManagerIntentResponse) {
        self.intentResponse = intentResponse
    }
}

@available(iOS 12.0, *)
extension ManagerPresenter: ManagerPresenterProtocol {
    var title: String? {
        return "TU GESTOR PERSONAL"
    }
    var photo: String? {
        return intentResponse.managerCode
    }
    var name: String? {
        return intentResponse.availableName
    }
    var phone: String? {
        return intentResponse.availablePhone
    }
    var info: String? {
        return "Información y atención las 24h"
    }
}
