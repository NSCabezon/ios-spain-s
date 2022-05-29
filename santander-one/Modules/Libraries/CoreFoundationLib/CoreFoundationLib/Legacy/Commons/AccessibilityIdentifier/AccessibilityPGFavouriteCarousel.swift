//
//  AccessibilityPGFavouriteCarousel.swift
//  Commons
//
//  Created by Ignacio González Miró on 29/09/2020.
//

import Foundation

public enum AccessibilityPGFavouriteCarousel: String {
    case classicBaseCell = "classicPgCarouselSendMoney"
    case smartBase = "pgSmartCarouselFavoritesSendMoney"
    case baseTitle = "pg_label_sendMoney"
    case newShippmentPill = "sendMoneyBtnNewSend"
    case newShippmentPillTitle = "transfer_button_newSend"
    case newShippmentPillSubtitle = "transfer_text_button_newSend"
    case newShippmentPillIcon = "imagePlus"
    case newContactPill = "sendMoneyBtnNewContact"
    case newContactPillTitle = "pg_label_newContacts"
    case newContactPillSubtitle = "pg_text_addFavoriteContacts"
    case newContactPillIcon = "icnNewContact"
    case favouritePill = "sendMoneyBtnSendFav"
    case historicSendMoneyPill = "sendMoneyBtnSendHistorical"
    case historicSmPillImage = "icnSendHistorical"
    case historicSmPillTitle = "pg_label_sendHistorical"
    case historicSmPillDescription = "pg_text_button_reviewAllSendMoney"
}
