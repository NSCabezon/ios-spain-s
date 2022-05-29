
public struct ContactDTO {
    public let twitterContact: SocialNetworksContactDTO?
    public let facebookContact: SocialNetworksContactDTO?
    public let googlePlusContact: SocialNetworksContactDTO?
    public let whatsAppContact: SimpleContactDTO?
    public let mailContact: SimpleContactDTO?
    public let contactAreas: [ContactAreaDTO]
}
