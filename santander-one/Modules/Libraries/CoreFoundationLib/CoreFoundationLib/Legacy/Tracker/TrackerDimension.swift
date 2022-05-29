import Foundation

public enum TrackerDimension {
    case amount
    case currency
    case participations
    case operationType
    case codError
    case descError
    case textSearch
    case accessLoginType
    case deeplinkLogin
    case offerId
    case tfno
    case productsId
    case location
    case cardType
    case categoryId
    case ticker
    case numPersonalManagers
    case numOfficeManagers
    case indUrgentTransferOmf
    case indReusedTransfer
    case progTransferType
    case transferType
    case scheduledTransferType
    case rememberUser
    case latitude
    case longitude
    case loginDocumentType
    case ideaIdentifier
    case language
    case pgType
    case photoType
    case months
    case managerType
    case billemitterPayment
    case travelType
    case billType
    case historicalTypeTransfer
    case operativityType
    case directAccess
    case operate
    case cardOperative
    case accountOperative
    case transactionType
    case searchType
    case billStatus
    case bizumDeliveryType
    case simpleMultipleType
    case bizumHistoricType
    case digitalProfileNotConfigured
    case tipName
    case searchedTerm
    case faqQuestion
    case faqLink
    case link
}

public extension TrackerDimension {
    var key: String {
        switch self {
        case .amount: return "importe"
        case .currency: return "divisa"
        case .participations: return "participaciones"
        case .operationType: return "tipo_operacion"
        case .codError: return "cod_error"
        case .descError: return "desc_error"
        case .textSearch: return "termino_busqueda"
        case .accessLoginType: return "tipo_acceso_login"
        case .deeplinkLogin: return "deeplink_login"
        case .offerId: return "id_oferta"
        case .tfno: return "telefono"
        case .productsId: return "products_id"
        case .location: return "location"
        case .cardType: return "tipo_tarjeta"
        case .categoryId: return "id_categoria"
        case .ticker: return "ticker"
        case .numPersonalManagers: return "num_gestores_sant_personal"
        case .numOfficeManagers: return "num_gestores_oficina"
        case .indUrgentTransferOmf: return "ind_transferencia_urgente_omf"
        case .indReusedTransfer: return "ind_transferencia_reutilizada"
        case .progTransferType: return "tipo_transferencia_programada"
        case .transferType: return "tipo_envio"
        case .scheduledTransferType: return "tipo_envio_programado"
        case .rememberUser: return "recordar_usuario"
        case .latitude: return "lat"
        case .longitude: return "long"
        case .loginDocumentType: return "tipo_documento"
        case .ideaIdentifier: return "id_idea"
        case .language: return "idioma"
        case .pgType: return "tipo_pg"
        case .photoType: return "tipo_foto"
        case .months: return "num_meses"
        case .managerType: return "tipo_gestor"
        case .billemitterPayment: return ""
        case .travelType: return "tipo_viaje"
        case .billType: return "tipo_recibo"
        case .historicalTypeTransfer: return "tipo_historico_transfe"
        case .operativityType: return "tipo_operatividad"
        case .directAccess: return "acceso_directo"
        case .operate: return "operar"
        case .cardOperative: return "operativa_tarjetas"
        case .accountOperative: return "operativa_cuentas"
        case .transactionType: return "tipo_movimiento"
        case .searchType: return "tipo_busqueda"
        case .billStatus: return "estado_recibos"
        case .bizumDeliveryType: return "tipo_envio_bizum"
        case .simpleMultipleType: return "tipo_simple_multiple"
        case .bizumHistoricType: return "tipo_bizum_historico"
        case .digitalProfileNotConfigured: return "opcion_perfil_digital_no_completada"
        case .tipName:  return "tip_name"
        case .searchedTerm: return "search_term"
        case .faqQuestion: return "faq_question"
        case .faqLink: return "faq_link"
        case .link: return "enlace"
        }
    }
}
