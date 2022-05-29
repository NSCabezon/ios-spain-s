import CoreFoundationLib

struct PullOffersLocationsFactory {
    var allTagsWithBanner: Set<String> {
        return PullOffersLocationsFactory().all.reduce(Set<String>()) { set, location in
            guard location.hasBanner else {
                return set
            }
            var modified = set
            modified.insert(location.stringTag)
            return modified
        }
    }
    
    var specificsLocations: [PullOfferLocation] {
        var specificLocations: [PullOfferLocation] = []
        specificLocations.append(contentsOf: transactionDetail)
        return Set(specificLocations).map { $0 }
    }
    
    var all: [PullOfferLocation] {
        var allLocations: [PullOfferLocation] = []
        allLocations.append(contentsOf: globalPosition)
        allLocations.append(contentsOf: world123SideMenu)
        allLocations.append(contentsOf: customerService)
        allLocations.append(contentsOf: myServices)
        allLocations.append(contentsOf: privateSideMenu)
        allLocations.append(contentsOf: personalArea)
        allLocations.append(contentsOf: officeWithManager)
        allLocations.append(contentsOf: cardsHome)
        allLocations.append(contentsOf: fundsHome)
        allLocations.append(contentsOf: portfoliosHome)
        allLocations.append(contentsOf: transactionDetail)
        allLocations.append(contentsOf: plansHome)
        allLocations.append(contentsOf: loansHome)
        allLocations.append(contentsOf: depositsHome)
        allLocations.append(contentsOf: logout)
        allLocations.append(contentsOf: sofiaInvestment)
        return Set(allLocations).map { $0 }
    }
    
    // MARK: PG LOCATIONS
    var globalPosition: [PullOfferLocation] {
        return [
            .PG_CTA,
            .PG_TAR,
            .PG_VAL,
            .PG_FON,
            .PG_DEP,
            .PG_PLA,
            .PG_PRE,
            .PG_TOP,
            .PG_SAI,
            .PG_SPR,
            .PG_CTA_NO,
            .PG_TAR_NO,
            .PG_VAL_NO,
            .PG_FON_NO,
            .PG_DEP_NO,
            .PG_PLA_NO,
            .PG_PRE_NO,
            .PG_SAI_NO,
            .PG_SPR_NO,
            .PG_MINI_PFM,
            .HAPPY_BIRTHDAY
        ]
    }
    
    // MARK: Customer Service
    var customerService: [PullOfferLocation] {
        return [.CITA_OFICINA]
    }
    
    // MARK: My Services
    var myServices: [PullOfferLocation] {
        return [.TRAE_UN_AMIGO]
    }
    
    // MARK: Private Side Menu
    var privateSideMenu: [PullOfferLocation] {
        let privateSide = [
            .FIRMA_ORDENES,
            .PAGO_MOVIL,
            .SIDE_MENU_ONE1,
            .SIDE_MENU_ONE2,
            .MENU_CONTRATAR_SANFLIX,
            .HUELLA_CARBONO,
            .MY_HOME_MENU
            ] as [PullOfferLocation]
        return privateSide + myProductsSideMenu + sofiaInvestment + world123SideMenu
    }
    
    var otherServicesSideMenu: [PullOfferLocation] {
        [.HUELLA_CARBONO]
    }
    
    var myProductsSideMenu: [PullOfferLocation] {
        [.MENU_TPV]
    }
    
    var world123SideMenu: [PullOfferLocation] {
        [.MUNDO123_MENU_SIMULATE,
         .MUNDO123_MENU_WHATHAVE,
         .MUNDO123_MENU_BENEFITS,
         .MUNDO123_MENU_SIGNUP]
    }
    
    // MARK: Personal Area
    var personalArea: [PullOfferLocation] {
        return [
            .RECOBRO,
            .AREA_PERSONAL_ALERTAS_SSC,
            .DATOS_CONTACTO,
            .RENTA_ANUAL,
            .GDPR,
            .GESTION_FAVORITOS
        ]
    }
    
