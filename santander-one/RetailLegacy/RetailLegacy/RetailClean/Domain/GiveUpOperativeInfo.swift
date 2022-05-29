import Operative
import CoreFoundationLib

struct GiveUpOpinatorInfo: OpinatorInfo {
    let titleKey: String
    let endPoint: String
    let params: [OpinatorParameter]
    let page: OpinatorPage
}

extension GiveUpOpinatorInfo {
    init(titleKey: String = "toolbar_title_improve", path: String, params: [OpinatorParameter] = [], page: OpinatorPage) {
        self.titleKey = titleKey
        self.endPoint = path
        self.params = params + [DomainOpinatorParameter.userId, DomainOpinatorParameter.appVersion,  DomainOpinatorParameter.language,  DomainOpinatorParameter.browser,  DomainOpinatorParameter.devicemodel,  DomainOpinatorParameter.os]
        self.page = page
    }
    
    init?(regularOpinatorInfo: RegularOpinatorInfo) {
        guard regularOpinatorInfo.page != .general else {
            return nil
        }
        self.titleKey = regularOpinatorInfo.titleKey
        self.endPoint = GiveUpOpinatorInfo.takeUrl(fromRegularOpinatorInfo: regularOpinatorInfo)
        self.params = regularOpinatorInfo.params
        self.page = regularOpinatorInfo.page
    }
}

extension GiveUpOpinatorInfo {
    private static func takeUrl(fromRegularOpinatorInfo opinatorInfo: RegularOpinatorInfo) -> String {
        switch opinatorInfo.page {
        case .general:
            return ""
        case .nationalTransfer:
            return opinatorInfo.endPoint.replace("transferencias-exito", "transf-nacional-abandono")
        case .fundTransfer:
            return opinatorInfo.endPoint.replace("no-carterizados-exito", "nocarterizados-aband")
        case .usualTransfer:
            return opinatorInfo.endPoint.replace("habituales-exito", "envio-favorito-abandono")
        case .loanChangeAccount:
            return opinatorInfo.endPoint.replace("Cambio_Cuenta_Prestamo", "app-cambio-cuenta-abandono")
        case .loanPartialAmortization:
            return opinatorInfo.endPoint.replace("Amortiza_Prestamos", "app-amort-parcial-abandono")
        case .mobileRecharge:
            return opinatorInfo.endPoint.replace("Recarga_Moviles/", "app-recarga-movil-abandono")
        case .cashWithdrawal:
            return opinatorInfo.endPoint.replace("extraer-dinero-cod-exito", "santander-cash-abandono")
        case .changeDirectDebit:
            return opinatorInfo.endPoint.replace("exito", "aban")
        case .cancelDirectBilling:
            return opinatorInfo.endPoint.replace("exito", "aban")
        case .changeMassiveDirectDebit:
            return opinatorInfo.endPoint.replace("recibos-exito", "recibo-aban")
        default:
            return opinatorInfo.endPoint.replace("exito", "abandono")
        }
    }
}

extension GiveUpOpinatorInfo {
    static var allCases: [GiveUpOpinatorInfo] {
        let fromRegular: [GiveUpOpinatorInfo] = RegularOpinatorInfo.allCases.compactMap {
            guard let info = GiveUpOpinatorInfo(regularOpinatorInfo: $0) else {
                return nil
            }
            return info
        }
        
        return fromRegular + [
            GiveUpOpinatorInfo(path: "app-consulta-pin-abandono", page: .requestPin),
            GiveUpOpinatorInfo(path: "app-consulta-cvv-abandono", page: .requestCvv),
            GiveUpOpinatorInfo(path: "app-bloqueo-tarjetas-abandono", page: .blockCard),
            GiveUpOpinatorInfo(path: "app-ecash-generica-abandono", page: .ecashGeneric),
            GiveUpOpinatorInfo(path: "app-valores-generica-abandono", page: .tradeStocks),
            GiveUpOpinatorInfo(path: "app-editar-transf-prog-abandono", page: .modifyScheduledTransfer),
            GiveUpOpinatorInfo(path: "app-baja-transf-prog-abandono", page: .cancelTransfer),
            GiveUpOpinatorInfo(path: "app-aportacion-extra-planes-abandono", page: .pensionExtraordinaryContribution),
            GiveUpOpinatorInfo(path: "app-gestion-limite-abandono", page: .limitGestion),
            GiveUpOpinatorInfo(path: "app-cambio-forma-pago-abandono", page: .changePaymentMethod)
        ]
    }
}
