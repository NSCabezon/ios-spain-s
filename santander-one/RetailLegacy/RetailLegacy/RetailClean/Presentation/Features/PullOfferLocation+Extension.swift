import CoreFoundationLib

extension Dictionary where Key == PullOfferLocation, Value == Offer {
    func contains(location: String) -> Bool {
        return contains(where: { $0.key.stringTag == location })
    }
    
    func location(key: String) -> (location: PullOfferLocation, offer: Offer)? {
        guard let location = self.first(where: { $0.key.stringTag == key }) else { return nil }
        return (location.key, location.value)
    }
}

public extension PullOfferLocation {
    
    //TODO: (EMMA_REPLACE) replaces emma event IDs for the targes
    static let globalPositionEventID: String = "69ab14945990e8331cf19e8a22361fa0"
    static let accountsEventID: String = "9b23acfd694b244edd21dec7f20875a1"
    static let cardsEventID: String = "59f215966bb34782685fa3fa7b27ea9b"
    static let transfersEventID: String = "83a265950fe58020f00dee1138ffb8d7"
    static let billAndTaxesEventID: String = "e4341a09ab8bf1779ad902dc9036a543"
    static let personalAreaEventID: String = "e4744e9e6b9a866a7d042f18260c1603"
    static let managerEventID: String = "e4d77ec3b0f72c2308107a600a74a09e"
    static let customerServiceEventID: String = "37d188dd073c18e390e889bf5da3881d"
    
    // MARK: Global Position Locations
    static let TUTORIAL = PullOfferLocation(stringTag: "TUTORIAL", hasBanner: true, pageForMetrics: TrackerPagePrivate.GlobalPosition(globalPositionEventID: globalPositionEventID).page)
    static let TUTORIAL_BEFORE_ONBOARDING = PullOfferLocation(stringTag: "TUTORIAL_BEFORE_ONBOARDING", hasBanner: true, pageForMetrics: TrackerPagePrivate.GlobalPosition(globalPositionEventID: "").page)
    static let PG_CTA = PullOfferLocation(stringTag: "PG_CTA", hasBanner: true, pageForMetrics: TrackerPagePrivate.GlobalPosition(globalPositionEventID: globalPositionEventID).page)
    static let PG_TAR = PullOfferLocation(stringTag: "PG_TAR", hasBanner: true, pageForMetrics: TrackerPagePrivate.GlobalPosition(globalPositionEventID: globalPositionEventID).page)
    static let PG_VAL = PullOfferLocation(stringTag: "PG_VAL", hasBanner: true, pageForMetrics: TrackerPagePrivate.GlobalPosition(globalPositionEventID: globalPositionEventID).page)
    static let PG_FON = PullOfferLocation(stringTag: "PG_FON", hasBanner: true, pageForMetrics: TrackerPagePrivate.GlobalPosition(globalPositionEventID: globalPositionEventID).page)
    static let PG_DEP = PullOfferLocation(stringTag: "PG_DEP", hasBanner: true, pageForMetrics: TrackerPagePrivate.GlobalPosition(globalPositionEventID: globalPositionEventID).page)
    static let PG_PLA = PullOfferLocation(stringTag: "PG_PLA", hasBanner: true, pageForMetrics: TrackerPagePrivate.GlobalPosition(globalPositionEventID: globalPositionEventID).page)
    static let PG_PRE = PullOfferLocation(stringTag: "PG_PRE", hasBanner: true, pageForMetrics: TrackerPagePrivate.GlobalPosition(globalPositionEventID: globalPositionEventID).page)
    static let PG_TOP = PullOfferLocation(stringTag: "PG_TOP", hasBanner: true, pageForMetrics: TrackerPagePrivate.GlobalPosition(globalPositionEventID: globalPositionEventID).page)
    static let PG_SAI = PullOfferLocation(stringTag: "PG_SAI", hasBanner: true, pageForMetrics: TrackerPagePrivate.GlobalPosition(globalPositionEventID: globalPositionEventID).page)
    static let PG_SPR = PullOfferLocation(stringTag: "PG_SPR", hasBanner: true, pageForMetrics: TrackerPagePrivate.GlobalPosition(globalPositionEventID: globalPositionEventID).page)
    static let PG_CTA_NO = PullOfferLocation(stringTag: "PG_CTA_NO", hasBanner: true, pageForMetrics: TrackerPagePrivate.GlobalPosition(globalPositionEventID: globalPositionEventID).page)
    static let PG_TAR_NO = PullOfferLocation(stringTag: "PG_TAR_NO", hasBanner: true, pageForMetrics: TrackerPagePrivate.GlobalPosition(globalPositionEventID: globalPositionEventID).page)
    static let PG_VAL_NO = PullOfferLocation(stringTag: "PG_VAL_NO", hasBanner: true, pageForMetrics: TrackerPagePrivate.GlobalPosition(globalPositionEventID: globalPositionEventID).page)
    static let PG_FON_NO = PullOfferLocation(stringTag: "PG_FON_NO", hasBanner: true, pageForMetrics: TrackerPagePrivate.GlobalPosition(globalPositionEventID: globalPositionEventID).page)
    static let PG_DEP_NO = PullOfferLocation(stringTag: "PG_DEP_NO", hasBanner: true, pageForMetrics: TrackerPagePrivate.GlobalPosition(globalPositionEventID: globalPositionEventID).page)
    static let PG_PLA_NO = PullOfferLocation(stringTag: "PG_PLA_NO", hasBanner: true, pageForMetrics: TrackerPagePrivate.GlobalPosition(globalPositionEventID: globalPositionEventID).page)
    static let PG_PRE_NO = PullOfferLocation(stringTag: "PG_PRE_NO", hasBanner: true, pageForMetrics: TrackerPagePrivate.GlobalPosition(globalPositionEventID: globalPositionEventID).page)
    static let PG_SAI_NO = PullOfferLocation(stringTag: "PG_SAI_NO", hasBanner: true, pageForMetrics: TrackerPagePrivate.GlobalPosition(globalPositionEventID: globalPositionEventID).page)
    static let PG_SPR_NO = PullOfferLocation(stringTag: "PG_SPR_NO", hasBanner: true, pageForMetrics: TrackerPagePrivate.GlobalPosition(globalPositionEventID: globalPositionEventID).page)
    static let PG_MINI_PFM = PullOfferLocation(stringTag: "PG_MINI_PFM", hasBanner: false, pageForMetrics: TrackerPagePrivate.GlobalPosition(globalPositionEventID: globalPositionEventID).page)
    static let HAPPY_BIRTHDAY = PullOfferLocation(stringTag: "HAPPY_BIRTHDAY", hasBanner: false, pageForMetrics: TrackerPagePrivate.GlobalPosition(globalPositionEventID: globalPositionEventID).page)
    static let PG_FLOATING_BANNER = PullOfferLocation(stringTag: "PG_FLOATING_BANNER", hasBanner: false, pageForMetrics: TrackerPagePrivate.GlobalPosition(globalPositionEventID: globalPositionEventID).page)
    
