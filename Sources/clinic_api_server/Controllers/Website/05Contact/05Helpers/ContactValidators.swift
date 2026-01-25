import Vapor

struct AppointmentValidator {
    static func validate(_ req: Request) throws {
        // Simple manual validation or use Vapor's Validatable
        // Here we do simple checks as requested
        
        let input = try req.decodeContent(SMCreateAppointmentRequest.self)
        
        if input.name.isEmpty { throw Abort(.badRequest, reason: "Name is required") }
        if input.phone.count < 10 { throw Abort(.badRequest, reason: "Phone must be at least 10 digits") }
        
        // Date check: >= today
        guard input.preferredDate.count > 0 else { throw Abort(.badRequest, reason: "Preferred Date is required") }
        guard let preferredDate = input.preferredDate.toDate(format: .ddMMyyyy) else { throw Abort(.badRequest, reason: "Date format should be ddMMyyyy") }

        if preferredDate < Date().addingTimeInterval(-86400) { // allow some margin for today
            throw Abort(.badRequest, reason: "Date cannot be in the past")
        }
    }
}

struct EmailService {
    static func sendConfirmationStub(to: String) {
        // e.g. print("Sending email to \(to)")
    }
}