    // MARK: Office With Manager
    var officeWithManager: [PullOfferLocation] {
        return [.CITA_GESTOR_OFICINA]
    }
    
    // MARK: Card's Home
    var cardsHome: [PullOfferLocation] {
        return [.REDONDEO_SOLIDARIO, .CONTRATAR_TARJETAS]
    }
    
    // MARK: Account's Home
    var accountsHome: [PullOfferLocation] {
        return [
            .SOLICITUD_MONEDA_EXTRANJERA,
            .CTA_PFM,
            .CONTRATAR_CUENTAS,
            .EASY_PAY_HIGH_AMOUNT_ACCOUNT,
            .EASY_PAY_LOW_AMOUNT_ACCOUNT
        ]
    }
    
    // MARK: Fund's Home
    var fundsHome: [PullOfferLocation] {
        return [
            .FONDO_SUSCRIPCION,
            .FONDO_TRASPASO,
            .CONTRATAR_FONDOS
        ]
    }
    
    // MARK: Pension plan's Home
    var plansHome: [PullOfferLocation] {
        return [ .CONTRATAR_PLANES ]
    }
    
    // MARK: Loan's Home
    var loansHome: [PullOfferLocation] {
        return [ .CONTRATAR_PRESTAMOS ]
    }
    
    // MARK: Deposit's Home
    var depositsHome: [PullOfferLocation] {
        return [ .CONTRATAR_DEPOSITOS ]
    }
    
    // MARK: Portfolio's Home
    var portfoliosHome: [PullOfferLocation] {
        return [
            .FONDO_CARTERA_SUSCRIPCION,
            .FONDO_CARTERA_TRASPASO,
            .PLAN_CARTERA_APORTACION_EXTRA,
            .PLAN_CARTERA_ALTA_APORTACION
        ]
    }
    
    var transactionDetail: [PullOfferLocation] {
        return [
            .MOV_TAR_DETAIL,
            .MOV_CTA_DETAIL,
            .MOV_CTA_PFM
        ]
    }
    
    var accountTransactionDetail: [PullOfferLocation] {
        return [
            .EASY_PAY_HIGH_AMOUNT_ACCOUNT_DETAIL,
            .EASY_PAY_LOW_AMOUNT_ACCOUNT_DETAIL
        ]
    }
    
    var transferSummary: [PullOfferLocation] {
        return [
            .EASY_PAY_HIGH_AMOUNT_SUMMARY,
            .EASY_PAY_LOW_AMOUNT_SUMMARY
        ]
    }
    
    // MARK: Portfolio's Home
    var insuranceHome: [PullOfferLocation] {
        return [
            .PR_INSURANCE_SETUP,
            .SV_INSURANCE_CONTRIBUTION,
            .SV_INSURANCE_ACTIVATE_PLAN,
            .SV_INSURANCE_CHANGE_PLAN
        ]
    }
    
    // MARK: BillsAndTaxes's Home
     var billsAndTaxes: [PullOfferLocation] {
        return [
            .DEVOLUCION_RECIBOS,
            .PAGO_RECIBOS_OTRAS,
            .PAGO_IMPUESTOS_EMISORA,
            .PAGO_RECIBOS_SOCIALES,
            .PAGO_IBI_MADRID
        ]
    }
    
    // MARK: PushNotifications's Home
    var pushNotifications: [PullOfferLocation] {
        return [
            .INBOX_MESSAGES,
            .INBOX_SETUP
        ]
    }
    
    // MARK: Country Selector's Home
    var countrySelector: [PullOfferLocation] {
        return [
            .FXPAY
        ]
    }
    
    // MARK: - Logout
    var logout: [PullOfferLocation] {
        return [
            .LOGOUT_DIALOG
        ]
    }
    
