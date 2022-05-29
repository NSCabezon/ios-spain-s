@available(iOS 12.0, *)
protocol NoManagerPresenterProtocol: class {
    var title: String? { get }
    var info: String? { get }
    var action: String? { get }
}

@available(iOS 12.0, *)
class NoManagerPresenter {
}

@available(iOS 12.0, *)
extension NoManagerPresenter: NoManagerPresenterProtocol {
    var title: String? {
        return "¿Aún sin gestor personal?"
    }
    
    var info: String? {
        return "Apúntate a Santander | Personal y tendrás tu propio gestor digital"
    }
    
    var action: String? {
        return "Dar de alta"
    }
}
