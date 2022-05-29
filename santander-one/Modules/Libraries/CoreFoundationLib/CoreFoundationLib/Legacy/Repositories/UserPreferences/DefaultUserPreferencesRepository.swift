//
//  UserPreferencesRepository.swift
//  CoreFoundationLib
//
//  Created by Jose Ignacio de Juan Díaz on 27/12/21.
//

import CoreDomain
import OpenCombine

public final class DefaultUserPreferencesRepository {
    private let persistenceDataSource: PersistenceDataSource
    private let subject = CurrentValueSubject<UserPrefDTOEntity?, Never>(nil)
    
    public init(persistenceDataSource: PersistenceDataSource) {
        self.persistenceDataSource = persistenceDataSource
    }
}

private extension DefaultUserPreferencesRepository {
    func getUserPreferencesDTO(userId: String) -> UserPrefDTOEntity {
        if let userPrefDTOEntity = persistenceDataSource.getIfExistsUserPrefEntity(userId: userId) {
             userPrefDTOEntity.isSmartUser = isSmartUser()
            if let sharedUserPref = persistenceDataSource.getSharedUserPrefEntity(userId: userId),
               userPrefDTOEntity.updateWithSharedUserPref(sharedUserPref) {
                persistenceDataSource.setUserPrefEntity(userPrefDTOEntity: userPrefDTOEntity)
            }
            return userPrefDTOEntity
        } else if !persistenceDataSource.getUserPref(userId: userId).isMigrationSuccess {
            return migrateUserPreferences(userPrefDTO: persistenceDataSource.getUserPref(userId: userId))
        } else {
            let newUserPref = UserPrefDTOEntity(userId: userId)
            newUserPref.isSmartUser = isSmartUser()
            setUserPreferences(userPref: newUserPref)
            return newUserPref
        }
    }
    
    func isSmartUser() -> Bool {
        return persistenceDataSource.getPersistedUser()?.isSmart ?? false
    }
    
    func convertToPGBoxItemDTOEntity(pgBoxItemDTO: PGBoxItemDTO) -> PGBoxItemDTOEntity {
        return PGBoxItemDTOEntity(order: pgBoxItemDTO.order, isVisible: pgBoxItemDTO.isVisible)
    }
       
    func convertToPGBoxDTOEntity(order: Int, pgBoxDTO: PGBoxDTO) -> PGBoxDTOEntity {
        var productsEntity: [String: PGBoxItemDTOEntity] = [:]
        for product in pgBoxDTO._products {
            productsEntity[product.key] = convertToPGBoxItemDTOEntity(pgBoxItemDTO: product.value)
        }
        return PGBoxDTOEntity(order: order, isOpen: pgBoxDTO.isOpen, products: productsEntity)
    }
    
