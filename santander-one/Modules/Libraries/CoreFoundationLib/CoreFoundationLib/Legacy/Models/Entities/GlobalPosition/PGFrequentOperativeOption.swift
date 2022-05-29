import CoreDomain

public protocol GetPGFrequentOperativeOptionProtocol {
    func get(globalPositionType: GlobalPositionOptionEntity?) -> [PGFrequentOperativeOptionProtocol]
    func getDefault() -> [PGFrequentOperativeOptionProtocol]
}

public enum PGFrequentOperativeOptionAction {
    case core(option: PGFrequentOperativeOption)
    case custom(action: () -> Void)
}

public enum PGFrequentOperativeOptionEnabled {
    case core(option: PGFrequentOperativeOption)
    case custom(enabled: () -> Bool)
}

public protocol PGFrequentOperativeOptionProtocol {
    var rawValue: String { get }
    var accessibilityIdentifier: String? { get }
    var trackName: String? { get }
    func getViewType(isSmartGP: Bool) -> ActionButtonFillViewType
    func getViewType(isSmartGP: Bool, valuesProvider: PGFrequentOperativeOptionValueProviderProtocol?) -> ActionButtonFillViewType
    func getAction() -> PGFrequentOperativeOptionAction
    func getEnabled() -> PGFrequentOperativeOptionEnabled
    func getLocation() -> String?
}

public extension PGFrequentOperativeOptionProtocol {
    func getViewType(isSmartGP: Bool, valuesProvider: PGFrequentOperativeOptionValueProviderProtocol?) -> ActionButtonFillViewType {
        return getViewType(isSmartGP: isSmartGP)
    }
}

enum AccessibilityPGFrequentOperatives: String {
    case btnSendMoney
    case btnApply
    case btnBill
    case btnTransferAcount
    case btnMarket
    case btnAnalysis
    case btnDiaryFinancial
    case btnSuscription
    case btnSupport
    case btnInvestmentPosition
    case btnHelpUsSlidebar
    case btnShareholders
    case btnAtm
    case btnSettingOperation
    case btnMyManager
    case btnFunds
    case btnAddbanks
    case btnFinancialAnalysis
    case btnFinancialTips
    case btnFinancing
    case btnConsultPin
    case btnOnePlan
    case btnShortcut
    case btnCorreosCash
    case btnAppointmentInOffice
    case btnInvestmentsPorposals
    case btnAutomaticOperations
    case btnCarbonFootprint
}

public enum PGFrequentOperativeOption: String, CaseIterable, Codable {
    case operate
    case contract
    case billTax
    case sendMoney
    case marketplace
    case analysisArea
    case financialAgenda
    case suscription
    case customerCare
    case investmentPosition
    case impruve
    case stockholders
    case atm
    case personalArea
    case myManage
    case addBanks
    case financialAnalysis
    case financialTips
    case financing
    case onePlan
    case consultPin
    case shortcut
    case correosCash
    case officeAppointment
    case investmentsProposals
    case automaticOperations
    case carbonFootprint
}

struct PGFrequentOperativeOptionValues {
    let title: String
    let imageName: String
    let accessibilityName: String
}