    // MARK: - FXPay
    var fxpayDialog: [PullOfferLocation] {
        return [
            .FXPAY_DIALOG,
            .FXPAY
        ]
    }
    
    // MARK: - Sofia Investment
    var sofiaInvestment: [PullOfferLocation] {
        return [
            .FIRMA_ORDENES,
            .ORDENES_NO_ASESORADAS,
            .SOFIA_OPERAR,
            .SOFIA_ORDENES,
            .SOFIA_MOVIMIENTOS,
            .SOFIA_PROPUESTAS,
            .SOFIA_MERCADOS,
            .SOFIA_FAVORITOS,
            .SOFIA_ANALISIS,
            .SOFIA_SMARTTRADER,
            .SOFIA_ORIENTA,
            .MENU_INVESTMENT_INVEST,
            .MENU_INVESTMENT_MIFID,
            .MENU_INVESTMENT_EBROKER,
            .SIDE_INVESTMENT_MENU_MIFID_TEST,
            .SIDE_INVESTMENT_MENU_FUNDS,
            .MENU_INVESTMENT_FOREIGN_EXCHANGE,
            .MENU_INVESTMENT_PENSION,
            .MENU_INVESTMENT_ALERTS,
            .MENU_INVESTMENT_GUARANTEED,
            .SIDE_INVESTMENT_MENU_POSITION,
            .SIDE_INVESTMENT_MENU_STOCKS,
            .SIDE_INVESTMENT_MENU_FIXED_RENT,
            .SIDE_INVESTMENT_MENU_GUARANTEED,
            .SIDE_INVESTMENT_MENU_FOREINGN_EXCHANGE,
            .SIDE_INVESTMENT_MENU_ALERTS,
            .SIDE_INVESTMENT_MENU_ROBOADVISOR
        ]
    }
    
    // MARK: Stocks's Home
    var stocksHome: [PullOfferLocation] {
        return [
            .SOFIA_ORDENES_LIST,
            .SOFIA_BUY_LIST,
            .SOFIA_SELL_LIST,
            .SOFIA_SEARCH_LIST
        ]
    }
    
    var stocksDetail: [PullOfferLocation] {
        return [
            .SOFIA_BUY_DETAIL,
            .SOFIA_SELL_DETAIL,
            .SOFIA_SEARCH_BUY,
            .SOFIA_SEARCH_SELL
        ]
    }
    
    // MARK: - Transfers home
    var transfersHome: [PullOfferLocation] {
        return [
            .FXPAY_TRANSFER_HOME
        ]
    }
    
    // MARK: - Public
    var loginRemembered: [PullOfferLocation] {
        return [
            .PUBLIC_TUTORIAL_REC
        ]
    }
    var loginUnremembered: [PullOfferLocation] {
        return [
            .PUBLIC_TUTORIAL
        ]
    }
    
    // MARK: Personal Manager's Home
    var tutorialPullOffers: [PullOfferLocation] {
        return [
            .MANAGER_TUTORIAL,
            .BILLS_TAXES_HOME_TUTORIAL,
            .ONE_PAY_HOME_TUTORIAL,
            .ACCOUNTS_HOME_TUTORIAL,
            .CARDS_HOME_TUTORIAL,
            .MENU_MIGESTOR
        ]
    }
    
    var personalManagerTutorial: PullOfferLocation {
        return .MANAGER_TUTORIAL
    }
    
    var billsAndTaxesHomeTutorial: PullOfferLocation {
        return .BILLS_TAXES_HOME_TUTORIAL
    }
    
    var onePayHomeTutorial: PullOfferLocation {
        return .ONE_PAY_HOME_TUTORIAL
    }
    
    var accountsHomeTutorial: PullOfferLocation {
        return .ACCOUNTS_HOME_TUTORIAL
    }
    
    var cardsHomeTutorial: PullOfferLocation {
        return .CARDS_HOME_TUTORIAL
    }
}