    // MARK: Customer Service
    static let CITA_OFICINA = PullOfferLocation(stringTag: "CITA_OFICINA", hasBanner: false, pageForMetrics: TrackerPagePrivate.CustomerService(customerServiceEventID: customerServiceEventID).page)
    
    // MARK: My Products
    static let MENU_RENTING = PullOfferLocation(stringTag: "MENU_RENTING", hasBanner: false, pageForMetrics: TrackerPagePrivate.Menu().page)
    static let MENU_TPV = PullOfferLocation(stringTag: "MENU_TPV", hasBanner: false, pageForMetrics: TrackerPagePrivate.Menu().page)
    
    // MARK: My Services
    static let TRAE_UN_AMIGO = PullOfferLocation(stringTag: "TRAE_UN_AMIGO", hasBanner: false, pageForMetrics: TrackerPagePrivate.Menu().page)
    
    // MARK: Private Side Menu
    static let PAGO_MOVIL = PullOfferLocation(stringTag: "PAGO_MOVIL", hasBanner: false, pageForMetrics: TrackerPagePrivate.Menu().page)
    static let MENU_MIGESTOR = PullOfferLocation(stringTag: "MENU_MIGESTOR", hasBanner: true, pageForMetrics: TrackerPagePrivate.Menu().page)
    static let SIDE_MENU_ONE1 = PullOfferLocation(stringTag: "SIDE_MENU_ONE1", hasBanner: false, pageForMetrics: TrackerPagePrivate.Menu().page)
    static let SIDE_MENU_ONE2 = PullOfferLocation(stringTag: "SIDE_MENU_ONE2", hasBanner: false, pageForMetrics: TrackerPagePrivate.Menu().page)
    static let HUELLA_CARBONO = PullOfferLocation(stringTag: "HUELLA_CARBONO", hasBanner: false, pageForMetrics: TrackerPagePrivate.Menu().page)
    static let MY_HOME_MENU = PullOfferLocation(stringTag: "MI_CASA_MENU", hasBanner: false, pageForMetrics: TrackerPagePrivate.Menu().page)
    