    func migrateUserPreferences(userPrefDTO: UserPrefDTO) -> UserPrefDTOEntity {
        let userPrefDTOEntity = UserPrefDTOEntity(userId: userPrefDTO.userId)
        userPrefDTOEntity.isUserPb = userPrefDTO.isUserPb
        userPrefDTOEntity.isSmartUser = isSmartUser()
        
        userPrefDTOEntity.pgUserPrefDTO.onboardingFinished = userPrefDTO.pgUserPrefDTO.onboardingFinished
        userPrefDTOEntity.pgUserPrefDTO.otpPushBetaFinished = userPrefDTO.pgUserPrefDTO.otpPushBetaFinished
        userPrefDTOEntity.pgUserPrefDTO.globalPositionOptionSelected = userPrefDTO.pgUserPrefDTO.globalPositionOptionSelected
        userPrefDTOEntity.pgUserPrefDTO.photoThemeOptionSelected = userPrefDTO.pgUserPrefDTO.photoThemeOptionSelected
        
        let oldProducts: [ProductTypeEntity: PGBoxDTO] = [
            .account: userPrefDTO.pgUserPrefDTO.accountsBox,
            .card: userPrefDTO.pgUserPrefDTO.cardsBox,
            .loan: userPrefDTO.pgUserPrefDTO.loansBox,
            .deposit: userPrefDTO.pgUserPrefDTO.depositsBox,
            .stockAccount: userPrefDTO.pgUserPrefDTO.stocksBox,
            .fund: userPrefDTO.pgUserPrefDTO.fundssBox,
            .pension: userPrefDTO.pgUserPrefDTO.pensionssBox,
            .managedPortfolio: userPrefDTO.pgUserPrefDTO.portfolioManagedsBox,
            .notManagedPortfolio: userPrefDTO.pgUserPrefDTO.portfolioNotManagedsBox,
            .insuranceSaving: userPrefDTO.pgUserPrefDTO.insuranceSavingsBox,
            .insuranceProtection: userPrefDTO.pgUserPrefDTO.insuranceProtectionsBox
        ]
        
        for (type, defaultOrder) in ProductTypeEntity.getOrderDictionary(isPb: userPrefDTO.isUserPb) {
            guard let oldProduct = oldProducts[type] else { continue }
            userPrefDTOEntity.pgUserPrefDTO.boxes[UserPrefBoxType(type: type)] = convertToPGBoxDTOEntity(order: defaultOrder, pgBoxDTO: oldProduct)
        }
        userPrefDTOEntity.pgUserPrefDTO.resetBoxesConfiguration()
        userPrefDTO.isMigrationSuccess = true
        persistenceDataSource.setUserPref(userPrefDTO: userPrefDTO)
        persistenceDataSource.setUserPrefEntity(userPrefDTOEntity: userPrefDTOEntity)
        
        return userPrefDTOEntity
    }
    
    private func convertToPGBoxDTOEntity(pGBoxItemDTOEntity: PGBoxItemDTOEntity) -> PGBoxItemDTO {
        return PGBoxItemDTO(order: pGBoxItemDTOEntity.order, isVisible: pGBoxItemDTOEntity.isVisible)
    }

    func convertToPGBoxDTO(order: Int, pgBoxDTOEntity: PGBoxDTOEntity) -> PGBoxDTO {
        var productsEntity: [String: PGBoxItemDTO] = [:]
        for product in pgBoxDTOEntity.products {
            productsEntity[product.key] = convertToPGBoxDTOEntity(pGBoxItemDTOEntity: product.value)
        }
        
        return PGBoxDTO(isOpen: pgBoxDTOEntity.isOpen, _products: productsEntity)
    }
    
    func migrateUserPreferencesToOld(userPrefDTOEntity: UserPrefDTOEntity) -> UserPrefDTO? {
        let userPrefDTO = persistenceDataSource.getUserPref(userId: userPrefDTOEntity.userId)
        userPrefDTO.isUserPb = userPrefDTOEntity.isUserPb
        userPrefDTO.pgUserPrefDTO.onboardingFinished = userPrefDTOEntity.pgUserPrefDTO.onboardingFinished
        userPrefDTO.pgUserPrefDTO.otpPushBetaFinished = userPrefDTOEntity.pgUserPrefDTO.otpPushBetaFinished
        userPrefDTO.pgUserPrefDTO.globalPositionOptionSelected = userPrefDTOEntity.pgUserPrefDTO.globalPositionOptionSelected
        if let photoTheme = userPrefDTOEntity.pgUserPrefDTO.photoThemeOptionSelected { userPrefDTO.pgUserPrefDTO.photoThemeOptionSelected = photoTheme}
        userPrefDTOEntity.pgUserPrefDTO.sortedProducts.enumerated().forEach { (product) in
            
            let convertedProduct = convertToPGBoxDTO(order: product.offset, pgBoxDTOEntity: product.element.1)
            if product.element.0 == UserPrefBoxType.account {
                userPrefDTO.pgUserPrefDTO.accountsBox = convertedProduct
            }
            if product.element.0 == UserPrefBoxType.card {
                userPrefDTO.pgUserPrefDTO.cardsBox = convertedProduct
            }
            if product.element.0 == UserPrefBoxType.loan {
                userPrefDTO.pgUserPrefDTO.loansBox = convertedProduct
            }
            if product.element.0 == UserPrefBoxType.deposit {
                userPrefDTO.pgUserPrefDTO.depositsBox = convertedProduct
            }
            if product.element.0 == UserPrefBoxType.stock {
                userPrefDTO.pgUserPrefDTO.stocksBox = convertedProduct
            }
            if product.element.0 == UserPrefBoxType.fund {
                userPrefDTO.pgUserPrefDTO.fundssBox = convertedProduct
            }
            if product.element.0 == UserPrefBoxType.pension {
                userPrefDTO.pgUserPrefDTO.pensionssBox = convertedProduct
            }
            if product.element.0 == UserPrefBoxType.managedPortfolio {
                userPrefDTO.pgUserPrefDTO.portfolioManagedsBox = convertedProduct
            }
            if product.element.0 == UserPrefBoxType.notManagedPortfolio {
                userPrefDTO.pgUserPrefDTO.portfolioNotManagedsBox = convertedProduct
            }
            if product.element.0 == UserPrefBoxType.insuranceSaving {
                userPrefDTO.pgUserPrefDTO.insuranceSavingsBox = convertedProduct
            }
            if product.element.0 == UserPrefBoxType.insuranceProtection {
                userPrefDTO.pgUserPrefDTO.insuranceProtectionsBox = convertedProduct
            }
        }
        
        return userPrefDTO
    }
    
