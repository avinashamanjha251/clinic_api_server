import Vapor

struct AppointmentValidator {
    static func validate(_ req: Request) throws {
        // Simple manual validation or use Vapor's Validatable
        // Here we do simple checks as requested
        
        let input = try req.content.decode(SMCreateAppointmentRequest.self)
        
        if input.name.isEmpty { throw Abort(.badRequest, reason: "Name is required") }
        if input.phone.count < 10 { throw Abort(.badRequest, reason: "Phone must be at least 10 digits") }
        
        // Date check: >= today
        if input.preferredDate < Date().addingTimeInterval(-86400) { // allow some margin for today
            throw Abort(.badRequest, reason: "Date cannot be in the past")
        }
    }
}

struct EmailService {
    static func sendConfirmationStub(to: String) {
        // e.g. print("Sending email to \(to)")
    }
}
