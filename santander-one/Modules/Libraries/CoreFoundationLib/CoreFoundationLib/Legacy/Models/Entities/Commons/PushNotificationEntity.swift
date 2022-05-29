public struct PushNotificationEntity {
	public let id: String
	public let title: String
	public let message: String
	public let date: Date?
	public let isRead: Bool
	
	public init(id: String, title: String, message: String, date: Date? = nil, isRead: Bool) {
		self.id = id
		self.title = title
		self.message = message
		self.date = date
		self.isRead = isRead
	}
}

extension PushNotificationEntity: PushNotificationConformable {}
