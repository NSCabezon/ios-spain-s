//
//  AccessibilityTransfers.swift
//  Commons
//
//  Created by Tania Castellano Brasero on 21/05/2020.
//

import Foundation

public enum AccessibilityTransfers: String {
    case inputDestinationCountryTitle
    case inputDestinationCountryButton
    case inputDestinationCountry
    case inputAmountTitle
    case inputAmountButton
    case inputAmount
    case inputConceptTitle
    case inputConcept
    public static let btnContinue = "generic_button_continue"
    public static let genericToolbarTitleCountry = "genericToolbar_title_country"
    public static let genericToolbarTitleCurrency = "genericToolbar_title_currency"
    public static let genericToolbarTitleSummary = "genericToolbar_title_summary"
    public static let currencyList = "currency_list"
    public static let countryList = "country_list"
    public static let currencyCollection = "currency_collection"
    public static let countryCollection = "country_collection"
    public static let icnSearch = "icnSearch"
    public static let countryBadgeBtn = "country_badgeBtn"
    public static let currencyBadgeBtn = "currency_badgeBtn"
    
    // MARK: - Header change account
    public static let transferHeaderOriginAccount = "transfer_header_originAccount"
    public static let transferLabelOriginAccount = "transfer_label_originAccount"
    public static let accountNumberLabel = "transferDestinationLabelAccountNumber"
    public static let availableAmountTitleLabel = "transferDestinationLabelAvailableAmount"
    public static let icnEdit = "icnEdit"
    public static let genericButtonChangeAccount = "generic_button_changeAccount"
    case btnChangeAccount
    
    // MARK: - Selector country and currency
    case btnList
    case btnCountry
    case btnCurrency
    case transferAmountEntryBtnContinue
    case searchInputText
    case searchInputTextValue
    
    // MARK: - Summary
    public static let moreInfoButton = "pg_label_moreInfo"
    
    // MARK: - OTP
    public static let otpTextField = "otp_text_sms"
}
public enum AccessibilityFavRecipients {
    public static let favouriteTf = "areaInputTextRecipients"
    public static let favouriteTfButton = "areaInputTextRecipientsBtn"
    public static let favouriteButton = "areaInputTextRecipientsAddFavouriteBtn"
    public static let favouriteCell = "btnFavourite"
    public static let icnCurrency = "icnCurrency"
    public static let icnWorld = "icnWorld"
    public static let favUserAvatarLabel = "favUser_label_userAvatar"
    public static let favUserAlias = "favUser_label_alias"
    public static let favUserUsername = "favUser_label_username"
    public static let favUserIBAN = "favUser_label_iban"
    public static let favUserCurrency = "favUser_label_currency"
    public static let favUserCountry = "favUser_label_country"
}

public enum AccessibilityFavRecipientsHeader: String {
    case backButton = "close"
    case headerTitle = "titleToolbar"
}

public enum AccessibilityTransferConfirmation: String {
    case button = "btnConfirm"
    case areaPrice = "areaPrice"
    case areaCard = "areaCard"
    case textComision = "confirmation_item_onePayCommission"
    case areaNotification = "areaNotification"
    case icnCheckBoxSelectedGreen = "icnCheckBoxSelectedGreen"
    case icnCheckBoxUnSelected = "icnCheckBoxUnSelected"
    case areaInputText = "areaInputText"
}

public enum AccesibilityTransferAccountSelection {
    public static let oneListView = "oneListView"
    public static let btnHiddenAccount = "originAccount_label_seeHiddenAccounts"
    public static let icnArrowDown = "icnArrowDown"
}

public enum AccessibilityTransferHome {
    public static let sendMoneyHomeBtnSeeContacts = "sendMoneyHomeBtnSeeContacts"
    public static let sendMoneyHomeLabelTitle = "transfer_title_sendTo"
    
    // MARK: - New shipment cell
    public static let sendMoneyBtnNewSend = "sendMoneyBtnNewSend"
    public static let sendMoneyHomeBtnNewTransferSend = "sendMoneyHomeButtonNewTransferSend"
    public static let sendMoneyHomeViewNewButtonCircle = "sendMoneyHomeViewNewTransferCircle"
    public static let sendMoneyHomeLabelNewTransferTitle = "sendMoneyHomeLabelNewTransferTitle"
    public static let sendMoneyHomeViewNewTransferImage = "sendMoneyHomeViewNewTransferImage"
    public static let sendMoneyHomeLabelNewTransferDesc = "sendMoneyHomeLabelNewTransferDesc"
    public static let sendMoneyLabelNewTransferAnd = "generic_text_and"
    public static let sendMoneyViewCircleContainer = "sendMoneyViewCircleContainer"
    
