//
//  AccessibilityBizum.swift
//  Commons
//
//  Created by Margaret López Calderon on 15/09/2020.
//

import Foundation

public enum AccessibilityBizumSendMoney {
    public static let bizumInputAmount = "bizumInputAmount"
    public static let bizumInputAmountPerson = "bizumInputAmountPerson"
    public static let bizumInputConcept = "bizumInputConcept"
    public static let bizumBtnContinue = "bizumBtnContinue"
    public static let bizumListContacts = "bizumListContacts"
    public static let bizumLabelTotalAmount = "bizumLabelTotalAmount"
    public static let bizumTooltipSameAmount = "bizum_tooltip_sameAmount"
    public static let bizumlabelTotal = "bizum_label_total"
    public static let bizumNoteTitle = "generic_label_note"
    public static let bizumNote = "addNote_label_addNote"
    public static let bizumImageTitle = "generic_label_image"
    public static let bizumImage = "addImage_label_addImage"
}

public enum AccessibilityBizumSendMoneyAccountSelector {
    public static let originAccountLabelSentMoney = "originAccount_label_sentMoney"
    public static let accountItem = "bizum_account_selector_item"
    public static let accountNotVisibleItem = "bizum_account_selector_not_visible_item"
    public static let originAccountLabelSeeHiddenAccounts = "originAccount_label_seeHiddenAccounts"
}

public enum AccessibilityBizum {
    public static let bizumLabelRecentTitle = "bizumLabelRecentTitle"
    public static let bizumLabelRecentSubTitle = "bizumLabelRecentSubTitle"
    public static let bizumListViewRecent = "bizumListViewRecent"
    public static let bizumBtnRecentSeeAll = "bizumBtnRecentSeeAll"
    public static let bizumBtnRecent = "bizumBtnRecent"
    public static let bizumBtnSettings = "bizumBtnSettings"
    public static let bizumLabelSettings = "bizumLabelSettings"
    public static let bizumBtnHistorical = "bizumBtnHistorical"
    public static let bizumAlertBtnKnowMore = "bizumAlertBtnKnowMore"
    public static let bizumAlertBtnNoThanks = "bizumAlertBtnNoThanks"
    public static let bizumAlertTitleShoppingBizum = "bizum_alertTitle_shoppingBizum"
    public static let bizumAlertTextShoppingBizum = "bizum_alertText_shoppingBizum"
    public static let bizumContactCaroussel = "bizumContactCaroussel"
    public static let bizumLabelRecentOperationAllTitle = "bizumLabelRecentOperationAllTitle"
    public static let bizumLabelRecentOperationAllText = "bizumLabelRecentOperationAllText"
    public static let bizumViewRecentOperationContainerView = "bizumViewRecentOperationContainerView"
    public static let bizumLabelRecentOperationDate = "bizumLabelRecentOperationDate"
    public static let bizumLabelRecentOperationTitle = "bizumLabelRecentOperationTitle"
    public static let bizumLabelRecentOperationText = "bizumLabelRecentOperationText"
    public static let bizumLabelRecentOperationAmount = "bizumLabelRecentOperationAmount"
    public static let bizumLabelRecentOperationState = "bizumLabelRecentOperationState"
    public static let bizumOptionsTitleLabel = "bizumOptionsTitleLabel"
}

