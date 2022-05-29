//

import SANLegacyLibrary

struct DocumentDO {
    let dto: DocumentDTO?
    
    var document: String? {
        return dto?.document
    }
}
