import Vapor

struct ContactRoutes {
    static func configure(_ r: RoutesBuilder) throws {
        let contact = r.grouped("contact")
        
        contact.get(use: ContactViewModel.getData)
        
        contact.grouped(try SimpleBasicAuthMiddleware())
               .grouped(DecryptionMiddleware())
               .grouped(EncryptionResponseMiddleware())
               .post("appointment", use: ContactViewModel.createAppointment)
    }
}