    // MARK: Private Side Menu - World 123
    static let MUNDO123_MENU_SIMULATE = PullOfferLocation(stringTag: "MUNDO123_MENU_SIMULATE", hasBanner: false, pageForMetrics: TrackerPagePrivate.Menu().page)
    static let MUNDO123_MENU_WHATHAVE = PullOfferLocation(stringTag: "MUNDO123_MENU_WHATHAVE", hasBanner: false, pageForMetrics: TrackerPagePrivate.Menu().page)
    static let MUNDO123_MENU_BENEFITS = PullOfferLocation(stringTag: "MUNDO123_MENU_BENEFITS", hasBanner: false, pageForMetrics: TrackerPagePrivate.Menu().page)
    static let MUNDO123_MENU_SIGNUP = PullOfferLocation(stringTag: "MUNDO123_MENU_SIGNUP", hasBanner: false, pageForMetrics: TrackerPagePrivate.Menu().page)
    
    // MARK: Personal Area
    static let RECOBRO = PullOfferLocation(stringTag: "RECOBRO", hasBanner: false, pageForMetrics: TrackerPagePrivate.PersonalArea.Action.recovery.rawValue)
    static let AREA_PERSONAL_ALERTAS_SSC = PullOfferLocation(stringTag: "AREA_PERSONAL_ALERTAS_SSC", hasBanner: false, pageForMetrics: TrackerPagePrivate.PersonalArea(personalAreaEventID: personalAreaEventID).page)
    static let DATOS_CONTACTO = PullOfferLocation(stringTag: "DATOS_CONTACTO", hasBanner: false, pageForMetrics: TrackerPagePrivate.PersonalArea(personalAreaEventID: personalAreaEventID).page)
    static let RENTA_ANUAL = PullOfferLocation(stringTag: "RENTA_ANUAL", hasBanner: false, pageForMetrics: TrackerPagePrivate.PersonalArea(personalAreaEventID: personalAreaEventID).page)
    static let GDPR = PullOfferLocation(stringTag: "GDPR", hasBanner: false, pageForMetrics: TrackerPagePrivate.PersonalArea(personalAreaEventID: personalAreaEventID).page)
    static let GESTION_FAVORITOS = PullOfferLocation(stringTag: "GESTION_FAVORITOS", hasBanner: false, pageForMetrics: TrackerPagePrivate.PersonalArea(personalAreaEventID: personalAreaEventID).page)
    static let SEGURIDAD_CAJA_FUERTE = PullOfferLocation(stringTag: "SEGURIDAD_CAJA_FUERTE", hasBanner: false, pageForMetrics: TrackerPagePrivate.PersonalArea(personalAreaEventID: personalAreaEventID).page)
    static let SEGURIDAD_CAJA_FUERTE_NO_ONE = PullOfferLocation(stringTag: "SEGURIDAD_CAJA_FUERTE_NO_ONE", hasBanner: false, pageForMetrics: TrackerPagePrivate.PersonalArea(personalAreaEventID: personalAreaEventID).page)
    // MARK: Office With Manager
    static let CITA_GESTOR_OFICINA = PullOfferLocation(stringTag: "CITA_GESTOR_OFICINA", hasBanner: false, pageForMetrics: TrackerPagePrivate.YourManagerOffice().page)
    
    // MARK: Account's Home
    static let SOLICITUD_MONEDA_EXTRANJERA = PullOfferLocation(stringTag: "SOLICITUD_MONEDA_EXTRANJERA", hasBanner: false, pageForMetrics: TrackerPagePrivate.Accounts(accountsEventID: accountsEventID).page)
    static let CTA_PFM = PullOfferLocation(stringTag: "CTA_PFM", hasBanner: false, pageForMetrics: TrackerPagePrivate.Accounts(accountsEventID: accountsEventID).page)
    
    // MARK: Card's Home
    static let REDONDEO_SOLIDARIO = PullOfferLocation(stringTag: "REDONDEO_SOLIDARIO", hasBanner: false, pageForMetrics: TrackerPagePrivate.Cards(cardsEventID: cardsEventID).page)
    
