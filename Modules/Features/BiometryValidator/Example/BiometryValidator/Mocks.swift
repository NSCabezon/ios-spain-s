//
//  Mocks.swift
//  BiometryValidator_Example
//
//  Created by Rubén Márquez Fernández on 26/5/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import CoreFoundationLib
import SANLibraryV3
import Operative
import UI
import Contacts
import BiometryValidator
import Ecommerce
import CoreDomain

class SegmentedUserRepositoryMock: SegmentedUserRepositoryProtocol {
    
    func getSegmentedUser() -> SegmentedUserDTO? {
        return nil
    }
    
    func getSegmentedUserSpb() -> [SegmentedUserTypeDTO]? {
        return nil
    }
    
    func getSegmentedUserGeneric() -> [SegmentedUserTypeDTO]? {
        return nil
    }
}

class PullOffersInterpreterMock: PullOffersInterpreter {
    func isValid(tip: PullOffersConfigTipDTO, reload: Bool) -> Bool {
        return false
    }
    
    func validForContract(category: PullOffersConfigCategoryDTO, reload: Bool) -> [OfferDTO]? {
        return nil
    }
    
    func getCandidate(userId: String, location: PullOfferLocation) -> OfferDTO? {
        return nil
    }
    
    func getValidOffer(offerId: String) -> OfferDTO? {
        return nil
    }
    
    func getOffer(offerId: String) -> OfferDTO? {
        return nil
    }
    
    func setCandidates(locations: [String: [String]], userId: String, reload: Bool) {
        
    }
    
    func expireOffer(userId: String, offerDTO: OfferDTO) {
        
    }
    
    func removeOffer(location: String) {
        
    }
    
    func disableOffer(identifier: String?) {
    }
    
    func reset() {
        
    }
    
    func isLocationVisitedInSession(location: PullOfferLocation) -> Bool {
        return false
    }
}

class TrackerManagerMock: TrackerManager {
    
    func trackScreen(screenId: String, extraParameters: [String: String]) {
        print("TrackScreen screenId: \(screenId), extraParameters: \(extraParameters)", separator: ",", terminator: "\n")
    }
    
    func trackEvent(screenId: String, eventId: String, extraParameters: [String: String]) {
        print("TrackEvent (eventId: \(eventId), screenId: \(screenId), extraParameters: \(extraParameters)", separator: ",", terminator: "\n")
    }
    
    func trackEmma(token: String) {
        print("METRICS token Emma: \(token)")
    }
}

class ContactPermissionsManagerMock: ContactPermissionsManagerProtocol {
    
    func isContactsAccessEnabled() -> Bool {
        true
    }
    
    func isAlreadySet(completion: @escaping (Bool) -> Void) {
        completion(true)
    }
    
    func askAuthorizationIfNeeded(completion: @escaping (Bool) -> Void) {
        completion(true)
    }
    
    func getContacts(includingImages: Bool, completion: @escaping ([UserContactEntity]?, ContactsPersmissionStatus) -> Void) {
        let phone = UserContactPhoneEntity(alias: "Movil", number: "8885555512")
        let contact = UserContactEntity(identifier: "HJ45iio", name: "John", surname: "Appleseed", thumbnail: nil, phones: [phone])
        completion([contact], ContactsPersmissionStatus.success)
    }
}

extension ViewController: GlobalPositionReloader {
    func reloadGlobalPosition() {
        self.reloadEngine.globalPositionDidReload()
    }
}

extension ViewController: OperativeLauncherHandler {
    var dependenciesResolver: DependenciesResolver {
        return self.dependencies
    }
    
    var operativeNavigationController: UINavigationController? {
        return self.navController
    }
    
    func showOperativeLoading(completion: @escaping () -> Void) {
        self.showLoading(title: localized("generic_popup_loadingContent"), subTitle: localized("loading_label_moment"), completion: completion)
    }
    
    func hideOperativeLoading(completion: @escaping () -> Void) {
        self.dismissLoading(completion: completion)
    }
    
