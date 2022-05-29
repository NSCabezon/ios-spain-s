//

import Foundation

extension CharacterSet {
    
    static var signature: CharacterSet {
        return CharacterSet(charactersIn: "1234567890qwertyuiopasdfghjklñzxcvbnmQWERTYUIOPÑLKJHGFDSAZXCVBNM")
    }
    
    static var iban: CharacterSet {
        return CharacterSet(charactersIn: "1234567890QWERTYUIOPLKJHGFDSAZXCVBNM")
    }
    
    static var custom: CharacterSet {
        return CharacterSet(charactersIn: "1234567890qwertyuiopasdfghjklñzxcvbnmQWERTYUIOPÑLKJHGFDSAZXCVBNM _,.:-?/()+áéíóúÁÉÍÓÚÇç'")
    }
    
    static var ibanNoSepa: CharacterSet {
        return CharacterSet(charactersIn: "1234567890qwertyuiopasdfghjklñzxcvbnmQWERTYUIOPÑLKJHGFDSAZXCVBNM")
    }
}
