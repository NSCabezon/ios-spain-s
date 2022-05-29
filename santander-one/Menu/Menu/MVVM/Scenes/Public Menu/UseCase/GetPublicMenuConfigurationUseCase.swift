import Foundation
import OpenCombine
import CoreFoundationLib
import RxCombine

public protocol GetPublicMenuConfigurationUseCase {
    func fetchMenuConfiguration() -> AnyPublisher<[[PublicMenuElementRepresentable]], Never>
}

struct DefaultGetPublicMenuConfigurationUseCase {
    private var repository: PublicMenuRepository
    private let appConfigRepository: AppConfigRepositoryProtocol
    
    init(dependencies: PublicMenuDependenciesResolver) {
        self.repository = dependencies.external.resolve()
        self.appConfigRepository = dependencies.external.resolve()
    }
}

extension DefaultGetPublicMenuConfigurationUseCase: GetPublicMenuConfigurationUseCase {
    func fetchMenuConfiguration() -> AnyPublisher<[[PublicMenuElementRepresentable]], Never> {
        return Publishers.Zip(
            getBoolPublishers(),
            getStringPublisher()
        )
        .combineLatest(repository.getPublicMenuConfiguration())
        .map({ response in
            let ((boolNodes, stringNodes), country) = response
            return self.filterOptions(boolNodes: boolNodes,
                                      stringNodes: stringNodes,
                                      countryConfiguration: country)
        })
        .eraseToAnyPublisher()
    }
}

private extension DefaultGetPublicMenuConfigurationUseCase {
    
    struct PublicMenuOption: PublicMenuElementRepresentable {
        var top: PublicMenuOptionRepresentable?
        var bottom: PublicMenuOptionRepresentable?
        
        init(top: PublicMenuOptionRepresentable?, bottom: PublicMenuOptionRepresentable?) {
            self.top = top
            self.bottom = bottom
        }
    }
    
    func getBoolPublishers() -> AnyPublisher<[String: Bool], Never> {
        appConfigRepository.values(for: [PublicMenuConstants.enableLoanRepayment: false,
                                         PublicMenuConstants.enableChangeLoanLinkedAccount: false,
                                         PublicMenuConstants.enablePublicProducts: false,
                                         PublicMenuConstants.enableStockholders: false,
                                         PublicMenuConstants.enablePricingConditions: false])
    }
    
    func getStringPublisher() -> AnyPublisher<[String: String], Never> {
        appConfigRepository.values(for: [PublicMenuConstants.recoverPassword: "",
                                         PublicMenuConstants.mobileWeb: "",
                                         PublicMenuConstants.getMagic: "",
                                         PublicMenuConstants.becomeClient: "",
                                         PublicMenuConstants.recoverProcess: "",
                                         PublicMenuConstants.prepaidLogin: "",
                                         PublicMenuConstants.shareHolders: ""])
    }
    
    func filterOptions(boolNodes: [String: Bool], stringNodes: [String: String], countryConfiguration: [[PublicMenuElementRepresentable]]) -> [[PublicMenuElementRepresentable]] {
        return countryConfiguration.map { (config) in
            return config.map {
                let top = evaluateNode(option: $0.top, boolNodes: boolNodes, stringNodes: stringNodes)
                let bottom = evaluateNode(option: $0.bottom, boolNodes: boolNodes, stringNodes: stringNodes)
                return PublicMenuOption(top: top, bottom: bottom)
            }
        }
    }
    
