import PrivateMenu
import OpenCombine
import CoreDomain
import CoreFoundationLib

typealias SofiaTypeAction = (type: SofiaInvestmentOptionType, action: PrivateSubmenuAction)

struct ESPrivateMenuSofiaInvestmentUseCase: GetSofiaInvestmentSubMenuUseCase {
    private let offers: GetCandidateOfferUseCase
    private let globalPositionRepository: GlobalPositionDataRepository
    private let boxes: GetGlobalPositionBoxesUseCase
    private let boxesCount: GetMyProductsUseCase
    private let appConfigRepository: AppConfigRepositoryProtocol
    
    init(dependencies: PrivateMenuModuleExternalDependenciesResolver) {
        offers = dependencies.resolve()
        globalPositionRepository = dependencies.resolve()
        boxes = dependencies.resolve()
        appConfigRepository = dependencies.resolve()
        boxesCount = dependencies.resolve()
    }
    
    func fetchSubMenuOptions() -> AnyPublisher<[PrivateMenuSectionRepresentable], Never> {
        return options
    }
}

private extension ESPrivateMenuSofiaInvestmentUseCase {
    var isPb: AnyPublisher<Bool, Never> {
        return globalPositionRepository
            .getGlobalPosition()
            .map(\.isPb)
            .replaceNil(with: false)
            .eraseToAnyPublisher()
    }
    