    // MARK: Fund's Home
    static let FONDO_SUSCRIPCION = PullOfferLocation(stringTag: "FONDO_SUSCRIPCION", hasBanner: false, pageForMetrics: TrackerPagePrivate.Funds().page)
    static let FONDO_TRASPASO = PullOfferLocation(stringTag: "FONDO_TRASPASO", hasBanner: false, pageForMetrics: TrackerPagePrivate.Funds().page)
    
    // MARK: Portfolio's Home
    static let FONDO_CARTERA_SUSCRIPCION = PullOfferLocation(stringTag: "FONDO_CARTERA_SUSCRIPCION", hasBanner: false, pageForMetrics: nil)
    static let FONDO_CARTERA_TRASPASO = PullOfferLocation(stringTag: "FONDO_CARTERA_TRASPASO", hasBanner: false, pageForMetrics: nil)
    static let PLAN_CARTERA_APORTACION_EXTRA = PullOfferLocation(stringTag: "PLAN_CARTERA_APORTACION_EXTRA", hasBanner: false, pageForMetrics: nil)
    static let PLAN_CARTERA_ALTA_APORTACION = PullOfferLocation(stringTag: "PLAN_CARTERA_ALTA_APORTACION", hasBanner: false, pageForMetrics: nil)
    
    // MARK: Transaction Detail
    static let MOV_TAR_DETAIL = PullOfferLocation(stringTag: "MOV_TAR_DETAIL", hasBanner: true, pageForMetrics: TrackerPagePrivate.CardTransactionDetail().page)
    static let MOV_CTA_DETAIL = PullOfferLocation(stringTag: "MOV_CTA_DETAIL", hasBanner: true, pageForMetrics: TrackerPagePrivate.AccountTransactionDetail().page)
    static let MOV_CTA_PFM = PullOfferLocation(stringTag: "MOV_CTA_PFM", hasBanner: false, pageForMetrics: TrackerPagePrivate.AccountTransactionDetail().page)
    
    // MARK: Insurances
    static let PR_INSURANCE_SETUP = PullOfferLocation(stringTag: "PR_INSURANCE_SETUP", hasBanner: false, pageForMetrics: TrackerPagePrivate.Insurance().page)
    static let SV_INSURANCE_CONTRIBUTION = PullOfferLocation(stringTag: "SV_INSURANCE_CONTRIBUTION", hasBanner: false, pageForMetrics: TrackerPagePrivate.InsuranceSaving().page)
    static let SV_INSURANCE_ACTIVATE_PLAN = PullOfferLocation(stringTag: "SV_INSURANCE_ACTIVATE_PLAN", hasBanner: false, pageForMetrics: TrackerPagePrivate.InsuranceSaving().page)
    static let SV_INSURANCE_CHANGE_PLAN = PullOfferLocation(stringTag: "SV_INSURANCE_CHANGE_PLAN", hasBanner: false, pageForMetrics: TrackerPagePrivate.InsuranceSaving().page)
    
    // MARK: Bill and Taxes
    static let DEVOLUCION_RECIBOS = PullOfferLocation(stringTag: "DEVOLUCION_RECIBOS", hasBanner: false, pageForMetrics: TrackerPagePrivate.BillAndTaxes(billAndTaxesEventID: billAndTaxesEventID).page)
    static let PAGO_RECIBOS_OTRAS = PullOfferLocation(stringTag: "PAGO_RECIBOS_OTRAS", hasBanner: false, pageForMetrics: TrackerPagePrivate.BillAndTaxes(billAndTaxesEventID: billAndTaxesEventID).page)
    static let PAGO_IMPUESTOS_EMISORA = PullOfferLocation(stringTag: "PAGO_IMPUESTOS_EMISORA", hasBanner: false, pageForMetrics: TrackerPagePrivate.BillAndTaxes(billAndTaxesEventID: billAndTaxesEventID).page)
    static let PAGO_RECIBOS_SOCIALES = PullOfferLocation(stringTag: "PAGO_RECIBOS_SOCIALES", hasBanner: false, pageForMetrics: TrackerPagePrivate.BillAndTaxes(billAndTaxesEventID: billAndTaxesEventID).page)
    static let PAGO_IBI_MADRID = PullOfferLocation(stringTag: "PAGO_IBI_MADRID", hasBanner: false, pageForMetrics: TrackerPagePrivate.BillAndTaxes(billAndTaxesEventID: billAndTaxesEventID).page)
    