    func evaluateNode(option: PublicMenuOptionRepresentable?, boolNodes: [String: Bool], stringNodes: [String: String]) -> PublicMenuOptionRepresentable? {
        guard var optUnwrapped = option else { return nil }
        switch optUnwrapped.type {
        case let .flipButton(principalItem: principalItem, secondaryItem: secondaryItem, time: time):
            optUnwrapped.type = .flipButton(principalItem: evaluateNode(option: principalItem,
                                                                                boolNodes: boolNodes,
                                                                                stringNodes: stringNodes) ?? principalItem,
                                            secondaryItem: evaluateNode(option: secondaryItem,
                                                                                boolNodes: boolNodes,
                                                                                stringNodes: stringNodes) ?? secondaryItem,
                                            time: time)
            return optUnwrapped
        case let .selectOptionButton(options: subOptions):
            optUnwrapped.type = evaluateMultiOptionsType(optionType: subOptions, boolNodes: boolNodes, stringNodes: stringNodes)
            return optUnwrapped
        default:
            return evaluateSingleOption(option: optUnwrapped, boolNodes: boolNodes, stringNodes: stringNodes)
        }
    }
    
    func evaluateSingleOption(option: PublicMenuOptionRepresentable?, boolNodes: [String: Bool], stringNodes: [String: String]) -> PublicMenuOptionRepresentable? {
        guard var optUnwrapped = option else { return nil }
        guard let kindOf = option?.kindOfNode, kindOf != .none else { return option }
        let boolConf = boolNodes[kindOf.associatedPublicMenuConstant()]
        let stringConf = stringNodes[kindOf.associatedPublicMenuConstant()]
        guard boolConf != nil || stringConf != nil else { return option }
        if boolConf == true {
            return optUnwrapped
        }
        if let actionValue = stringConf, !actionValue.isEmpty {
            optUnwrapped.action = optUnwrapped.action.addAssociatedValue(actionValue)
            return optUnwrapped
        }
        return nil
    }
    
    func evaluateMultiOptionsType(optionType: [SelectOptionButtonModelRepresentable], boolNodes: [String: Bool], stringNodes: [String: String]) -> PublicMenuOptionType {
        let newOptions: [SelectOptionButtonModelRepresentable] =
            optionType.compactMap {
                guard $0.node != .none else { return $0 }
                let boolConf = boolNodes[$0.node.associatedPublicMenuConstant()]
                let stringConf = stringNodes[$0.node.associatedPublicMenuConstant()]
                if boolConf == true {
                    return $0
                }
                if let actionValue = stringConf, !actionValue.isEmpty {
                    var cpy = $0
                    cpy.action = $0.action.addAssociatedValue(actionValue)
                    return cpy
                }
                return nil
            }
        return .selectOptionButton(options: newOptions)
        
    }
}

extension KindOfPublicMenuNode {
    func associatedPublicMenuConstant() -> String {
        switch self {
        case .recoverPassword:
            return PublicMenuConstants.recoverPassword
        case .mobileWeb:
            return PublicMenuConstants.mobileWeb
        case .getMagic:
            return PublicMenuConstants.getMagic
        case .becomeClient:
            return PublicMenuConstants.becomeClient
        case .recoverProcess:
            return PublicMenuConstants.recoverProcess
        case .enablePublicProducts:
            return PublicMenuConstants.enablePublicProducts
        case .enableStockholders:
            return PublicMenuConstants.enableStockholders
        case .prepaidLogin:
            return PublicMenuConstants.prepaidLogin
        case .shareHolders:
            return PublicMenuConstants.shareHolders
        case .enablePricingConditions:
            return PublicMenuConstants.enablePricingConditions
        case .enableLoanRepayment:
            return PublicMenuConstants.enableLoanRepayment
        case .enableChangeLoanLinkedAccount:
            return PublicMenuConstants.enableChangeLoanLinkedAccount
        case .commercialSegment, .none:
            return ""
        }
    }
}

extension PublicMenuAction {
    func addAssociatedValue(_ value: String) -> PublicMenuAction {
        switch self {
        case .openURL:
            return .openURL(url: value)
        case .callPhone:
            return .callPhone(number: value)
        case .goToATMLocator, .goToStockholders, .goToOurProducts, .toggleSideMenu, .goToHomeTips, .none, .custom(action: _), .comingSoon:
            return self
        }
    }
}
