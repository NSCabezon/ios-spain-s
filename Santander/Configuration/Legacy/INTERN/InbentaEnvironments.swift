import Foundation
import CoreFoundationLib

struct InbentaEnvironments {
    // Entornos Inbenta
    static let inbentaEndpointProd = "https://santander-avatar.inbenta.com/"
    static let inbentaEndpointStaging = "https://santander.inbenta.com/avatar_staging/"
    
    static let inbentaEnvironmentProd = InbentaEnvironmentDTO("PROD", inbentaEndpointProd, "")
    static let inbentaEnvironmentStaging = InbentaEnvironmentDTO("STAGING", inbentaEndpointStaging, "")
}