    // MARK: - Favourite cells
    public static let sendMoneyHomeViewFavoriteRecipientsList = "sendMoneyHomeViewFavoriteRecipientsList"
    public static let sendMoneyHomeButtonFavorite = "sendMoneyButtonFavoriteContact"
    public static let sendMoneyHomeLabelFavoriteInitials = "sendMoneyLabelFavoriteInitials"
    public static let sendMoneyHomeLabelFavoriteName = "sendMoneyLabelFavoriteName"
    public static let sendMoneyHomeLabelFavoriteAccountNumber = "sendMoneyLabelFavoriteAccountNumber"
    public static let sendMoneyHomeViewFavoriteBankIcon = "sendMoneyViewFavoriteBankIcon"
    public static let sendMoneyHomeViewFavoriteInitialsCircle = "sendMoneyViewFavoriteInitialsCircle"
    public static let sendMoneyHomeBtnFavoriteNewContact = "sendMoneyHomeBtnFavoriteNewContact"
    public static let sendMoneyBtnNewContact = "sendMoneyBtnNewContact"
    
    // MARK: - Favourite table
    public static let sendMoneyHomeBtnSaveFavoriteRecipients = "sendMoneyHomeBtnSaveFavoriteRecipients"
    
    // MARK: - Change currency and country
    public static let seachTextView = "seachTextView"
    public static let searchFirstButton = "searchFirstButton"
    public static let searchSecondButton = "searchSecondButton"
    public static let searchThirdButton = "searchThirdButton"
    public static let searchFourthButton = "searchFourthButton"
    public static let searchFifthButton = "searchFifthButton"
    
    // MARK: - Emmitted cells
    public static let sendMoneyHomeViewEmittedCellContainer = "sendMoneyHomeViewEmittedCellContainer"
    public static let sendMoneyHomeLabelEmittedCellBeneficiary = "sendMoneyHomeLabelEmittedCellBeneficiary"
    public static let sendMoneyHomeLabelEmittedCellIban = "sendMoneyHomeLabelEmittedCellIban"
    public static let sendMoneyHomeViewEmittedCellBackImage = "sendMoneyHomeViewEmittedCellBackImage"
    public static let sendMoneyHomeLabelEmittedCellExecutedDate = "sendMoneyHomeLabelEmittedCellExecutedDate"
    public static let sendMoneyHomeLabelEmittedCellAmount = "sendMoneyHomeLabelEmittedCellAmount"
    public static let sendMoneyHomeViewEmittedCellArrow = "sendMoneyHomeViewEmittedCellArrow"
    
    // MARK: - Historical
    public static let historicalTitleLabel = "transfer_title_recent"
    public static let historicalTitleButton = "transfer_label_seeHistorical"
    
    // MARK: - Actions
    public static let sendMoneyHomeLabelTransferActionTitle = "transfer_title_options"
    public static let sendMoneyHomeViewIcnArrowImage = "icnArrowRightGray"
    public static let sendMoneyHomeViewTransferActionView = "sendMoneyHomeViewTransferActionView"
    public static let sendMoneyHomeViewReuseActionView = "sendMoneyHomeViewReuseActionView"
    public static let sendMoneyHomeViewSwitchActionView = "sendMoneyHomeViewSwitchActionView"
    public static let sendMoneyHomeViewOnePayFxActionView = "sendMoneyHomeViewOnePayFxActionView"
    public static let sendMoneyHomeViewAtmActionView = "sendMoneyHomeViewAtmActionView"
    public static let sendMoneyHomeViewCorreosCashActionView = "sendMoneyHomeViewCorreosCashActionView"
    public static let sendMoneyHomeViewScheduleTransfersActionView = "sendMoneyHomeViewScheduleTransfersActionView"
    public static let sendMoneyHomeViewDonationsActionView = "sendMoneyHomeViewDonationsActionView"
    
    // MARK: - OneListHomeOptionsView
    public static let oneHomeListOptionsTitleView = "transfer_title_options"
    public static let oneHomeListOptionsView = "oneHomeOptionsListView"
}

