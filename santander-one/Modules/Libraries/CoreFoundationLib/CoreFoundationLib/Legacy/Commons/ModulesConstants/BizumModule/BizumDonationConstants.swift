import Foundation

public struct BizumDonationSelectOrganizationPage: PageWithActionTrackable {
    public let page = "/bizum/donation"
    public typealias ActionType = Action
    public enum Action: String {
        case organizationSelected = "seleccionar_organizacion"
    }
    public init() {}
}

public struct BizumDonationAmountPage: TrackerPageAssociated {
    public var pageAssociated = "bizum_donacion_importe_destino"
    public init() {}
}

public struct BizumDonationConfirmationPage: TrackerPageAssociated {
    public var pageAssociated = "bizum_donacion_confirmacion"
    public init() {}
}

public struct BizumDonationSignaturePage: TrackerPageAssociated {
    public var pageAssociated = "bizum_donacion_firma"
    public init() {}
}

public struct BizumDonationOTPPage: TrackerPageAssociated {
    public var pageAssociated = "bizum_donacion_otp"
    public init() {}
}

public struct BizumDonationSummaryPage: PageWithActionTrackable {
    public let page = "bizum_donacion_resumen"
    public typealias ActionType = Action
    public enum Action: String {
        case share = "compartir"
    }
    public init() {}
}

public struct BizumDonationTrackingEventNames {
    public let enterOrganizationCodePrefix = "insert_NGO_code_"
    public init() {}
}