    // MARK: Push Notifications
    static let INBOX_MESSAGES = PullOfferLocation(stringTag: "INBOX_MESSAGES", hasBanner: false, pageForMetrics: TrackerPagePrivate.Salesforce().page)
    static let INBOX_SETUP = PullOfferLocation(stringTag: "INBOX_SETUP", hasBanner: false, pageForMetrics: TrackerPagePrivate.Salesforce().page)
    static let BUZON_CONTRATOS_CARRUSEL = PullOfferLocation(stringTag: "BUZON_CONTRATOS_CARRUSEL", hasBanner: false, pageForMetrics: TrackerPagePrivate.Inbox().page)
    static let BUZON_EXTRACTOS = PullOfferLocation(stringTag: "BUZON_EXTRACTOS", hasBanner: false, pageForMetrics: TrackerPagePrivate.Inbox().page)
    static let BUZON_CONTRATOS = PullOfferLocation(stringTag: "BUZON_CONTRATOS", hasBanner: false, pageForMetrics: TrackerPagePrivate.Inbox().page)
    
    // MARK: Country Selector
    static let FXPAY = PullOfferLocation(stringTag: "FXPAY", hasBanner: true, pageForMetrics: TrackerPagePrivate.TransferCountrySelector().page)
    static let FXPAY_DIALOG = PullOfferLocation(stringTag: "FXPAY_DIALOG", hasBanner: false, pageForMetrics: TrackerPagePrivate.TransferAmountEntry().page)
    static let FXPAY_TRANSFER_HOME = PullOfferLocation(stringTag: "FXPAY_TRANSFER_HOME", hasBanner: false, pageForMetrics: TrackerPagePrivate.OnePayHome().page)
    static let TRANSFER_HOME_DONATIONS = PullOfferLocation(stringTag: "TRANSFER_HOME_DONATIONS", hasBanner: false, pageForMetrics: TrackerPagePrivate.OnePayHome().page)
    static let CORREOS_CASH_TRANSFER_HOME = PullOfferLocation(stringTag: "CORREOS_CASH_TRANSFER_HOME", hasBanner: false, pageForMetrics: TrackerPagePrivate.OnePayHome().page)
     
    // MARK: Product purchase
    static let CONTRATAR_CUENTAS = PullOfferLocation(stringTag: "CONTRATAR_CUENTAS", hasBanner: false, pageForMetrics: TrackerPagePrivate.Accounts(accountsEventID: accountsEventID).page)
    static let CONTRATAR_TARJETAS = PullOfferLocation(stringTag: "CONTRATAR_TARJETAS", hasBanner: false, pageForMetrics: TrackerPagePrivate.Cards(cardsEventID: cardsEventID).page)
    static let CONTRATAR_FONDOS = PullOfferLocation(
        stringTag: "CONTRATAR_FONDOS",
        hasBanner: false,
        pageForMetrics: TrackerPagePrivate.Funds().page
    )
    static let CONTRATAR_PLANES = PullOfferLocation(stringTag: "CONTRATAR_PLANES", hasBanner: false, pageForMetrics: TrackerPagePrivate.Pension().page)
    static let CONTRATAR_PRESTAMOS = PullOfferLocation(stringTag: "CONTRATAR_PRESTAMOS", hasBanner: false, pageForMetrics: TrackerPagePrivate.Loans().page)
    static let CONTRATAR_DEPOSITOS = PullOfferLocation(stringTag: "CONTRATAR_DEPOSITOS", hasBanner: false, pageForMetrics: TrackerPagePrivate.Deposit().page)
    
    // MARK: - Logout
    static let LOGOUT_DIALOG = PullOfferLocation(stringTag: "LOGOUT_DIALOG", hasBanner: true, pageForMetrics: TrackerPagePrivate.Menu().page)
    
