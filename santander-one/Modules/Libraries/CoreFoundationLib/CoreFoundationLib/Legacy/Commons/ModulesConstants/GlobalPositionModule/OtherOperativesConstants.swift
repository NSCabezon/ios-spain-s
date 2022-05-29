
public struct OtherOperativesPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "/operation"
    
    public enum Action: String {
        case action = "accion"
        case tapInTip = "click_tip"
    }
    public init() {}
}

public struct OperatePullOffers {
    public static let foreignCurrencyOperate = "OPERAR_SOLICITUD_MONEDA_EXTRANJERA"
    public static let donationsOperate = "OPERAR_DONACIONES"
    public static let solidarityOperate = "OPERAR_REDONDEO_SOLIDARIO"
    public static let cardContractOperate = "OPERAR_CONTRATAR_TARJETAS"
    public static let accountContractOperate = "OPERAR_CONTRATAR_CUENTAS"
    public static let fxPayOperate = "OPERAR_FXPAY"
    public static let inboxOperate = "OPERAR_INBOX_SETUP"
    public static let insuranceContributionOperate = "OPERAR_SV_INSURANCE_CONTRIBUTION"
    public static let insuranceChangePlanOperate = "OPERAR_SV_INSURANCE_CHANGE_PLAN"
    public static let insuranceActivatePlanOperate = "OPERAR_SV_INSURANCE_ACTIVATE_PLAN"
    public static let insurcanceSetupOperate = "OPERAR_PR_INSURANCE_SETUP"
    public static let suscriptionFundOperate = "OPERAR_FONDO_SUSCRIPCION"
    public static let internalTransferFundOperate = "OPERAR_FONDO_TRASPASO"
    public static let ownershipCertificateOperate = "CERTIFICATE_ACCOUNT_BUTTON"
    public static let transferOfContractsOperate = "OPERAR_TRASLADO_CONTRATOS"
    public static let officeAppointmentOperate = "OPERAR_OFFICE_APPOINTMENT"
}

public struct OperateConstants {
    public static let appConfigInsuranceDetailEnabled = "enabledInsuranceDetail"
}
