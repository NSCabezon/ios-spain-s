import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class LoadCustomerServiceOptionsSuperUseCase {
    
    private let useCaseProvider: UseCaseProvider
    private let useCaseHandler: UseCaseHandler
    private let segmentedUserRepository: SegmentedUserRepository
    private let bsanManagersProvider: BSANManagersProvider
    private let appConfigRepository: AppConfigRepository
    private let isLoggedIn: Bool

    private var errorHandler: GenericPresenterErrorHandler
    
    init(useCaseProvider: UseCaseProvider,
         useCaseHandler: UseCaseHandler,
         errorHandler: GenericPresenterErrorHandler,
         isLoggedIn: Bool,
         segmentedUserRepository: SegmentedUserRepository,
         bsanManagersProvider: BSANManagersProvider,
         appConfig: AppConfigRepository) {
        self.useCaseProvider = useCaseProvider
        self.useCaseHandler = useCaseHandler
        self.isLoggedIn = isLoggedIn
        self.errorHandler = errorHandler
        self.segmentedUserRepository = segmentedUserRepository
        self.bsanManagersProvider = bsanManagersProvider
        self.appConfigRepository = appConfig
    }
    
    func build(completion: @escaping ([CustomerServiceOption]?) -> Void) {
        
        if isLoggedIn {
            guard let user = (try? checkRepositoryResponse(bsanManagersProvider.getBsanSessionManager().getUser())),
                let userSegment = (try? checkRepositoryResponse(bsanManagersProvider.getBsanUserSegmentManager().getUserSegment())) else {
                    completion(nil)
                    return
            }
            let bdp = userSegment.bdpSegment?.clientSegment?.segment
            let commercial = userSegment.commercialSegment?.clientSegment?.segment
            let isSmart = (try? bsanManagersProvider.getBsanUserSegmentManager().isSmartUser()) ?? false
            let isPB = user.isPB
            let result = makePrivateSections(isPB: isPB, isSmart: isSmart, bdp: bdp, commercial: commercial)
            
            completion(result)
        } else {
            completion(makePublicSections())
        }
        
    }
    
    private func makePublicSections() -> [CustomerServiceOption] {
        //By now the public section will be generic and Default. Under contruction
        let segmentList = segmentedUserRepository.getSegmentedUserGeneric()
        
        let matcher = SegmentedUserMatcher(isPB: false)
        let segment = matcher.retrieveDefaultSegment(segmentedUser: segmentList)
        var result = [CustomerServiceOption]()

        if let contactList = buildContactList(from: segment) {
            result.append(.contact(contactList))
        }
        
        if let socialNetworks = buildSocialNetworks(contacts: segment?.contact) {
            result += socialNetworks
        }
        
        return result
    }
    
    typealias ContactData = (String?, String?, String?, String?)
    private func buildContactList(from segment: CommercialSegmentsDTO?) -> [ContactData]? {
        var contactList = [(String?, String?, String?, String?)]()
        guard let segment = segment else { return nil }
        let commercialSegment = CommercialSegmentEntity(dto: segment)

        if let superlinea = commercialSegment.contact?.superlinea {
            contactList.append(getContactPhone(superlinea))
        }
        if let cardBlock = commercialSegment.contact?.cardBlock {
            contactList.append(getContactPhone(cardBlock))
        }
        if let fraudFeedback = commercialSegment.contact?.fraudFeedback {
            contactList.append(getContactPhone(fraudFeedback))
        }
        
        if contactList.count > 0 {
            return contactList
        }
        
        return nil
    }
    
    private func getContactPhone(_ contact: ContactPhoneEntity) -> ContactData {
        let number1 = contact.numbers?.first
        var number2: String?
        if let numbers = contact.numbers, numbers.count > 1 {
            number2 = numbers[1]
        }
        return ContactData(contact.title, contact.desc, number1, number2)
    }
    
    private func makePrivateSections(isPB: Bool, isSmart: Bool, bdp: String?, commercial: String?) -> [CustomerServiceOption] {
        let matcher = SegmentedUserMatcher(isPB: isPB, repository: segmentedUserRepository)
        guard let segment = matcher.retrieveUserSegment(bdpType: bdp, comCode: commercial) else {
            return [CustomerServiceOption]()
        }

        var result = [CustomerServiceOption]()
        
        if let contactList = buildContactList(from: segment) {
            result.append(.contact(contactList))
        }
        
        let isSelect = CommercialSegmentEntity(dto: segment).isSelect
        
        let isChatEnabled = appConfigRepository.getAppConfigBooleanNode(nodeName: DomainConstant.appConfigEnableChat)
        if isChatEnabled == true && (isPB || isSelect || isSmart) {
            result.append(.chat(isSmart: isSmart))
        }
       
        let isVirtualAssistantEnabled = appConfigRepository.getAppConfigBooleanNode(nodeName: DomainConstant.appConfigEnableVirtualAssistant)
        if isVirtualAssistantEnabled == true {
            result.append(.help)
        }
        
        result.append(.appointment)
        
        if let socialNetworks = buildSocialNetworks(contacts: segment.contact) {
            result += socialNetworks
        }
        
        return result
    }
    
    private func buildSocialNetworks(contacts: ContactSegmentDTO?) -> [CustomerServiceOption]? {
        var socialNetworks = [CustomerServiceOption]()
        if let whatsApp = contacts?.contactWhatsapp, whatsApp.active == .yes {
            socialNetworks.append(.whatsApp(detail: whatsApp.hint, phone: whatsApp.phone))
        }
        if let email = contacts?.contactMail, email.active == .yes {
            socialNetworks.append(.email(detail: email.hint, email: email.mail))
        }
        if let facebook = contacts?.contactFacebook, facebook.active == .yes {
            socialNetworks.append(.socialNetworks([.facebook(url: facebook.url, appURL: facebook.appUrl)]))
        }
        if let twitter = contacts?.contactTwitter, twitter.active == .yes {
            socialNetworks.append(.socialNetworks([.twitter(url: twitter.url, appURL: twitter.appUrl)]))
        }

        if socialNetworks.count > 0 {
           return socialNetworks
        }
        return nil
    }
    
    private func getPersistedUser(completion: @escaping (PersistedUser?) -> Void) {
            UseCaseWrapper(with: useCaseProvider.getPersistedUserUseCase(),
                           useCaseHandler: useCaseHandler,
                           errorHandler: errorHandler,
                           onSuccess: { result in
                            completion(result.getPersistedUserDTO())
                },
                           onError: { _ in
                            completion(nil)
            })
        }
    
    func checkRepositoryResponse<T>(_ bsanResponse: BSANResponse<T>) throws -> T? {
        if bsanResponse.isSuccess() {
            return try bsanResponse.getResponseData()
        }
        throw IllegalResponseException("illegal response")
    }
}