    var options: AnyPublisher<[PrivateMenuSectionRepresentable], Never> {
        return investmentItems
            .zip(wantInvestItems, toolsItems) { investmentItems, wantInvestItems, toolsItems in
                return investmentItems + wantInvestItems + toolsItems
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Investment position
    var isNotManagedPortfolio: AnyPublisher<Bool, Never> {
        boxes.fetchBoxesVisibles()
            .map { return $0.contains(.notManagedPortfolio) }
            .eraseToAnyPublisher()
    }
    
    var isStockholders: AnyPublisher<Bool, Never> {
        return appConfigRepository
            .value(for: "enableStockholders", defaultValue: false)
            .eraseToAnyPublisher()
    }
    
    var isManagedPortfolio: AnyPublisher<Bool, Never> {
        boxes.fetchBoxesVisibles()
            .map { return $0.contains(.managedPortfolio) }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Investment position
    var investmentItems: AnyPublisher<[PrivateMenuSectionRepresentable], Never> {
        let investmentPosition = isLocation("SIDE_INVESTMENT_MENU_POSITION")
        let ordersSigning = isLocation("FIRMA_ORDENES")
        let unadvisedOrders = isLocation("ORDENES_NO_ASESORADAS")
        let sofiaOrder = isLocation("SOFIA_ORDENES")
        var options: [PrivateSubmenuAction] = []
        return investmentPosition
            .zip(isNotManagedPortfolio, isPb) { investment, notManaged, isPb -> [PrivateSubmenuAction] in
                if let investment = investment {
                    options.append(.sofiaOffer(.investmentPosition, investment))
                }
                if notManaged && isPb {
                    options.append(.sofiaOffer(.notManagedPortfolios, nil))
                }
                return options
            }
            .zip(isManagedPortfolio, isPb) { _, managed, isPb  -> [PrivateSubmenuAction] in
                if managed && isPb {
                    options.append(.sofiaOffer(.managedPortfolios, nil))
                }
                return options
            }
            .zip(ordersSigning, isPb) { _, signing, isPb -> [PrivateSubmenuAction] in
                if isPb, let signing = signing {
                    options.append(.sofiaOffer(.ordersSigning, signing))
                }
                return options
            }
            .zip(unadvisedOrders, isPb) { _, unadvised, isPb -> [PrivateSubmenuAction] in
                if isPb, let unadvised = unadvised {
                    options.append(.sofiaOffer(.unadvisedOrders, unadvised))
                }
                return options
            }
            .zip(sofiaOrder) { _, order -> [PrivateSubmenuAction] in
                if let order = order {
                    options.append(.sofiaOffer(.sofiaOrder, order))
                }
                return options
            }
            .combineLatest(boxesCount.fetchMyProducts().replaceError(with: [:]), { items, data in
                buildSection(options: items, boxes: data)
            })
            .eraseToAnyPublisher()
    }
     
     // MARK: - I WANT TO INVEST SECTION
     var wantInvestItems: AnyPublisher<[PrivateMenuSectionRepresentable], Never> {
     let stocks = isLocation("SIDE_INVESTMENT_MENU_STOCKS")
     let fixedRent = isLocation("SIDE_INVESTMENT_MENU_FIXED_RENT")
     let guaranteed = isLocation("SIDE_INVESTMENT_MENU_GUARANTEED")
     let foreignExchange = isLocation("SIDE_INVESTMENT_MENU_FOREINGN_EXCHANGE")
     let funds = isLocation("SIDE_INVESTMENT_MENU_FUNDS")
     let pensions = isLocation("SIDE_INVESTMENT_MENU_PENSION_PLANS")
     let roboadvisor = isLocation("SIDE_INVESTMENT_MENU_ROBOADVISOR")
     var options: [PrivateSubmenuAction] = []
         return stocks
             .zip(fixedRent, guaranteed) { stocks, fixed, guaranteed -> [PrivateSubmenuAction] in
                 if let stocks = stocks {
                     options.append(.sofiaOffer(.stocks, stocks))
                 }
                 if let fixed = fixed {
                     options.append(.sofiaOffer(.fixedRent, fixed))
                 }
                 if let guaranteed = guaranteed {
                     options.append(.sofiaOffer(.guaranteed, guaranteed))
                 }
                 return options
             }
             .zip(foreignExchange, funds) { _, foreignExchange, funds -> [PrivateSubmenuAction] in
                 if let foreignExchange = foreignExchange {
                     options.append(.sofiaOffer(.foreignExchange, foreignExchange))
                 }
                 if let funds = funds {
                     options.append(.sofiaOffer(.funds, funds))
                 }
                 return options
             }
             .zip(pensions, roboadvisor) { _, pensions, roboadvisor -> [PrivateSubmenuAction] in
                 if let pensions = pensions {
                     options.append(.sofiaOffer(.pensions, pensions))
                 }
                 if let roboadvisor = roboadvisor {
                     options.append(.sofiaOffer(.roboadvisor, roboadvisor))
                 }
                 return options
             }
             .combineLatest(boxesCount.fetchMyProducts().replaceError(with: [:]), { items, data -> [PrivateMenuSectionRepresentable] in
                 buildSection(titleKey: "menuInvestment_title_wantInvest", options: items, boxes: data)
             })
     .eraseToAnyPublisher()
     }
     
     // MARK: - TOOLS SECTION
    var toolsItems: AnyPublisher<[PrivateMenuSectionRepresentable], Never> {
        let investmentAlerts = isLocation("SIDE_INVESTMENT_MENU_ALERTS")
        let newTestMifid = isLocation("SIDE_INVESTMENT_MENU_MIFID_TEST")
        let sofiaMarket = isLocation("SOFIA_MERCADOS")
        let sofiaFavourite = isLocation("SOFIA_FAVORITOS")
        let sofiaAnalysis = isLocation("SOFIA_ANALISIS")
        let sofiaGuidance = isLocation("SOFIA_ORIENTA")
        var options: [PrivateSubmenuAction] = []
        return isStockholders
            .zip(investmentAlerts, newTestMifid) { stockHolder, investmentAlerts, newTestMifid -> [PrivateSubmenuAction] in
                if stockHolder {
                    options.append(.sofiaOffer(.shareholders, nil))
                }
                if let investmentAlerts = investmentAlerts {
                    options.append(.sofiaOffer(.investmentAlerts, investmentAlerts))
                }
                if let newTestMifid = newTestMifid {
                    options.append(.sofiaOffer(.newTestMifid, newTestMifid))
                }
                return options
            }
            .zip(sofiaMarket, sofiaFavourite) { _, market, favourite -> [PrivateSubmenuAction] in
                if let market = market {
                    options.append(.sofiaOffer(.sofiaMarket, market))
                }
                if let favourite = favourite {
                    options.append(.sofiaOffer(.sofiaFavourite, favourite))
                }
                return options
            }
            .zip(sofiaAnalysis, sofiaGuidance) { _, analysis, guidance -> [PrivateSubmenuAction] in
                if let analysis = analysis {
                    options.append(.sofiaOffer(.sofiaAnalysis, analysis))
                }
                if let guidance = guidance {
                    options.append(.sofiaOffer(.sofiaGuidance, guidance))
                }
                return options
            }
            .combineLatest(boxesCount.fetchMyProducts().replaceError(with: [:]), { items, data -> [PrivateMenuSectionRepresentable] in
                buildSection(titleKey: "menu_title_tools", options: items, boxes: data)
            })
            .eraseToAnyPublisher()
     }
    
    func buildSection(titleKey: String? = nil,
                      options: [PrivateSubmenuAction],
                      boxes: [UserPrefBoxType: PGBoxRepresentable]
    ) -> [PrivateMenuSectionRepresentable] {
        let countedElements = howManyElementsIn(boxes: boxes, from: options)
        let items = options.toOptionRepresentable(countedElements)
        return items.isEmpty ? [] : [PrivateMenuSection(titleKey: titleKey, items: items)]
    }
    
    // MARK: - Helpers
    func isLocation(_ location: String) -> AnyPublisher<OfferRepresentable?, Never> {
        guard let location = PullOffersLocationsFactoryEntity()
                .getLocationRepresentable(locations: sofiaLocations, location: location) else {
                    return Just(nil).eraseToAnyPublisher() }
        return getCandidate(location).eraseToAnyPublisher()
    }
    
    func getCandidate( _ location: PullOfferLocationRepresentable) -> AnyPublisher<OfferRepresentable?, Never> {
        return offers.fetchCandidateOfferPublisher(location: location)
            .flatMap({ offerRepresentable -> AnyPublisher<OfferRepresentable?, Never> in
                return Just(offerRepresentable).eraseToAnyPublisher()
            })
            .replaceError(with: nil)
            .map { $0 }
            .eraseToAnyPublisher()
    }
    
    var sofiaLocations: [PullOfferLocationRepresentable] {
        return PullOffersLocationsFactoryEntity().sofiaInvestment
    }
    
    func howManyElementsIn(boxes: [UserPrefBoxType: PGBoxRepresentable],
                           from myProducts: [PrivateSubmenuAction]) -> [PrivateSubmenuAction: Int] {
        var result = [PrivateSubmenuAction: Int]()
        myProducts.forEach { option in
            result.updateValue(countForOption(option: option, in: boxes), forKey: option)
        }
        return result
    }
    
    func countForOption(option: PrivateSubmenuAction, in boxes: [UserPrefBoxType: PGBoxRepresentable]) -> Int {
        if case let .sofiaOffer(sofia, _) = option {
            switch sofia {
            case .managedPortfolios:
                return boxes[.managedPortfolio]?.productsRepresentable.count ?? 0
            case .notManagedPortfolios:
                return boxes[.notManagedPortfolio]?.productsRepresentable.count ?? 0
            case .shareholders:
                return boxes[.managedPortfolioVariableIncome]?.productsRepresentable.count ?? 0
            default:
                return 0
            }
        } else {
            return 0
        }
    }
}