    func showOperativeAlertError(keyTitle: String?, keyDesc: String?, completion: (() -> Void)?) {
        print("ERROR!!")
        print(keyDesc ?? "")
        completion?()
    }
}

extension ViewController: LoadingViewPresentationCapable {
    var associatedLoadingView: UIViewController {
        return self.presentingViewController ?? self.presentedViewController ?? self
    }
}

extension ViewController: OperativeContainerCoordinatorDelegate {
    func executeOffer(_ offer: OfferRepresentable) {
    }
    
    func handleOpinator(_ opinator: OpinatorInfoProtocol) {
    }
    
    func handleGiveUpOpinator(_ opinator: OpinatorInfoProtocol, completion: @escaping () -> Void) {
        completion()
    }
    
    func handleWebView(with data: Data, title: String) {
    }
    
    func executeOffer(_ offer: OfferEntity) {
        
    }
}

class ContactPermissionsManager: ContactPermissionsManagerProtocol {
    func getContacts(includingImages: Bool, completion: @escaping ([UserContactEntity]?, ContactsPersmissionStatus) -> Void) {
        completion(
            [
                UserContactEntity(identifier: "0001", name: "Paquito", surname: "String", thumbnail: nil, phones: [UserContactPhoneEntity(alias: "", number: "722568844")]),
                UserContactEntity(identifier: "0002", name: "Norberto", surname: "String", thumbnail: nil, phones: [UserContactPhoneEntity(alias: "", number: "655107540")]),
                UserContactEntity(identifier: "0003", name: "Adac", surname: "String", thumbnail: nil, phones: [UserContactPhoneEntity(alias: "", number: "666666668")]),
                UserContactEntity(identifier: "0004", name: "Taema", surname: "String", thumbnail: nil, phones: [UserContactPhoneEntity(alias: "", number: "666666669")]),
                UserContactEntity(identifier: "0005", name: "OPAsda", surname: "String", thumbnail: nil, phones: [UserContactPhoneEntity(alias: "", number: "666666610")])
            ],
            .success)
    }
    
    func isContactsAccessEnabled() -> Bool {
        return true
    }
    
    func isAlreadySet(completion: @escaping (Bool) -> Void) {
        completion(true)
    }
    
    func askAuthorizationIfNeeded(completion: @escaping (Bool) -> Void) {
        completion(true)
    }
}

class RepositoryResponseFake<P>: RepositoryResponse<P> {
    override func isSuccess() -> Bool {
        return true
    }
    
    override func getResponseData() throws -> P? {
        return nil
    }
    
    override func getErrorCode() throws -> CLong {
        return 0
    }
    
    override func getErrorMessage() throws -> String {
        return ""
    }
}

class AppConfigRepositoryFake: AppConfigRepositoryProtocol {
    func getAppConfigListNode<T>(_ nodeName: String, object: T.Type, options: AppConfigDecodeOptions) -> [T]? where T : Decodable {
        return nil
    }
    
    func getInt(_ nodeName: String) -> Int? {
        return nil
    }
    
    func getAppConfigListNode(_ nodeName: String) -> [String]? {
        return nil
    }
    
    func getBool(_ nodeName: String) -> Bool? {
        return nil
    }
    
    func getDecimal(_ nodeName: String) -> Decimal? { return nil }
    func getString(_ nodeName: String) -> String? { return nil }
}

class FaqsRepositoryFake: FaqsRepositoryProtocol {
    func getFaqsList(_ type: FaqsType) -> [FaqDTO] {
        return []
    }
    
    func getFaqsList() -> FaqsListDTO? {
        return nil
    }
}

final class GetLanguagesSelectionUseCaseMock: GetLanguagesSelectionUseCase {
    private var output = GetLanguagesSelectionUseCaseOkOutput(current: Language.createFromType(languageType: .spanish,
                                                                                               isPb: false))
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetLanguagesSelectionUseCaseOkOutput, StringErrorOutput> {
        return UseCaseResponse.ok(output)
    }
}
