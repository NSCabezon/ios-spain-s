//
//  AccessibilityAtm.swift
//  Commons
//
//  Created by Cristobal Ramos Laina on 04/09/2020.
//

public enum AccessibilityAtm: String {
    case tagView = "menu_label_newProminent"
    case labelSeeAllTips = "generic_button_seeAll"
    case buttonSeeAllTips = "tipsBtnSeeAll"
    
    // Cashier Limit
    case icnSetLimitsCards = "icnSetLimitsCard"
    case cellLimitCards = "atmBtnSetLimitsCards"
    case labelLimitCards = "atm_button_setLimitsCards"
    case arrowImageRight = "icnArrowRight"
    
    // Get Money With Code
    case icnWithDraw = "icnCodeWithdraw"
    case getMoneyWithCodeCell = "atmBtnCodeWithdraw"
    case titleLabelGetMoneyWithCode = "atm_button_codeWithdraw"
    
    // Global Search
    case titleLabelGlobalSearch = "GlobalSearchLabelHomeTipCellTitle"
    case descriptionLabelGlobalSearch = "GlobalSearchLabelHomeTipCellDescription"
    case descriptionViewGlobalSearch = "GlobalSearchViewHomeTipCellDescriptionZone"
    case imageTipViewGlobalSearch = "GlobalSearchImageHomeTipCellBackgroundImage"
    case viewContainerGlobalSearch = "GlobalSearchButtonHomeTipCellGoToOffer"
    
    // Report Fault
    case atmBtnReportFault = "atmBtnReportFault"
    
    // Search
    case atmInputSearch = "atmInputSearch"
    
    // See All Tips
    case atmBtnSeeAllTips = "atmBtnSeeAllTips"
    case descriptionLabelSeeAllTips = "atm_button_seeAllTips"
    case atmCarouselTips = "atmBtnCarouselTips"
    case atmTipTitle = "tips_title_ourTips"
    
    // Office Appointment
    case icnCalendar = "icnCalendar"
    case cellOfficeAppointment = "atmBtnOfficeDate"
    case labelTitleOfficeAppointment = "helpCenter_button_officeDate"
    case labelSubtitleOfficeAppointment = "helpCenter_text_officeDate"

    public enum AtmListOperations {
        public static let title = "atm_tilte_lastOperations"
        public static let listOperation = "atmListLastOperations"
        public static let atmElementOpeartion = "atmElementLastOperations"
    }
    
    public enum AtmDetail {
        public static let viewDetail = "atmViewDetail"
        public static let title = "atm_title_atm"
        public static let address = "atm_title_address"
        public static let distance = "atm_title_distance"
        public static let status = "generic_button_operative"
        public static let imageArrow = "icnArrowRight"
        public static let serviceTitle = "atm_label_otherServices"
        public static let atmListOtherServices = "atmListOtherServices"
        public static let element = "atm_element"
        public static let service = "atm_service"
        public static let atmListTicketsAvailable = "atmListTicketsAvailable"
        public static let cashTypeTitle = "atm_label_ticketsAvailable"
        public static let atmBtnAtm = "atmBtnAtm"
    }
    
    public enum NearestAtms {
        public static let nearAtmCashierLabel = "atm_text_nearbyAtm"
        public static let distance = "atmLabelDistance"
        public static let adress = "atmLabelAddress"
        public static let operative = "generic_button_operative"
        public static let filter = "generic_button_filters"
        public static let carousel = "atmImgCarouselAtm"
        public static let atmBtnsFilters = "atmBtnsFilters"
        public static let filterButton = "atmBtnFilters"
        public static let atmBtnLocationAtm = "atmBtnLocationAtm"
    }
}
