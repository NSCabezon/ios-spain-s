struct AppInfoDO {
    
    let dto: AppInfoDTO
    let osVersion: String
    let appVersion: String
    
    init(dto: AppInfoDTO, osVersion: String, appVersion: String) {
        self.dto = dto
        self.osVersion = osVersion
        self.appVersion = appVersion
    }
}