    // MARK: - My Investments
    static let FIRMA_ORDENES = PullOfferLocation(stringTag: "FIRMA_ORDENES", hasBanner: false, pageForMetrics: TrackerPagePrivate.Menu().page)
    static let ORDENES_NO_ASESORADAS = PullOfferLocation(stringTag: "ORDENES_NO_ASESORADAS", hasBanner: false, pageForMetrics: TrackerPagePrivate.Menu().page)
    static let SOFIA_OPERAR = PullOfferLocation(stringTag: "SOFIA_OPERAR", hasBanner: false, pageForMetrics: TrackerPagePrivate.Menu().page)
    static let SOFIA_ORDENES = PullOfferLocation(stringTag: "SOFIA_ORDENES", hasBanner: false, pageForMetrics: TrackerPagePrivate.Menu().page)
    static let SOFIA_MOVIMIENTOS = PullOfferLocation(stringTag: "SOFIA_MOVIMIENTOS", hasBanner: false, pageForMetrics: TrackerPagePrivate.Menu().page)
    static let SOFIA_PROPUESTAS = PullOfferLocation(stringTag: "SOFIA_PROPUESTAS", hasBanner: false, pageForMetrics: TrackerPagePrivate.Menu().page)
    static let SOFIA_MERCADOS = PullOfferLocation(stringTag: "SOFIA_MERCADOS", hasBanner: false, pageForMetrics: TrackerPagePrivate.Menu().page)
    static let SOFIA_FAVORITOS = PullOfferLocation(stringTag: "SOFIA_FAVORITOS", hasBanner: false, pageForMetrics: TrackerPagePrivate.Menu().page)
    static let SOFIA_ANALISIS = PullOfferLocation(stringTag: "SOFIA_ANALISIS", hasBanner: false, pageForMetrics: TrackerPagePrivate.Menu().page)
    static let SOFIA_SMARTTRADER = PullOfferLocation(stringTag: "SOFIA_SMARTTRADER", hasBanner: false, pageForMetrics: TrackerPagePrivate.Menu().page)
    static let SOFIA_ORIENTA = PullOfferLocation(stringTag: "SOFIA_ORIENTA", hasBanner: false, pageForMetrics: TrackerPagePrivate.Menu().page)
    static let MENU_INVESTMENT_INVEST = PullOfferLocation(stringTag: "MENU_INVESTMENT_INVEST", hasBanner: false, pageForMetrics: TrackerPagePrivate.Menu().page)
    static let MENU_INVESTMENT_MIFID = PullOfferLocation(stringTag: "MENU_INVESTMENT_MIFID", hasBanner: false, pageForMetrics: TrackerPagePrivate.Menu().page)
    static let MENU_INVESTMENT_EBROKER = PullOfferLocation(stringTag: "MENU_INVESTMENT_EBROKER", hasBanner: false, pageForMetrics: TrackerPagePrivate.Menu().page)
    static let SIDE_INVESTMENT_MENU_MIFID_TEST = PullOfferLocation(stringTag: "SIDE_INVESTMENT_MENU_MIFID_TEST", hasBanner: false, pageForMetrics: TrackerPagePrivate.Menu().page)
    static let SIDE_INVESTMENT_MENU_FUNDS = PullOfferLocation(stringTag: "SIDE_INVESTMENT_MENU_FUNDS", hasBanner: false, pageForMetrics: TrackerPagePrivate.Menu().page)
    static let MENU_INVESTMENT_FOREIGN_EXCHANGE = PullOfferLocation(stringTag: "SIDE_MENU_INVESTMENT_FOREIGN_EXCHANGE", hasBanner: false, pageForMetrics: TrackerPagePrivate.Menu().page)
    static let MENU_INVESTMENT_PENSION = PullOfferLocation(stringTag: "SIDE_INVESTMENT_MENU_PENSION_PLANS", hasBanner: false, pageForMetrics: TrackerPagePrivate.Menu().page)
    static let MENU_INVESTMENT_ALERTS = PullOfferLocation(stringTag: "SIDE_MENU_INVESTMENT_ALERTS", hasBanner: false, pageForMetrics: TrackerPagePrivate.Menu().page)
    static let MENU_INVESTMENT_GUARANTEED = PullOfferLocation(stringTag: "SIDE_MENU_INVESTMENT_GUARANTEED", hasBanner: false, pageForMetrics: TrackerPagePrivate.Menu().page)
    static let SIDE_INVESTMENT_MENU_POSITION = PullOfferLocation(stringTag: "SIDE_INVESTMENT_MENU_POSITION", hasBanner: false, pageForMetrics: TrackerPagePrivate.Menu().page)
    static let SIDE_INVESTMENT_MENU_GUARANTEED = PullOfferLocation(stringTag: "SIDE_INVESTMENT_MENU_GUARANTEED", hasBanner: false, pageForMetrics: TrackerPagePrivate.Menu().page)
    static let SIDE_INVESTMENT_MENU_FOREINGN_EXCHANGE = PullOfferLocation(stringTag: "SIDE_INVESTMENT_MENU_FOREINGN_EXCHANGE", hasBanner: false, pageForMetrics: TrackerPagePrivate.Menu().page)
    static let SIDE_INVESTMENT_MENU_ALERTS = PullOfferLocation(stringTag: "SIDE_INVESTMENT_MENU_ALERTS", hasBanner: false, pageForMetrics: TrackerPagePrivate.Menu().page)
    static let SIDE_INVESTMENT_MENU_PENSION_PLANS = PullOfferLocation(stringTag: "SIDE_INVESTMENT_MENU_PENSION_PLANS", hasBanner: false, pageForMetrics: TrackerPagePrivate.Menu().page)
    static let SIDE_INVESTMENT_MENU_STOCKS = PullOfferLocation(stringTag: "SIDE_INVESTMENT_MENU_STOCKS", hasBanner: false, pageForMetrics: TrackerPagePrivate.Menu().page)
    static let SIDE_INVESTMENT_MENU_FIXED_RENT = PullOfferLocation(stringTag: "SIDE_INVESTMENT_MENU_FIXED_RENT", hasBanner: false, pageForMetrics: TrackerPagePrivate.Menu().page)
    static let SIDE_INVESTMENT_MENU_ROBOADVISOR = PullOfferLocation(stringTag: "SIDE_INVESTMENT_MENU_ROBOADVISOR", hasBanner: false, pageForMetrics: TrackerPagePrivate.Menu().page)