public enum AccessibilityOneFavouritesList {
    public static let favouriteContactLabelAlias = "favouriteContactLabelAlias"
    public static let favouriteContactLabelHolder = "favouriteContactLabelHolder"
    public static let favouriteContactLabelIban = "favouriteContactLabelIban"
    public static let favouriteContactImageBankLogo = "oneIcnBankLogo"
    public static let favouriteContactImageGlobal = "oneIcnGlobal"
    public static let favouriteContactLabelCountryCurrency = "favouriteContactLabelCountryCurrency"
    public static let favouriteContactCell = "favouriteContactCell"
    public static let favouriteContactBtnMoveControl = "favouriteContactBtnMoveControl"
    public static let favouriteContactOneIcnDots = "oneIcnDots"
    public static let favouriteContactOneOvalButton = "oneOvalButton"
    public static let favouriteContactEmptyImageView = "imgLeaves"
    public static let favouriteContactSearchBarView = "oneInputRegularView"
}

public enum AccessibilityUsualTransfer: String {
    case sendBankIdenfierLabel = "sendMoney_label_bankIdentifier"
    case destinationCountryLabel = "sendMoney_label_destinationCountry"
    case currencyLabel = "sendMoney_label_valueCurrency"
    case countryLabel = "sendMoney_label_valueCountry"
    case aliasLabel = "onePay_label_alias"
    case alias
    case holderLabel = "onePay_label_holder"
    case beneficiaryName
    case destinationAccountLabel = "onePay_label_destinationAccount"
    case destinationAccount
    case sendMoneyDestinationAccountLabel = "sendMoney_label_destinationAccount"
}

public enum AccessibilityTransferHistorical {
    public static let historicalTransferViewSearchTextField = "historicalTransferViewSearchTextField"
    public static let historicalTransferViewSegmentedField = "historicalTransferViewSegmentedField"
    public static let btnAll = "historicalTransferViewAllSegment"
    public static let btnScheduled = "historicalTransferViewScheduledSegment"
    public static let btnReceived = "historicalTransferViewReceivedSegment"
    public static let historicalTransferLabelHeaderDate = "sendMoneyHistoryHeaderDate"
    public static let historicalTransferViewEmptyView = "historicalTransferViewEmptyView"
    public static let historicalTransferViewScroll = "historicalTransferViewScroll"
    
    // MARK: Transfer cells
    public static let historicalTransferCell = "sendMoneyTransferHistoryItem"
    public static let historicalTransferCellTypeIcn = "sendMoneyHistoryItemIcon"
    public static let historicalTransferInitial = "sendMoneyHistoryItemInitial"
    public static let historicalTransferCellViewBankImage = "sendMoneyHistoryItemIconBank"
    public static let historicalTransferCellViewInitialsCircle = "ContactCircleBackground"
    public static let historicalTransferCellLabelDestinationUser = "sendMoneyHistoryItemName"
    public static let historicalTransferCellLabelDestinationAccount = "sendMoneyHistoryItemIban"
    public static let historicalTransferCellLabelAmount = "sendMoneyHistoryltemAmount"
    public static let historicalTransferCellViewDottedLine = "historicalTransfer_dottedLine"
    public static let historicalTransferCellViewSeparator = "historicalTransfer_separator"
    
    // MARK: Transfer emmited detail
    public static let nameLabelGenericConfirmationCell = "name_label_genericConfirmationCell"
    public static let identifierLabelGenericConfirmationCell = "identifier_label_genericConfirmationCell"
    public static let amountLabelGenericConfirmationCell = "amount_label_genericConfirmationCell"
    public static let amountInfoLabelGenericConfirmationCell = "amountInfo_label_genericConfirmationCell"
    public static let titleLabelDetailThreeLinesCell = "title_label_detailThreeLinesCell"
    public static let amountLabelDetailThreeLinesCell = "amount_label_detailThreeLinesCell"
    public static let descriptionLabelDetailThreeLinesCell = "description_label_detailThreeLinesCell"
    public static let titleLabelDetailItemCell = "title_label_detailItemCell"
    public static let subtitleLabelDetailItemCell = "subtitle_label_detailItemCell"
    public static let btnCopyDetailItemCell = "btn_copy_detailItemCell"
    public static let imgBtnCopyDetailItemCell = "img_btn_copy_detailItemCell"
    
