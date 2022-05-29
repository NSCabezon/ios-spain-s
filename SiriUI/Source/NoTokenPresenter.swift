protocol NoTokenPresenterProtocol {
    var title: String? { get }
    var message: String? { get }
    var bottom: String? { get }
}

class NoTokenPresenter {}

extension NoTokenPresenter: NoTokenPresenterProtocol {
    var title: String? {
        return "TU GESTOR PERSONAL"
    }
    var message: String? {
        return "Para poder llamar a tu gestor debes activar el acceso mediante Touch Id en la app"
    }
    var bottom: String? {
        return "Acceder a la app"
    }
}