    // MARK: - Account easy pay
    static let EASY_PAY_LOW_AMOUNT_ACCOUNT = PullOfferLocation(stringTag: "EASY_PAY_LOW_AMOUNT", hasBanner: false, pageForMetrics: nil)
    static let EASY_PAY_HIGH_AMOUNT_ACCOUNT = PullOfferLocation(stringTag: "EASY_PAY_HIGH_AMOUNT", hasBanner: false, pageForMetrics: nil)
    static let EASY_PAY_LOW_AMOUNT_ACCOUNT_DETAIL = PullOfferLocation(stringTag: "EASY_PAY_LOW_AMOUNT", hasBanner: false, pageForMetrics: TrackerPagePrivate.AccountTransactionDetail().page)
    static let EASY_PAY_HIGH_AMOUNT_ACCOUNT_DETAIL = PullOfferLocation(stringTag: "EASY_PAY_HIGH_AMOUNT", hasBanner: false, pageForMetrics: TrackerPagePrivate.AccountTransactionDetail().page)
    static let EASY_PAY_LOW_AMOUNT_SUMMARY = PullOfferLocation(stringTag: "EASY_PAY_LOW_AMOUNT", hasBanner: false, pageForMetrics: TrackerPagePrivate.NationalTransferSummary().page)
    static let EASY_PAY_HIGH_AMOUNT_SUMMARY = PullOfferLocation(stringTag: "EASY_PAY_HIGH_AMOUNT", hasBanner: false, pageForMetrics: TrackerPagePrivate.NationalTransferSummary().page)

    // MARK: Stocks
    static let SOFIA_ORDENES_LIST = PullOfferLocation(stringTag: "SOFIA_ORDENES", hasBanner: false, pageForMetrics: TrackerPagePrivate.Stocks().page)
    static let SOFIA_BUY_LIST = PullOfferLocation(stringTag: "SOFIA_BUY", hasBanner: false, pageForMetrics: TrackerPagePrivate.Stocks().page)
    static let SOFIA_SELL_LIST = PullOfferLocation(stringTag: "SOFIA_SELL", hasBanner: false, pageForMetrics: TrackerPagePrivate.Stocks().page)
    static let SOFIA_SEARCH_LIST = PullOfferLocation(stringTag: "SOFIA_SEARCH", hasBanner: false, pageForMetrics: TrackerPagePrivate.Stocks().page)
    static let SOFIA_BUY_DETAIL = PullOfferLocation(stringTag: "SOFIA_BUY", hasBanner: false, pageForMetrics: TrackerPagePrivate.StocksDetailValue().page)
    static let SOFIA_SELL_DETAIL = PullOfferLocation(stringTag: "SOFIA_SELL", hasBanner: false, pageForMetrics: TrackerPagePrivate.StocksDetailValue().page)
    static let SOFIA_SEARCH_BUY = PullOfferLocation(stringTag: "SOFIA_SEARCH_BUY", hasBanner: false, pageForMetrics: TrackerPagePrivate.StocksDetailValue().page)
    static let SOFIA_SEARCH_SELL = PullOfferLocation(stringTag: "SOFIA_SEARCH_SELL", hasBanner: false, pageForMetrics: TrackerPagePrivate.StocksDetailValue().page)
    