extension PGFrequentOperativeOption: PGFrequentOperativeOptionProtocol {
    public var accessibilityIdentifier: String? {
        switch self {
        case .operate:
            return AccessibilityPGFrequentOperatives.btnSendMoney.rawValue
        case .contract:
            return AccessibilityPGFrequentOperatives.btnApply.rawValue
        case .billTax:
            return AccessibilityPGFrequentOperatives.btnBill.rawValue
        case .sendMoney:
            return AccessibilityPGFrequentOperatives.btnTransferAcount.rawValue
        case .marketplace:
            return AccessibilityPGFrequentOperatives.btnMarket.rawValue
        case .analysisArea:
            return AccessibilityPGFrequentOperatives.btnAnalysis.rawValue
        case .financialAgenda:
            return AccessibilityPGFrequentOperatives.btnDiaryFinancial.rawValue
        case .suscription:
            return AccessibilityPGFrequentOperatives.btnSuscription.rawValue
        case .customerCare:
            return AccessibilityPGFrequentOperatives.btnSupport.rawValue
        case .investmentPosition:
            return AccessibilityPGFrequentOperatives.btnInvestmentPosition.rawValue
        case .impruve:
            return AccessibilityPGFrequentOperatives.btnHelpUsSlidebar.rawValue
        case .stockholders:
            return AccessibilityPGFrequentOperatives.btnShareholders.rawValue
        case .atm:
            return AccessibilityPGFrequentOperatives.btnAtm.rawValue
        case .personalArea:
            return AccessibilityPGFrequentOperatives.btnSettingOperation.rawValue
        case .myManage:
            return AccessibilityPGFrequentOperatives.btnMyManager.rawValue
        case .addBanks:
            return AccessibilityPGFrequentOperatives.btnAddbanks.rawValue
        case .financialAnalysis:
            return AccessibilityPGFrequentOperatives.btnFinancialAnalysis.rawValue
        case .financialTips:
            return AccessibilityPGFrequentOperatives.btnFinancialTips.rawValue
        case .financing:
            return AccessibilityPGFrequentOperatives.btnFinancing.rawValue
        case .consultPin:
            return AccessibilityPGFrequentOperatives.btnConsultPin.rawValue
        case .onePlan:
            return AccessibilityPGFrequentOperatives.btnOnePlan.rawValue
        case .shortcut:
            return AccessibilityPGFrequentOperatives.btnShortcut.rawValue
        case .correosCash:
            return AccessibilityPGFrequentOperatives.btnCorreosCash.rawValue
        case .officeAppointment:
            return AccessibilityPGFrequentOperatives.btnAppointmentInOffice.rawValue
        case .investmentsProposals:
            return AccessibilityPGFrequentOperatives.btnInvestmentsPorposals.rawValue
        case .automaticOperations:
            return AccessibilityPGFrequentOperatives.btnAutomaticOperations.rawValue
        case .carbonFootprint:
            return AccessibilityPGFrequentOperatives.btnCarbonFootprint.rawValue
        }
    }
    public var trackName: String? {
        switch self {
        case .operate: return "operar"
        case .contract: return "contratar"
        case .billTax: return "recibos"
        case .sendMoney: return "enviar_dinero"
        case .marketplace: return "santander_shopping"
        case .analysisArea: return "analisis"
        case .financialAgenda: return "agenda_financiera"
        case .suscription: return "suscripciones_tarjeta"
        case .customerCare: return "atencion_cliente"
        case .investmentPosition: return "posicion_inversion"
        case .impruve: return "ayudanos_mejorar"
        case .stockholders: return "accionistas"
        case .atm: return "cajeros"
        case .personalArea: return "area_personal"
        case .myManage: return "mi_gestor"
        case .addBanks: return "agregar_bancos"
        case .financialAnalysis: return "analisis_financiero"
        case .financialTips: return "consejos_financieros"
        case .financing: return "financing"
        case .consultPin: return "consultar_pin"
        case .onePlan: return nil
        case .shortcut: return "location_accesos_directos"
        case .correosCash: return nil
        case .officeAppointment: return nil
        case .investmentsProposals: return nil
        case .automaticOperations: return nil
        case .carbonFootprint: return "carbon_footprint"
        }
    }
    
    public func getAction() -> PGFrequentOperativeOptionAction {
        return .core(option: self)
    }
    
    public func getEnabled() -> PGFrequentOperativeOptionEnabled {
        return .core(option: self)
    }
    
    public func getViewType(isSmartGP: Bool, valuesProvider: PGFrequentOperativeOptionValueProviderProtocol?) -> ActionButtonFillViewType {
        if let valuesProvider = valuesProvider {
            let valuesProviderStatic = type(of: valuesProvider)
            let iconKey = isSmartGP ?
            valuesProviderStatic.smartIconKey[self] ?? valuesProviderStatic.iconKey[self]: valuesProviderStatic.iconKey [self]
            let literalKey = valuesProviderStatic.literalKey[self]
            let accessibilityKey = valuesProviderStatic.accessibilityKey[self]
            let values = PGFrequentOperativeOptionValues(title: literalKey ?? "", imageName: iconKey ?? "", accessibilityName: accessibilityKey ?? "")
            return buildViewType(with: values)
        }
        return getViewType(isSmartGP: isSmartGP)
    }
    public func getViewType(isSmartGP: Bool) -> ActionButtonFillViewType {
        let iconKey = isSmartGP ?
            PGFrequentOperativeOptionValueProvider.smartIconKey[self] ?? PGFrequentOperativeOptionValueProvider.iconKey[self]:
            PGFrequentOperativeOptionValueProvider.iconKey [self]
        let literalKey = PGFrequentOperativeOptionValueProvider.literalKey[self]
        let accessibilityKey = PGFrequentOperativeOptionValueProvider.accessibilityKey[self]
        let values = PGFrequentOperativeOptionValues(title: literalKey ?? "", imageName: iconKey ?? "", accessibilityName: accessibilityKey ?? "")
        return buildViewType(with: values)
    }
    
