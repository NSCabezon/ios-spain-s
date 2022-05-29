struct TrackerPageCommon {

    struct CustomerService {
        let page = "atencion_logado"
        enum Action: String {
            case call = "llamar"
            case mail = "escribir_mail"
            case google = "google_plus"
            case whatsapp = "whatsapp_copiar"
            case facebook = "facebook"
            case twitter = "twitter"
            case chat = "chat"
            case help = "te_ayudamos"
            case date = "cita_oficina"
        }
    }

}
