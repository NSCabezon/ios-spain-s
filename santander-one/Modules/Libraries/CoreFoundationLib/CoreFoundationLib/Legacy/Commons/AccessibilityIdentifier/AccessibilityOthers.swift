import Foundation

public enum AccessibilityOthers: String {
	// Hamburger button
	case btnMenu = "icnMenu"
    case btnContinue
    case btnBack = "icnBack"
        
    // MARK: - ActionLisboaTextField
    case areaInputText
    case btnBadge
    case whatIBAN = "sendMoney_label_whatIban"
    case badgeLabel = "badge_abel"
    
    // MARK: - OperativeConfirmation
    case btnSend
    case btnClose = "icnClose"
    
    // MARK: - Picker Elements
    case pickerController
    case pickerElement
    case doneBarButton
    
    // MARK: - InstantMoney
    case confirmationBtn = "generic_button_confirm"
    case confirmationNavTitle = "genericToolbar_title_confirmation"
    case summaryNavTitle = "genericToolbar_title_summary"
    
    // MARK: - FractionablePayment
    case fractionateView = "fractionate_view"
    case fractionateTitle = "fractionate_title"
    case fractionatePercentage = "fractionate_perfentageImage"
    case fractionateArrow = "fractionate_arrowImage"
    
    // MARK: - CrossSellingButton
    case crossSellingView = "crossSellingButtonView"
    case crossSellingButton = "crossSellingButton_pressable"
    case crossSellingTitle = "crossSellingButton_title"
    case crossSellingImage = "crossSellingButton_arrowImage"

    // MARK: - WhiteButton
    public static let btnWhite = "btn_white"
    public static let labelBtnWhite = "label_btn_white"

    // MARK: - RedButton
    public static let btnRed = "btn_red"
    public static let labelBtnRed = "label_btn_red"
}

public enum AccessibilityDateSelector: String {
    case inputScheduledDate
    case inputScheduledDateTitle
    case inputPeriodicity
    case inputStartDate
    case inputStartDateTitle
    case inputEndDate
    case inputEndDateTitle
    case btnEndDateNever
    case labelEndDateNever
    case inputEmissionDate
    case inputEmissionDateTitle
    case periodicityLabel = "transfer_label_periodicity"
}

public enum AccessibilityConfirmationView: String {
    case titleLabel = "generic_title_label"
    case valueLabel = "generic_value_label"
    case infoLabel = "generic_info_label"
    case actionButton = "generic_edit_link"
    case labelTotal =  "confirmation_label_totalOperation"
    case amountTotal = "generic_label_percentage"
}