    // MARK: Transfer received detail
    public static let transferReceivedDetailLabelAmountTitle = "deliveryDetails_label_amount"
    public static let transferReceivedDetailLabelConceptTitle = "deliveryDetails_label_concept"
    public static let transferReceivedDetailLabelConceptValue = "deliveryDetails_label_concept_value"
    public static let transferReceivedDetailLabelTypeTitle = "deliveryDetails_label_type"
    public static let transferReceivedDetailLabelTransferReceivedTitle = "deliveryDetails_label_receiveTransfer"
    public static let transferReceivedDetailLabelDestinationAccountTitle = "deliveryDetails_label_destinationAccounts"
    public static let transferReceivedDetailLabelOperationDateTitle = "deliveryDetails_label_operationDate"
    public static let transferReceivedDetailLabelValueDateTitle = "deliveryDetails_label_valueDate"
    public static let transferReceivedDetailBtnPdf = "transferReceivedDetailBtnPdf"
    public static let transferReceivedDetailBtnShare = "transferReceivedDetailBtnShare"
    public static let transferListHistoricAll = "transferListHistoricAll"
    public static let transferInputSearch = "transferInputSearch"
    public static let transferSegmentedHistory = "transferSegmentedHistory"
    public static let transferSegmentedAll = "transferSegmentedAll"
    public static let transferSegmentedDelivered = "transferSegmentedDelivered"
    public static let transferSegmentedReceived = "transferSegmentedReceived"
}

public enum AccessibilityTransferOrigin: String {
    case titleLabel = "originAccount_label_sentMoney"
    case cellButton = "transferBtnAccount"
    case accountArea = "originAccount_view_accountArea"
    case accountAliasLabel = "originAccount_label_accountAlias"
    case accountIBANLabel = "originAccount_label_accountIban"
    case accountAvailableBalanceLabel = "accountHome_label_availableBalance"
    case accountBalanceLabel = "accountHome_label_balance"
}

public enum AccessibilityTransferDestination: String {
    case transferDestinationBtnContinue
    case btnResidentCheckBox
    case btnSaveCheckBox
    case residentLabel = "sendMoney_label_residentsInSpain"
    case saveLabel = "sendMoney_label_checkSaveContact"
    case areaInputTextAlias
    case lastPaymentsTitle = "sendMoney_label_lastBeneficiaries"
    case lastBeneficiariesAvatar = "sendMoney_label_lastBeneficiariesAvatar"
    case lastBeneficiariesUsername = "sendMoney_label_lastBeneficiariesUsername"
    case lastBeneficiariesIBAN = "sendMoney_label_lastBeneficiariesIBAN"
    case lastBeneficiariesBankIcon = "sendMoney_label_lastBeneficiariesBankIcon"
}

public enum AccessibilityTransferSubTypes: String {
    case viewTitle = "sendMoney_label_sentType"
    case commissionTitle = "sendType_label_commission"
    case commissionDisclaimer = "sendType_disclaimer_commissions"
    case totalTitle = "sendMoney_label_"
    case remaining = "sendMoney_label_remainingTransfers"
    case remainingNumber = "sendMoney_label_remainingTransfersNumber"
    case validDate = "sendMoney_label_validDate"
    case infoPaymentPacks = "sendMoney_text_infoPaymentPacks"
}

public enum AccessibilityTransferSelector: String {
    case areaInmediate
    case areaStandar
    case areaExpress
    case btnInfo
}

public enum AccessibilityTransferSummary: String {
    case areaBtnAnotherPayment
    case areaBtnGlobalPosition
    case areaBtnImprove
    case whatNowLabel = "footerSummary_label_andNow"
    case btnDownloadPdf
    case pdfLabel = "summary_button_downloadPDF"
    case btnShare
    case shareLabel = "generic_button_share"
    case paymentLocationContainer = "transferSummaryViewOnePaymentLocationContainer"
    case paymentLocation = "transferSummaryBtnOnePaymentLocation"
}

public enum AccessibilityTransferFavorites: String {
    case sendMoneyListSortFavourites
    case sendMoneyBtnNewFavoriteRecipient
    case sendMoneyListFavouriteRecipients
    case sendMoneyBtns
    case favoriteRecipientsBtnNewFavorite
    case sendMoneyEmptyListSortFavourites
    case onePayTitleEmptyFavorites
    case onePayLabelEmptyFavorites
}

public enum AccessibilityEditFavorite {
    // MARK: Country and currency selector step
    public static let countryStepLabelCountry = "editFavoriteOperativeCountryStepLabelCountry"
    public static let countryStepLabelCurrencyName = "editFavoriteOperativeCountryStepLabelCurrencyName"
    public static let countryStepLabelCurrencyCode = "editFavoriteOperativeCountryStepLabelCurrencyCode"
    
    // MARK: Beneficiary and destination account step
    public static let destinationStepLabelAliasTitle = "onePay_label_alias"
    public static let destinationStepLabelAlias = "editFavoriteOperativeDestinationStepLabelAlias"
    public static let destinationStepLabelCountryName = "editFavoriteOperativeDestinationStepLabelCountryName"
    public static let destinationStepLabelCurrencyName = "editFavoriteOperativeDestinationStepLabelCurrencyName"
}

