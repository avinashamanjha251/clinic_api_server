import Vapor
import MongoDBVapor

struct ContactViewModel: ContactViewModelProtocol {
    static let baseViewModel = BaseMongoViewModel<SMAppointment>()
    
    static func getData(_ req: Request) async throws -> Response {
        let data = SMContactResponse(
            header: HomeViewModel.getHeader(activeUrl: "contact"),
            page_header: .init(
                title: "Contact Us",
                subtitle: "We'd love to hear from you. Schedule your appointment today!"
            ),
            contact_info: .init(
                section_title: "Get in Touch",
                description: "Have questions or need to schedule an appointment? Reach out to us using any of the methods below.",
                items: [
                    .init(
                        title: "Phone",
                        content: "+91 7050554772",
                        link: "tel:7050554772",
                        icon: "📞",
                        subtitle: "Mon-Sun, 9am - 9pm"
                    ),
                    .init(
                        title: "Email",
                        content: "avinashamanjha.portfolio@gmail.com",
                        link: "mailto:avinashamanjha.portfolio@gmail.com",
                        icon: "✉️",
                        subtitle: "We reply within 24 hours"
                    ),
                    .init(
                        title: "Location",
                        content: "Bhagwati Smriti, Ward Number 31, June Bandh, Deoghar",
                        link: nil,
                        icon: "📍",
                        subtitle: "Free parking available"
                    ),
                    .init(
                        title: "Hours",
                        content: "Mon - Sun: 10:00 AM - 09:00 PM\n24/7 Emergency Care",
                        link: nil,
                        icon: "🕐",
                        subtitle: nil
                    )
                ],
                emergency_card: .init(
                    title: "🚨 Dental Emergency?",
                    description: "If you're experiencing a dental emergency after hours, please call our emergency line:",
                    phone: "+91 7050554772",
                    phone_link: "tel:7050554772",
                    subtitle: "Available 24/7 for dental emergencies - Tap to call"
                )
            ),
            map_section: .init(
                title: "Find Us",
                content: .init(
                    title: "🗺️ Interactive Map",
                    address: "Bhagwati Smriti, Ward Number 31, June Bandh, Deoghar",
                    note: "In a real implementation, this would show an embedded Google Map or similar mapping service.",
                    features: [
                        "🅿️ Free Parking",
                        "🚌 Public Transit Nearby"
                    ]
                )
            ),
            services: [
                .init(value: "general-checkup", label: "General Checkup"),
                .init(value: "cleaning", label: "Dental Cleaning"),
                .init(value: "fillings", label: "Fillings"),
                .init(value: "crowns", label: "Crowns"),
                .init(value: "whitening", label: "Teeth Whitening"),
                .init(value: "implants", label: "Dental Implants"),
                .init(value: "emergency", label: "Emergency Care"),
                .init(value: "consultation", label: "Consultation"),
                .init(value: "other", label: "Other")
            ],
            time_slots: [
                "8:00 AM", "9:00 AM", "10:00 AM", "11:00 AM",
                "12:00 PM", "1:00 PM", "2:00 PM",
                "3:00 PM", "4:00 PM", "5:00 PM"
            ],
            footer: HomeViewModel.getFooter()
        )
        return await ResponseHandler.success(data: data, on: req)
    }
    
    static func createAppointment(_ req: Request) async throws -> Response {
        // 1. Validate
        try AppointmentValidator.validate(req)
        
        // 2. Decode
        let input = try req.decodeContent(SMCreateAppointmentRequest.self)
        
        // 3. Fraud Detection
        try FraudDetectionService.inspectCreate(payload: input, request: req)
        
        // 4. Create Model
        let appointment = SMAppointment(
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
        
        return await ResponseHandler.success(message: "Appointment request received",
                                             data: nil as ResponseHandler.EmptyData?,
                                             on: req)
    }
}

// Request DTO
struct SMCreateAppointmentRequest: Content {
    let name: String
    let email: String?
    let phone: String
    let service: String
    let message: String
    let preferredDate: String
    let preferredTime: String
}