public enum AccessibilityBizumHistoric {
    public static let bizumTabAll = "bizum_tab_all"
    public static let bizumTabSend = "bizum_tab_send"
    public static let bizumTabRecived = "bizum_tab_received"
    public static let bizumTabShoping = "bizum_tab_shopping"
    public static let bizumHistoryInputSearch = "bizumHistoryInputSearch"
    public static let bizumHistoricList = "bizumHistoricList"
    public static let bizumHistoricSegmentedHistoricList = "bizumHistoricSegmentedHistoricList"
    public static let icnClip = "icnClip"
    public static let bizumHistoricCell = "bizumHistoricCell"
    public static let bizumHistoricIconType = "bizumHistoricIconType"
    public static let bizumHistoricLabelInitials = "bizumHistoricLabelInitials"
    public static let bizumHistoricLabelTitle = "bizumHistoricLabelTitle"
    public static let bizumHistoricLabelSubtitle = "bizumHistoricLabelSubtitle"
    public static let bizumHistoricLabelAmount = "bizumHistoricLabelAmount"
    public static let bizumHistoricLabelConcept = "bizumHistoricLabelConcept"
    public static let bizumHistoricLabelPhoneNumber = "bizumHistoricLabelPhoneNumber"
    public static let bizumHistoricIconState = "bizumHistoricIconState"
    public static let bizumHistoricLabelState = "bizumHistoricLabelState"
    public static let icnMultiple = "icnMultiple"
    public static let bizumAndMore = "bizum_label_andMore"
    public static let bizumHistoricLabelHistoricListDate = "bizumHistoricLabelHistoricListDate"
    public static let bizumHistoricLabelListHeaderTitle = "bizumHistoricLabelListHeaderTitle"
    public static let bizumRejectActionButton = "bizumBtnRejectRequest"
    public static let bizumAcceptActionButton = "bizumBtnAcceptRequest"
    public static let bizumRefundActionButton = "bizumBtnReturnShipping"
    public static let bizumSendActionButton = "bizumBtnSendShipping"
    public static let bizumHistoricInitialsLabel = "bizumHistoricInitialsLabel"
    public static let bizumHistoricInitialsBgView = "bizumHistoricInitialsBgView"
}

public enum AccessibilityBizumDetail {
    public static let bizumLabelAmountValue = "bizumLabelAmountValue"
    public static let bizumLabelConceptValue = "bizumLabelConceptValue"
    public static let bizumLabelEmitterValue = "bizumLabelEmitterValue"
    public static let bizumLabelEmitterIdValue = "bizumLabelEmitterIdValue"
    public static let bizumLabelDateValue = "bizumLabelDateValue"
    public static let bizumLabelReceiverValue = "bizumLabelReceiverValue"
    public static let bizumLabelStateValue = "bizumLabelStateValue"
    public static let bizumLabelNoteValue = "bizumLabelNoteValue"
    public static let bizumLabelOrigin = "bizumLabelOrigin"
    public static let bizumLabelAmount = "bizumDetail_label_amount"
    public static let bizumLabelEmitterMoney = "bizumDetail_label_sentFrom"
    public static let bizumLabelEmitterRequest = "bizumDetail_label_requestedFrom"
    public static let bizumLabelReceiverMoney = "bizumDetail_label_receivedFrom"
    public static let bizumLabelReceiverRequest = "bizumDetail_label_applicant"
    public static let bizumLabelSenType = "bizumDetail_label_sendType"
    public static let bizumLabelNoCommissions = "bizumDetail_label_bizumNoCommissions"
    public static let bizumLabelDestination = "bizumDetail_label_destination"
    public static let bizumLabelmageText = "addImage_label_viewImage"
    public static let bizumDetailListReceiver = "bizumDetailListReceiver"
    public static let bizumDetailMultipleDescriptionLabel = "bizumDetailMultipleDescriptionLabel"
}

public enum AccessibilityBizumReuseContact {
    public static let icnMultiple = "icnMultiple"
    public static let reuseContactLabelIdentifier = "reuseContactLabelIdentifier"
    public static let reuseContactLabelAlias = "reuseContactLabelAlias"
    public static let reuseContactViewInitials = "reuseContactViewInitials"
    public static let reuseContactLabelInitials = "reuseContactLabelInitials"
    public static let reuseContactLabelNumberContacts = "reuseContactLabelNumberContacts"
    public static let bizumLabelMultipleTo = "bizum_label_multipleTo"
    public static let bizumLabelAndMore = "bizum_label_andMore"
}

