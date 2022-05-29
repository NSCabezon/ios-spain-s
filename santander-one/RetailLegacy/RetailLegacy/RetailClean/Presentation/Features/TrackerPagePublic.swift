public struct TrackerPagePublic {

    public struct CustomerService {
        public let page = "atencion_no_logado"
    }
    public struct LoginNotRemembered {
        public let page = "/login/unknown_user"
        public enum Action: String {
            case internalLogin = "login_attempt"
            case error = "error_{step1_step2}"
        }
    }
    public struct LoginRemembered {
        public let page = "/login/known_user"
        public enum Action: String {
            case internalLogin = "login_attempt"
            case error = "error_{step1_step2}"
        }
    }
    public struct PublicProducts {
        public let page = "home_publica_nuestros_productos"
        public enum Action: String {
            case selectProduct = "seleccionar_producto"
        }
    }
}
