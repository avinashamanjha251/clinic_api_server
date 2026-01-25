import Vapor

struct ContactRoutes {
    static func configure(_ r: RoutesBuilder) throws {
        let contact = r.grouped("contact")
        
        // Protected endpoint
        contact.grouped(try SimpleBasicAuthMiddleware())
               .post("appointment", use: ContactViewModel.createAppointment)
        
        contact.get("info", use: ContactViewModel.getContactInfo)
    }
}
