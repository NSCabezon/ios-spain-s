import SANLegacyLibrary
import CoreFoundationLib
import CoreDomain

class SessionAppData {
    
    class PendingSolicitudes {
        var closedInGlobalPosition: [PendingSolicitudeEntity] = []
    }
    
    var currentFilter: [OwnershipTypeDesc]?
    var selectedProduct: SelectedProduct?
    var isMixedUser: Bool?
    var commercialSegment: CommercialSegmentEntity?
    var tips: [PullOffersConfigTip]?
    var loginMessagesCheckings: [LoginMessagesState: Bool]?
    var securityTips: [PullOfferTipEntity]?
    var securityTravelTips: [PullOfferTipEntity]?
    var helpCenterTips: [PullOfferTipEntity]?
    var atmTips: [PullOfferTipEntity]?
    var activateDebitCardTips: [PullOfferTipEntity]?
    var activateCreditCardTips: [PullOfferTipEntity]?
    var cardBoardingWelcomeDebitCardTips: [PullOfferTipEntity]?
    var cardBoardingWelcomeCreditCardTips: [PullOfferTipEntity]?
    var santanderExperiences: [PullOfferTipEntity]?
    var pendingSolicitudes: PendingSolicitudes = PendingSolicitudes()
    var cardBoardingAlmostFinishedCreditTips: [PullOfferTipEntity]?
    var cardBoardingAlmostFinishedDebitTips: [PullOfferTipEntity]?
    
    //Temporaries to save login parameters when logged in without remember check
    //These will be used for user persistance in case touchId is enabled in personalData
    var tempLogin: String?
    var tempUserType: UserLoginType?
    var tempEnvironmentName: String?
    var tempName: String?
}