public enum AccessibilityBizumConfirmation {
    public static let titleComment = "bizum_label_addComment"
    public static let commentView = "bizumInputCommentary"
    public static let contactView = "contactView"
    public static let contactLabel = "contactLabel"
    public static let contactAlias = "contactAlias"
    public static let contactName = "contactName"
    public static let contactPhone = "contactPhone"
    public static let date = "date"
    public static let originAccount = "originAccount"
    public static let sendType = "sendType"
    public static let bizumInputCommentaryContainer = "bizumInputCommentaryContainer"
}

public enum AccessibilityBizumSummary {
    public static let title = "summary_title"
    public static let subtitle = "summary_subtitle"
    public static let ticImage = "icnCheckOval"
    public static let summaryStandardBodySubtitle = "summaryStandardBodySubtitle"
    public static let summaryStandardBodyInfo = "summaryStandardBodyInfo"
    public static let destinationName = "destinationName"
    public static let destinationAmount = "destinationAmount"
    public static let destinationStatus = "destinationStatus"
    public static let comment = "comment"
    public static let commentValue = "commentValue"
    public static let summaryRecipientLabel = "summary_label_destination"
    public static let organizationTitle = "organizationTitle"
    public static let organizationName = "organizationName"
    public static let organizationImage = "organizationImage"
}

public enum AccessibilityBizumSendAgain {
    public static let titleSendAgain = "transfer_label_sendAgain"
    public static let titleRequestAgain = "bizum_label_requestAgain"
    public static let totalAmountTitle = "confirmation_label_totalAmount"
    public static let totalAmountValue = "BizumSendAgainTotalAmountValue"
    public static let totalAmountInfo = "BizumSendAgainTotalAmountInfo"
    public static let emitterValue = "BizumSendAgainEmitterValue"
    public static let emitterInfo = "BizumSendAgainEmitterInfo"
    public static let transferTypeValue = "confirmation_label_destination"
    public static let receiverTitle = "confirmation_label_destination"
    public static let receiverValue = "BizumSendAgainReceiverValue"
    public static let receiverInfo = "BizumSendAgainReceiverValue"
}

public enum AccessibilityBizumSplitExpenses {
    public static let amountOperationHeaderContentView = "bizumListConcept"
    public static let amountOperationHeaderSplitExpensesIcon = "icnShareExpenseGreen"
    public static let amountOperationHeaderLabelAmount = "amountHeaderLabelAmount"
    public static let amountOperationHeaderBottomImageView = "icnBrokenPaper"
    public static let amountContactBtnTrash = "icnRemoveGreen"
    public static let amountContactAvatarNameLabel = "amountContactAvatarNameLabel"
    public static let amountContactNameLabel = "amountContactNameLabel"
    public static let amountContactPhoneLabel = "amountContactPhoneLabel"
    public static let amountContactAmountTitleLabel = "bizum_label_amount"
    public static let amountContactAmounLabel = "amountContactAmounLabel"
    public static let amountConceptInput = "amountConceptInput"
    public static let amountAddPhoneInput = "amountAddPhoneInput"
    public static let amountListFrequentContacts = "amountListFrequentContacts"
    
}

public enum AccessibilityBizumDonation {
    public static let donationAmountViewControllerDestinationImage = "bizumDonationAmountViewControllerDestinationImage"
    public static let donationAmountViewControllerDestinationLabel = "bizumDonationAmountViewControllerDestinationLabel"
    public static let donationAmountViewControllerInitialLabel = "bizumDonationAmountViewControllerInitialLabel"
    public static let ngoSelectorTableView = "bizumNgoSelectorTableView"
    public static let selectedNgoCollectionView = "bizumSelectedNgoCollectionView"
    public static let ngoCellLogoImage = "bizumNGOCellLogoImage"
    public static let ngoCellNameLabel = "bizumNGOCellNameLabel"
    public static let emptyViewLabel = "bizum_title_emptyView"
    public static let enterCodeView = "bizumDonationEnterCodeView"
    public static let enterCodeNGOLabel = "bizum_label_enterOng"
    public static let seeListNGOLabel = "bizum_label_seeListOngs"
    public static let selectorViewBtnContinue = "bizumDonationNGOSelectorViewBtnContinue"
    public static let listNGOEmptyView = "bizumDonationNGOListEmptyView"
    public static let listNGOLoadingView = "bizumDonationNGOListLoadingView"
    public static let listNGOBtnOng = "bizumDonationNGOListBtnOng"
}

