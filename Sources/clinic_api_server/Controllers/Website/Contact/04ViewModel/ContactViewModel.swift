import Vapor
import MongoDBVapor

struct ContactViewModel: ContactViewModelProtocol {
    static let baseViewModel = BaseMongoViewModel<CMAppointment>()
    
    static func createAppointment(_ req: Request) async throws -> Response {
        // 1. Validate
        try AppointmentValidator.validate(req)
        
        // 2. Decode
        let input = try req.content.decode(SMCreateAppointmentRequest.self)
        
        // 3. Fraud Detection
        try FraudDetectionService.inspectCreate(payload: input, request: req)
        
        // 4. Create Model
        let appointment = CMAppointment(
            name: input.name,
            email: input.email,
            phone: input.phone,
            service: input.service,
            message: input.message,
            preferredDate: input.preferredDate,
            preferredTime: input.preferredTime
        )
        
        // 5. Save
        try await baseViewModel.createDocument(appointment, on: req)
        
        // 6. Send Email (Stub)
        EmailService.sendConfirmationStub(to: input.email ?? "")
        
        return await ResponseHandler.success(message: "Appointment request received", data: nil as ResponseHandler.EmptyData?, on: req)
    }
    
    static func getContactInfo(_ req: Request) async throws -> Response {
        let info = [
            "phone": "+91 9876543210",
            "email": "contact@monalishadental.com",
            "address": "123 Dental Street, Health City",
            "emergency": "+91 9123456780"
        ]
        return await ResponseHandler.success(data: info, on: req)
    }
}

// Request DTO
struct SMCreateAppointmentRequest: Content {
    let name: String
    let email: String?
    let phone: String
    let service: String
    let message: String
    let preferredDate: Date
    let preferredTime: String
}
