//
//  FinanceableInfoBuilder.swift
//  Menu
//
//  Created by José Carlos Estela Anguita on 02/07/2020.
//

import Foundation
import CoreFoundationLib
import CoreDomain

public enum PaymentBoxType {
    case creditCard
    case receipts
    case transfers
    case purchases
}

struct FinanceableInfoViewModel {
    
    struct FractionalPaymentModel {
        
        init(shouldAddCreditCardBox: Bool) {
            if shouldAddCreditCardBox {
                cards.insert(
                    FractionalPaymentBoxViewModel(
                    iconName: "icnCardOperations",
                    title: localized("financing_title_creditCards"),
                    subTitle: localized("financing_label_seePayments"),
                    type: .creditCard
                    ),
                    at: 0
                )
            }
        }
        
        var cards: [FractionalPaymentBoxViewModel] = [
            FractionalPaymentBoxViewModel(
                iconName: "icnReceipt",
                title: localized("financing_title_bills"),
                subTitle: localized("financing_label_consultBills"),
                type: .receipts),
            FractionalPaymentBoxViewModel(
                iconName: "icnTransfer",
                title: localized("financing_title_sendMoney"),
                subTitle: localized("financing_label_seeSendMoney"),
                type: .transfers),
            FractionalPaymentBoxViewModel(
                iconName: "icnFinancingPurchases",
                title: localized("financing_title_purchases"),
                subTitle: localized("financing_label_seePurchases"),
                type: .purchases)
        ]
    }
    
    struct FractionalPaymentBoxViewModel {
        let iconName: String
        let title: LocalizedStylableText
        let subTitle: LocalizedStylableText
        let paymentType: PaymentBoxType
        
        init(iconName: String,
             title: LocalizedStylableText,
             subTitle: LocalizedStylableText,
             type: PaymentBoxType) {
            self.iconName = iconName
            self.title = title
            self.subTitle = subTitle
            self.paymentType = type
        }
    }
    
    struct Offer {
        let location: PullOfferLocation
        let offer: OfferEntity
        var viewModel: OfferEntityViewModel {
            return OfferEntityViewModel(entity: offer)
        }
    }
    
    struct AccountsCarousel {
        let accounts: [AccountEntity]
        let easyPay: AccountEasyPay
        let offers: [PullOfferLocation: OfferEntity]
    }
    
    struct CardsCarousel {
        let cards: [CardEntity]
        let isSanflixEnabled: Bool
        let offer: Offer?
    }
    
    struct NeedMoney {
        let amount: AmountEntity?
        let offer: Offer?
    }
    
    struct AdobeTarget {
        let data: AdobeTargetOfferRepresentable
    }
    
    struct BigOffer {
        let offer: Offer?
    }
    
    struct Tricks {
        let tricks: [TrickEntity]
    }
    
    struct CommercialOffers {
        let entity: PullOffersFinanceableCommercialOfferEntity
        let offers: [Offer]?
    }
    
    let accountsCarousel: AccountsCarousel?
    let cardsCarousel: CardsCarousel
    let preconceivedBanner: NeedMoney?
    let robinsonOffer: BigOffer?
    let bigOffer: BigOffer?
    let tricks: Tricks?
    let secondBigOffer: BigOffer?
    let adobeTarget: AdobeTarget?
    let fractionalPayment: FractionalPaymentModel?
    let commercialOffers: CommercialOffers?
}

extension FinanceableManager {
    
    final class InfoBuilder {
        
        private var accountsCarousel: FinanceableInfoViewModel.AccountsCarousel?
        private var cardsCarousel: FinanceableInfoViewModel.CardsCarousel = FinanceableInfoViewModel.CardsCarousel(cards: [], isSanflixEnabled: false, offer: nil)
        private var preconceivedBanner: FinanceableInfoViewModel.NeedMoney?
        private var adobeTarget: FinanceableInfoViewModel.AdobeTarget?
        private var robinsonOffer: FinanceableInfoViewModel.BigOffer?
        private var bigOffer: FinanceableInfoViewModel.BigOffer?
        private var secondBigOffer: FinanceableInfoViewModel.BigOffer?
        private var tricks: FinanceableInfoViewModel.Tricks?
        private var fractionalPayment: FinanceableInfoViewModel.FractionalPaymentModel?
        private var commercialOffers: FinanceableInfoViewModel.CommercialOffers?
        
        func setAccountsCarousel(_ accountsCarousel: FinanceableInfoViewModel.AccountsCarousel) {
            self.accountsCarousel = accountsCarousel
        }
        
        func setFractionalPayment(_ fractionalPayment: FinanceableInfoViewModel.FractionalPaymentModel) {
            self.fractionalPayment = fractionalPayment
        }
        
        func setCardsCarousel(_ cardsCarousel: FinanceableInfoViewModel.CardsCarousel) {
            self.cardsCarousel = cardsCarousel
        }
        
        func setBigOffer(_ bigOffer: FinanceableInfoViewModel.BigOffer) {
            self.bigOffer = bigOffer
        }
        
        func setSecondBigOffer(_ secondBigOffer: FinanceableInfoViewModel.BigOffer) {
            self.secondBigOffer = secondBigOffer
        }
        
        func setPreconceivedBanner(_ needMoney: FinanceableInfoViewModel.NeedMoney) {
            self.preconceivedBanner = needMoney
        }

        func setCommercialOffers(_ commercialOffers: FinanceableInfoViewModel.CommercialOffers) {
            self.commercialOffers = commercialOffers
        }
        
        func setAdobeTarget(_ adobeTarget: FinanceableInfoViewModel.AdobeTarget) {
            self.adobeTarget = adobeTarget
        }
        
        func setRobinsonOffer(_ robinsonOffer: FinanceableInfoViewModel.BigOffer) {
            self.robinsonOffer = robinsonOffer
        }
        
        func setTricks(_ tricks: FinanceableInfoViewModel.Tricks) {
            self.tricks = tricks
        }
        
        func build() -> FinanceableInfoViewModel {
            return FinanceableInfoViewModel(
                accountsCarousel: self.accountsCarousel,
                cardsCarousel: self.cardsCarousel,
                preconceivedBanner: self.preconceivedBanner,
                robinsonOffer: self.robinsonOffer,
                bigOffer: self.bigOffer,
                tricks: self.tricks,
                secondBigOffer: self.secondBigOffer,
                adobeTarget: self.adobeTarget,
                fractionalPayment: self.fractionalPayment,
                commercialOffers: self.commercialOffers
            )
        }
    }
}