public enum AccessibilityBizumContact {
    public static let bizumSuperTitleBarLabel = "bizumSuperTitleBarLabel"
    public static let bizumTitleBarLabel = "bizumTitleBarLabel"
    public static let bizumLabelTitle = "bizumLabelTitle"
    public static let bizumInputSchedule = "bizumInputSchedule"
    public static let acceptButton = "generic_button_accept"
    public static let bizumContactCarousel = "bizumContactCarousel"
    public static let bizumBtnContact = "bizumBtnContact"
    public static let bizumHeaderContact = "bizumHeaderContact"
    public static let bizumBtnSchedule = "bizumBtnSchedule"
    public static let bizumLabel = "bizum_tooltip_writeAMobileNumber"
    public static let bizumBtnAdd = "bizumBtnAdd"
    public static let btnTrash = "btnTrash"
    // Contact list
    public static let imgLeavesCell = "imgLeavesCell"
    public static let bizumListContacts = "bizumListContacts"
    public static let bizumInputSearch = "bizumInputSearch"
    public static let bizumEmptyTitleLabel = "bizumEmptyTitleLabel"
}

public enum AccessibilitySharingByWhatsapp {
    public static let singlePill = "summaryShareViewContactWhatsapp"
    public static let multiplePill = "summaryShareViewMultipleContactWhatsapp"
    public static let headerTitle = "summary_label_shareShipment"
    public static let headerSubtitle = "summary_label_shareImageGenerated"
    public static let headerImg = "icnWhatsapp"
    public static let headerDescription = "generic_label_shareWith"
}

public enum AccessibilityBizumHomeContact {
    public static let bizumImage = "bizumImage"
    public static let bizumTitle = "bizumTitle"
    public static let bizumInitialsLabel = "bizumInitialsLabel"
    public static let bizumInitialsView = "bizumInitialsView"
    public static let bizumSubTitle = "bizumSubTitle"
    public static let bizumImageNewSend = "bizumImageNewSend"
    public static let bizumCellNewSend = "bizumCellNewSend"
    public static let bizumTitleNewSend = "bizumTitleNewSend"
    public static let bizumSubTitleNewSend = "bizumSubTitleNewSend"
    public static let bizumCellSearch = "bizumCellSearch"
    public static let bizumImageSearch = "bizumImageSearch"
    public static let bizumTitleSearch = "bizumTitleSearch"
    public static let bizumSubTitleSearch = "bizumSubTitleSearch"
}

public enum BizumHomeOptionViewComponent {
    public static let bizumImage = "Image"
    public static let bizumTitle = "Title"
    public static let bizumSubTitle = "SubTitle"
}

public enum BizumHomeAlertContactList {
    public static let bizumLabelTitle = "bizumLabelTitle"
    public static let bizumLabelSubTitle = "bizumLabelSubTitle"
    public static let bizumBtnAllowed = "bizumBtnAllowed"
    public static let bizumBtnReject = "bizumBtnReject"
}

public enum BizumHistoricSectionHeader {
    public static let bizumLabelTitle = "bizumLabelTitle"
}

public enum BizumActionButtonComponent {
    public static let bizumTitleLabel = "bizumTitleLabel"
}

public enum BizumDetailView {
    public static let bizumTitleLabel = "bizumTitleLabel"
}