public enum AccessibilityContactDetail {
    // MARK: Contact Detail Header View
    public static let viewHeader = "contactDetailViewHeader"
    public static let headerAvatarCircleView = "contactDetailViewAvatarCircleView"
    public static let headerLabelAvatarName = "contactDetailLabelAvatarName"

    // MARK: Contact Detail Generic Views
    public static let genericFieldAliasContainer = "contactDetailViewAliasContainer"
    public static let genericFieldAlias = "contactDetailLabelAlias"
    public static let genericFieldHolderContainer = "contactDetailViewHolderContainer"
    public static let genericFieldHolder = "contactDetailLabelHolder"
    public static let genericFieldCountryContainer = "contactDetailViewCountryContainer"
    public static let genericFieldCountry = "contactDetailLabelCountry"
    public static let genericFieldCurrencyContainer = "contactDetailViewCurrencyContainer"
    public static let genericFieldCurrency = "contactDetailLabelCurrency"
    public static let genericFieldBeneficiaryAddressContainer = "contactDetailViewBeneficiaryAddressContainer"
    public static let genericFieldBeneficiaryAddress = "contactDetailLabelBeneficiaryAddress"
    public static let genericFieldBeneficiaryTownContainer = "contactDetailViewBeneficiaryTownContainer"
    public static let genericFieldBeneficiaryTown = "contactDetailLabelBeneficiaryTown"
    public static let genericFieldBeneficiaryCountryContainer = "contactDetailViewBeneficiaryCountryContainer"
    public static let genericFieldBeneficiaryCountry = "contactDetailLabelBeneficiaryCountry"
    public static let genericFieldDestinationCountryContainer = "contactDetailViewDestinationCountryContainer"
    public static let genericFieldDestinationCountry = "contactDetailLabelDestinationCountry"
    public static let genericFieldBicSwiftContainer = "contactDetailViewBicSwiftContainer"
    public static let genericFieldBicSwift = "contactDetailLabelBicSwift"
    public static let genericFieldBankNameContainer = "contactDetailViewBankNameContainer"
    public static let genericFieldBankName = "contactDetailLabelBankName"
    public static let genericFieldBankAddressContainer = "contactDetailViewBankAddressContainer"
    public static let genericFieldBankAddress = "contactDetailLabelBankAddress"
    public static let genericFieldBankTownContainer = "contactDetailViewBankTownContainer"
    public static let genericFieldBankTown = "contactDetailLabelBankTown"
    public static let genericFieldBankCountryContainer = "contactDetailViewBankCountryContainer"
    public static let genericFieldBankCountry = "contactDetailLabelBankCountry"
    
    // MARK: Contact Detail Account View
    public static let accountContainer = "contactDetailViewAccountContainer"
    public static let accountTitle = "contactDetailLabelAccount"
    public static let accountValue = "contactDetailLabelAccountValue"
    public static let accountImageBank = "contactDetailViewAccountImageBank"
    public static let accountShareImageView = "icnShareSlimGreen"
    public static let accountBtnShare = "contactDetailBtnAccountShare"
    public static let accountBtnNewTransfer = "contactDetailBtnAccountNewTransfer"
    public static let accountNewTransferImage = "icnEuroDestinationAccount"
    public static let accountNewTransferTitle = "generic_buttom_newSend"
    
    // MARK: Contact Detail Footer View
    public static let contactDetailLabelDeleteContactTitle = "favoriteRecipients_button_deleteContact"
    public static let contactDetailViewDeleteContactImage = "icnRemoveGreen"
    public static let contactDetailBtnDeleteContact = "contactDetailBtnDeleteContact"
    public static let contactDetailLabelEditContactTitle = "favoriteRecipients_button_editContact"
    public static let contactDetailViewEditContactImage = "icnEdit"
    public static let contactDetailBtnEditContact = "contactDetailBtnEditContact"
}

public enum AccessibilityRecentAndScheduled {
    public static let emptyImage  = "imgLeaves"
    public static let emptyTitleLabel  = "generic_label_emptyListResult"
    public static let emptySubTitleLabel  = "transfer_text_emptyView_notDone"
    public static let emptyView  = "emptyView"
    public static let loadingImage  = "loadingImage"
    public static let loadingTitleLabel  = "generic_popup_loadingContent"
    public static let loadingSubTitleLabel  = "loading_label_moment"
    public static let loadingView  = "loadingView"
    public static let recentAndScheduledTitleLabel  = "transfer_title_recent"
    public static let recentAndScheduledButton  = "transfer_label_seeHistorical"
}
