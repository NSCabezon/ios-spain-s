import Foundation
import CoreFoundationLib

public class NumberCipherFormat{
    
    public class func decipherNumber(message: String, key: String) -> NumberCipherDTO{
        var numberCipher = NumberCipherDTO()

        if let clave = key.substring(0, 32){
            do{
                try numberCipher.numDecrypted = DataCipher.decryptDESde(message, clave)
            }
            catch _ as NSError{}
        }
        
        return numberCipher
    }
}