    func buildViewType(with optionValues: PGFrequentOperativeOptionValues) -> ActionButtonFillViewType {
        switch self {
        case .shortcut,
             .onePlan:
            return .centeredImage(
                CenteredImageActionButtonViewModel(
                    imageKey: optionValues.imageName,
                    renderingMode: .alwaysOriginal,
                    imageAccessibilityIdentifier: optionValues.imageName
                )
            )
        case .carbonFootprint:
            return .defaultButton(
                DefaultActionButtonViewModel(
                    title: optionValues.title,
                    imageKey: optionValues.imageName,
                    renderingMode: .alwaysOriginal,
                    titleAccessibilityIdentifier: optionValues.title,
                    imageAccessibilityIdentifier: optionValues.imageName,
                    accessibilityButtonValue: optionValues.accessibilityName
                )
            )
        case .contract,
             .operate,
             .billTax,
             .sendMoney,
             .marketplace,
             .analysisArea,
             .financialAgenda,
             .suscription,
             .customerCare,
             .investmentPosition,
             .impruve,
             .stockholders,
             .atm,
             .personalArea,
             .myManage,
             .addBanks,
             .financialAnalysis,
             .financialTips,
             .consultPin,
             .financing,
             .correosCash,
             .officeAppointment,
             .investmentsProposals,
             .automaticOperations:
            return .defaultButton(
                DefaultActionButtonViewModel(
                    title: optionValues.title,
                    imageKey: optionValues.imageName,
                    titleAccessibilityIdentifier: optionValues.title,
                    imageAccessibilityIdentifier: optionValues.imageName,
                    accessibilityButtonValue: optionValues.accessibilityName
                )
            )
        }
    }
    
    public func getLocation() -> String? {
        return nil
    }
}

public protocol PGFrequentOperativeOptionValueProviderProtocol {
    static var literalKey: [PGFrequentOperativeOption: String] { get }
    static var accessibilityKey: [PGFrequentOperativeOption: String] { get }
    static var iconKey: [PGFrequentOperativeOption: String] { get }
    static var smartIconKey: [PGFrequentOperativeOption: String] { get }
    static var backgroungKey: [PGFrequentOperativeOption: String] { get }
}

struct PGFrequentOperativeOptionValueProvider: PGFrequentOperativeOptionValueProviderProtocol {
    static let literalKey: [PGFrequentOperativeOption: String] = [
        .operate: "frequentOperative_button_operate",
        .contract: "frequentOperative_button_contract",
        .billTax: "frequentOperative_label_billTax",
        .sendMoney: "frequentOperative_label_sendMoney",
        .marketplace: "frequentOperative_label_marketplace",
        .analysisArea: "frequentOperative_label_tips",
        .financialAgenda: "frequentOperative_label_financialAgenda",
        .suscription: "cardsOption_button_subscriptions",
        .customerCare: "frequentOperative_label_customerCare",
        .investmentPosition: "frequentOperative_label_investmentPosition",
        .impruve: "frequentOperative_label_impruve",
        .stockholders: "frequentOperative_label_stockholders",
        .atm: "frequentOperative_label_atm",
        .personalArea: "frequentOperative_label_personalArea",
        .myManage: "frequentOperative_label_myManage",
        .addBanks: "frequentOperative_label_addBanks",
        .financialAnalysis: "frequentOperative_label_financialAnalysis",
        .financialTips: "frequentOperative_label_financialAdvice",
        .consultPin: "frequentOperative_button_pin",
        .financing: "frequentOperative_label_financing",
        .correosCash: "accountOption_button_correosCash",
        .officeAppointment: "otherOption_button_appointmentInOffice",
        .investmentsProposals: "accountOption_button_ordersSigning",
        .automaticOperations: "accountOption_button_automaticOperations",
        .carbonFootprint: "menu_link_fingerPrint"
    ]
    static let accessibilityKey: [PGFrequentOperativeOption: String] = [
        .operate: "frequentOperative_button_operate",
        .contract: "frequentOperative_button_contract",
        .billTax: "frequentOperative_label_billTax",
        .sendMoney: "voiceover_sendMoney",
        .marketplace: "frequentOperative_label_marketplace",
        .analysisArea: "frequentOperative_label_tips",
        .financialAgenda: "frequentOperative_label_financialAgenda",
        .suscription: "cardsOption_button_subscriptions",
        .customerCare: "frequentOperative_label_customerCare",
        .investmentPosition: "frequentOperative_label_investmentPosition",
        .impruve: "frequentOperative_label_impruve",
        .stockholders: "frequentOperative_label_stockholders",
        .atm: "frequentOperative_label_atm",
        .personalArea: "frequentOperative_label_personalArea",
        .myManage: "frequentOperative_label_myManage",
        .addBanks: "frequentOperative_label_addBanks",
        .financialAnalysis: "frequentOperative_label_financialAnalysis",
        .financialTips: "frequentOperative_label_financialAdvice",
        .consultPin: "frequentOperative_button_pin",
        .financing: "frequentOperative_label_financing",
        .correosCash: "accountOption_button_correosCash",
        .officeAppointment: "otherOption_button_appointmentInOffice",
        .investmentsProposals: "accountOption_button_ordersSigning",
        .automaticOperations: "accountOption_button_automaticOperations",
        .carbonFootprint: "menu_link_fingerPrint"
    ]
    static let iconKey: [PGFrequentOperativeOption: String] = [
        .operate: "icnShortcuts",
        .contract: "icnExploreProducts",
        .billTax: "icnBill",
        .sendMoney: "icnSendMoney",
        .marketplace: "icnMarket",
        .analysisArea: "btnAnalysis",
        .financialAgenda: "icnDiaryFinancial",
        .suscription: "icnSubscriptionCards",
        .customerCare: "icnSupport",
        .investmentPosition: "icn_investmentPosition",
        .impruve: "icn_helpUsSlidebar",
        .stockholders: "icnShareholders",
        .atm: "oneIcnAtms",
        .personalArea: "icnSettingOperation",
        .myManage: "icn_my_manager",
        .addBanks: "icnBanks",
        .financialAnalysis: "btnFinancialAnalysis",
        .financialTips: "icnFinancialTips",
        .financing: "icnFinancing",
        .consultPin: "icnPin",
        .onePlan: "icnOne",
        .officeAppointment: "icnCalendar",
        .investmentsProposals: "icnSignatureOrders",
        .automaticOperations: "icnAutomaticOperations",
        .carbonFootprint: "icnCarbonFootprint"
    ]
    static let smartIconKey: [PGFrequentOperativeOption: String] = [
        .onePlan: "icnOneSmart"
    ]
    static let backgroungKey: [PGFrequentOperativeOption: String] = [:]
}