    func setUserPreferences(userPref: UserPrefDTOEntity) {
        //TODO: Remove when stop using userPrefDTO
        if let newUserPref = migrateUserPreferencesToOld(userPrefDTOEntity: userPref) {
            let response = setUserPrefDTO(userPrefDTO: newUserPref)
            if response.isSuccess() {
                _ = setUserPrefDTOEntity(userPrefDTOEntity: userPref)
                persistenceDataSource.setSharedUserPrefEntity(userPref: userPref.asShared())
            }
        }
    }
    
    func setUserPrefDTO(userPrefDTO: UserPrefDTO) -> RepositoryResponse<Void> {
        persistenceDataSource.setUserPref(userPrefDTO: userPrefDTO)
        return OkEmptyResponse()
    }
    
    func setUserPrefDTOEntity(userPrefDTOEntity: UserPrefDTOEntity) -> RepositoryResponse<Void> {
        persistenceDataSource.setUserPrefEntity(userPrefDTOEntity: userPrefDTOEntity)
        return OkEmptyResponse()
    }
}

extension DefaultUserPreferencesRepository: UserPreferencesRepository {
    public func getUserPreferences(userId: String) -> AnyPublisher<UserPreferencesRepresentable, Error> {
        subject
            .map { [unowned self] userPrefDTOEntity -> UserPrefDTOEntity in
                return userPrefDTOEntity ?? self.getUserPreferencesDTO(userId: userId)
            }
            .map { userPrefDTOEntity in
                return UserPrefEntity.from(dto: userPrefDTOEntity)
            }
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    public func updateUserPreferences(update: UpdateUserPreferencesRepresentable) {
        let userPrefDTO = getUserPreferencesDTO(userId: update.userId)
        if let alias = update.alias {
            userPrefDTO.pgUserPrefDTO.alias = alias
        }
        if let photoThemeOptionSelected = update.photoThemeOptionSelected {
            userPrefDTO.pgUserPrefDTO.photoThemeOptionSelected = photoThemeOptionSelected
        }
        if let globalPositionOptionSelected = update.globalPositionOptionSelected {
            userPrefDTO.pgUserPrefDTO.globalPositionOptionSelected = globalPositionOptionSelected.value()
        }
        if let pgColorMode = update.pgColorMode {
            userPrefDTO.pgUserPrefDTO.pgColorMode = pgColorMode
        }
        if let isPrivateMenuCoachManagerShown = update.isPrivateMenuCoachManagerShown {
            userPrefDTO.pgUserPrefDTO.isPrivateMenuCoachManagerShown = isPrivateMenuCoachManagerShown
        }
        subject.send(userPrefDTO)
        setUserPreferences(userPref: userPrefDTO)
    }
}
