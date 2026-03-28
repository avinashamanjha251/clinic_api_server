import Vapor

struct AppConfig {
    static let brandName = "Monalisha Dental Care and OPG Centre"
    static let contactEmail = Environment.get(environmentKey: .SMTP_USERNAME) ?? "monalishadentalcareandopgcentr@gmail.com"
    static let phoneNumber = "+91 7050554772"
    static let phoneLink = "tel:7050554772"
    static let address = "Bhagwati Smriti, Ward Number 31, June Bandh, Deoghar"
    static let hours = "Mon-Sun: 10:00 AM - 09:00 PM"
    static let emergencyContact = "+91 7050554772"
    static let tagline = "Your Smile, Our Priority"
}