public extension PGFrequentOperativeOption {
    static var defaultOperatives: [PGFrequentOperativeOption] {
        return [
            .operate, .contract, .billTax, .sendMoney, .marketplace, .analysisArea, .financialAgenda, .suscription, .customerCare, .investmentPosition, .impruve, .stockholders, .atm, .personalArea, .myManage, .addBanks, .financialAnalysis, .financialTips, .financing, .onePlan, .shortcut, .correosCash, .officeAppointment, .investmentsProposals, .automaticOperations, .carbonFootprint
        ]
    }
    
    static var simpleDefaultOperatives: [PGFrequentOperativeOption] {
        return [.operate, .contract, .billTax, .sendMoney]
    }
    
    static var operativesForConfigurationOne: [PGFrequentOperativeOption] {
        return [
            .operate, .sendMoney, .analysisArea, .contract, .billTax, .marketplace, .financialAgenda, .suscription, .customerCare, .investmentPosition, .impruve, .stockholders, .atm, .personalArea, .myManage, .addBanks, .financialAnalysis, .financialTips, .financing, .onePlan, .shortcut, .correosCash, .officeAppointment, .investmentsProposals, .automaticOperations, .carbonFootprint
        ]
    }
    static var operativesForConfigurationTwo: [PGFrequentOperativeOption] {
        return [
            .atm, .financialAgenda, .consultPin, .billTax, .operate, .contract, .sendMoney, .marketplace, .analysisArea, .suscription, .customerCare, .investmentPosition, .impruve, .stockholders, .personalArea, .myManage, .addBanks, .financialAnalysis, .financialTips, .financing, .onePlan, .shortcut, .correosCash, .officeAppointment, .investmentsProposals, automaticOperations, .carbonFootprint
        ]
    }
    static var operativesForConfigurationThree: [PGFrequentOperativeOption] {
        return [
            .marketplace, .analysisArea, .sendMoney, .operate, .contract, .billTax, .financialAgenda, .suscription, .customerCare, .investmentPosition, .impruve, .stockholders, .atm, .personalArea, .myManage, .addBanks, .financialAnalysis, .financialTips, .financing, .onePlan, .shortcut, .correosCash, .officeAppointment, .investmentsProposals, .automaticOperations, .carbonFootprint
        ]
    }
}
