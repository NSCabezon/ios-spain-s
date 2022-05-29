import CoreFoundationLib
import RetailLegacy

class WidgetRepositoryImpl: WidgetRepository {
    private let daoLanguage: DAOLanguage
    
    init(daoLanguage: DAOLanguage) {
        self.daoLanguage = daoLanguage
    }
    
    func getLanguage() -> RepositoryResponse<LanguageType?> {
        return LocalResponse(daoLanguage.get())
    }
}
