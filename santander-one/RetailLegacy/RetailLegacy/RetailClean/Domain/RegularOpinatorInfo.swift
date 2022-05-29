import Foundation
import Operative
import CoreFoundationLib

struct RegularOpinatorInfo: OpinatorInfo {
    let titleKey: String
    let endPoint: String
    let params: [OpinatorParameter]
    let page: OpinatorPage
}

extension RegularOpinatorInfo {
    init(titleKey: String = "toolbar_title_improve", path: String, params: [OpinatorParameter] = [], page: OpinatorPage) {
        self.titleKey = titleKey
        self.endPoint = path
        self.params = params + [DomainOpinatorParameter.userId, DomainOpinatorParameter.appVersion,  DomainOpinatorParameter.language,  DomainOpinatorParameter.browser,  DomainOpinatorParameter.devicemodel,  DomainOpinatorParameter.os]
        self.page = page
    }
}

extension RegularOpinatorInfo {
    static var allCases: [RegularOpinatorInfo] {
        return [
            RegularOpinatorInfo(path: "appnew-general", page: .general),
            RegularOpinatorInfo(path: "app-bloqueo-tarjetas-exito", page: .blockCard),
            RegularOpinatorInfo(path: "app-tarjeta-on-off-exito", page: .onOffCard),
            RegularOpinatorInfo(path: "app-pago-facil-exito", page: .easyPay),
            RegularOpinatorInfo(path: "app-pago-luego-exito", page: .payLater),
            RegularOpinatorInfo(path: "app-dinero-directo-exito", page: .directMoney),
            RegularOpinatorInfo(path: "app-ingreso-tarjeta-exito", page: .payOff),
            RegularOpinatorInfo(path: "app-carga-ecash-exito", page: .ecashCharge),
            RegularOpinatorInfo(path: "app-descarga-ecash-exito", page: .ecashDischarge),
            RegularOpinatorInfo(path: "app-subscripcion-fondos-exito", page: .fundSubscription),
            RegularOpinatorInfo(path: "app-traspaso-fondos-no-carterizados-exito", page: .fundTransfer),
            RegularOpinatorInfo(path: "app-aportacion-extra-planes-exito", page: .pensionExtraordinaryContribution),
            RegularOpinatorInfo(path: "app-aportacion-periodica-planes-exito", page: .pensionPeriodicalContribution),
            RegularOpinatorInfo(path: "app-compra-valores-exito", page: .buyStocks),
            RegularOpinatorInfo(path: "app-venta-valores-exito", page: .sellStocks),
            RegularOpinatorInfo(path: "Cambio_Cuenta_Prestamo", page: .loanChangeAccount),
            RegularOpinatorInfo(path: "Amortiza_Prestamos", page: .loanPartialAmortization),
            RegularOpinatorInfo(path: "Recarga_Moviles/", page: .mobileRecharge),
            RegularOpinatorInfo(titleKey: "toolbar_title_valueManager", path: "Valoracion_Gestor/", params: [PresentationOpinatorParameter.codGest], page: .yourManager),
            RegularOpinatorInfo(path: "app-alta-ces-exito", page: .signCES),
            RegularOpinatorInfo(path: "app-extraer-dinero-cod-exito/", page: .cashWithdrawal),
            RegularOpinatorInfo(path: "app-traspasos-exito", page: .internalTransfer),
            RegularOpinatorInfo(path: "app-activar-tarjeta-exito", page: .activateCard),
            RegularOpinatorInfo(path: "app-transferencias-exito", page: .nationalTransfer),
            RegularOpinatorInfo(path: "app-trans-internac-exito", page: .internationalTransfer),
            RegularOpinatorInfo(path: "app-transfer-periodica-internl-exito", page: .internationalPeriodicTransfer),
            RegularOpinatorInfo(path: "app-transfer-diferida-internacional-exit", page: .internationalDeferredTransfer),
            RegularOpinatorInfo(path: "app-transfer-periodica-nacional-exito", page: .nationalPeriodicTransfer),
            RegularOpinatorInfo(path: "app-transfer-diferida-nacional-exito", page: .nationalDeferredTransfer),
            RegularOpinatorInfo(path: "app-transferencias-nacional-urgente", page: .urgentTransfer),
            RegularOpinatorInfo(path: "app-trans-nacional-inmediata/", page: .inmediateTransfer),
            RegularOpinatorInfo(path: "app-habituales-exito/", page: .usualTransfer),
            RegularOpinatorInfo(path: "app-reutilizacion-transferencia-exito", page: .reemittedTransfer),
            RegularOpinatorInfo(path: "app-internacional-reutilizada-exito", page: .internationalReemittedTransfer),
            RegularOpinatorInfo(path: "app-pago-recibos-exito", page: .payBills),
            RegularOpinatorInfo(path: "app-pago-tributos-exito", page: .payTaxes),
            RegularOpinatorInfo(path: "app-baja-transf-prog-exito", page: .cancelScheduledTransfer),
            RegularOpinatorInfo(path: "app-editar-transf-prog-exito", page: .modifyScheduledTransfer),
            RegularOpinatorInfo(path: "app-envio-no-sepa-exito", page: .noSepaSend),
            RegularOpinatorInfo(path: "app-traspaso-periodico-exito", page: .periodicInternalTransfer),
            RegularOpinatorInfo(path: "app-traspaso-diferido-exito", page: .deferredInternalTransfer),
            RegularOpinatorInfo(path: "app-cambio-forma-pago-exito", page: .changePaymentMethod),
            RegularOpinatorInfo(path: "app-gestion-limite-exito", page: .limitGestion),
            RegularOpinatorInfo(path: "app-duplicado-recibo-exito", page: .duplicateBill),
            RegularOpinatorInfo(path: "app-domiciliar-recibo-otra-cuenta-exito", page: .changeDirectDebit),
            RegularOpinatorInfo(path: "app-devolucion-recibos-exito", page: .receiptReturn),
            RegularOpinatorInfo(path: "app-anular-domiciliacion-recibo-exito", page: .cancelDirectBilling),
            RegularOpinatorInfo(path: "app-cambio-masivo-recibos-exito", page: .changeMassiveDirectDebit),
            RegularOpinatorInfo(path: "app-alta-fav-sepa-exito", page: .createSepaUsualTransfer),
            RegularOpinatorInfo(path: "app-alta-fav-NOSEPA-exito", page: .createNoSepaUsualTransfer),
            RegularOpinatorInfo(path: "app-baja-fav-SEPA-exito", page: .removeSepaUsualTransfer),
            RegularOpinatorInfo(path: "app-baja-fav-NOSEPA-exito", page: .removeNoSepaUsualTransfer),
            RegularOpinatorInfo(path: "app-modificar-fav-SEPA-exito", page: .updateSepaUsualTransfer),
            RegularOpinatorInfo(path: "app-modificar-fav-NOSEPA-exito", page: .updateNoSepaUsualTransfer),
            RegularOpinatorInfo(path: "app-reemision-fav-NOSEPA-exito", page: .noSepaReemittedTransfer),
            RegularOpinatorInfo(path: "app-envio-fav-NOSEPA-exito", page: .noSepaUsualTransfer)
        ]
    }
}