    // MARK: - Public
    static let PUBLIC_TUTORIAL = PullOfferLocation(stringTag: "PUBLIC_TUTORIAL", hasBanner: false, pageForMetrics: TrackerPagePublic.LoginNotRemembered().page)
    static let PUBLIC_TUTORIAL_REC = PullOfferLocation(stringTag: "PUBLIC_TUTORIAL_REC", hasBanner: false, pageForMetrics: TrackerPagePublic.LoginRemembered().page)
    
    // MARK: - Home Products
    static let MANAGER_TUTORIAL = PullOfferLocation(stringTag: "MANAGER_TUTORIAL", hasBanner: false, pageForMetrics: TrackerPagePrivate.Manager().page)
    static let BILLS_TAXES_HOME_TUTORIAL = PullOfferLocation(stringTag: "BILLS_TAXES_HOME_TUTORIAL", hasBanner: false, pageForMetrics: TrackerPagePrivate.BillAndTaxes(billAndTaxesEventID: billAndTaxesEventID).page)
    static let ONE_PAY_HOME_TUTORIAL = PullOfferLocation(stringTag: "ONE_PAY_HOME_TUTORIAL", hasBanner: false, pageForMetrics: TrackerPagePrivate.OnePayHome().page)
    static let ACCOUNTS_HOME_TUTORIAL = PullOfferLocation(stringTag: "ACCOUNTS_HOME_TUTORIAL", hasBanner: false, pageForMetrics: TrackerPagePrivate.Accounts(accountsEventID: accountsEventID).page)
    static let CARDS_HOME_TUTORIAL = PullOfferLocation(stringTag: "CARDS_HOME_TUTORIAL", hasBanner: false, pageForMetrics: TrackerPagePrivate.Cards(cardsEventID: cardsEventID).page)
    
    // MARK: - Public
    static let ENVIO_DONACIONES = PullOfferLocation(stringTag: "ENVIO_DONACIONES", hasBanner: false, pageForMetrics: TrackerPagePrivate.Donation().page)
    static let SECURE_DEVICE_TUTORIAL_VIDEO = PullOfferLocation(stringTag: "SECURE_DEVICE_TUTORIAL_VIDEO", hasBanner: false, pageForMetrics: TrackerPagePrivate.SecurityArea().page)
    
    // MARK: - WithdrawMoneyWithCode
    static let CARD_WITHDRAW_MONEY_TOOLTIP_VIDEO = PullOfferLocation(stringTag: "CARD_WITHDRAW_MONEY_TOOLTIP_VIDEO", hasBanner: false, pageForMetrics: TrackerPagePrivate.CashWithdrawlCode().page)
    
    // MARK: - Sanflix
    static let CONTRATAR_SANFLIX = PullOfferLocation(stringTag: "CONTRATAR_SANFLIX", hasBanner: false, pageForMetrics: nil) //Deeplink
    static let MENU_CONTRATAR_SANFLIX = PullOfferLocation(stringTag: "MENU_CONTRATAR_SANFLIX", hasBanner: false, pageForMetrics: nil) //Private side menu
    static let OPERAR_CONTRATAR_TARJETAS = PullOfferLocation(stringTag: "OPERAR_CONTRATAR_TARJETAS", hasBanner: false, pageForMetrics: nil) //OperateView
    static let OPERAR_CONTRATAR_CUENTAS = PullOfferLocation(stringTag: "OPERAR_CONTRATAR_CUENTAS", hasBanner: false, pageForMetrics: nil) //OperateView
}

extension PullOfferLocation {
    var hashInt: Int {
        return stringTag.hashValue
    }
}

public extension PullOfferLocation {
    // MARK: - Operativa con préstamos
    static let OPERAR_AMORTIZACION_PARCIAL = PullOfferLocation(stringTag: "OPERAR_AMORTIZACION_PARCIAL", hasBanner: false, pageForMetrics: nil) //OperateView

    // MARK: - Operativa con fondos de inversión
    static let OPERAR_FONDO_SUSCRIPCION = PullOfferLocation(stringTag: "OPERAR_FONDO_SUSCRIPCION", hasBanner: false, pageForMetrics: nil) //OperateView
    static let OPERAR_FONDO_TRASPASO = PullOfferLocation(stringTag: "OPERAR_FONDO_TRASPASO", hasBanner: false, pageForMetrics: nil) //OperateView
}
