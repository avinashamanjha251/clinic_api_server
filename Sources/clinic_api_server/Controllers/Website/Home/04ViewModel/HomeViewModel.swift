import Vapor

struct HomeViewModel: HomeViewModelProtocol {
    static func getInfo(req: Request) async throws -> Response {
        let info = SMHomeInfoResponse(
            name: "Monalisha Dental Care",
            tagline: "Your Smile, Our Passion",
            address: "123 Dental Street, Health City",
            phone: "+91 9876543210",
            email: "contact@monalishadental.com",
            hours: "Mon-Sat: 9:00 AM - 8:00 PM",
            features: ["Advanced Technology", "Experienced Team", "Pain-free Dentistry"]
        )
        return await ResponseHandler.success(data: info, on: req)
    }
    
    static func getServicesSummary(req: Request) async throws -> Response {
        let summaries = [
            SMServiceSummary(title: "General Dentistry", description: "Comprehensive care including checkups, scaling, and fillings.", slug: "general-dentistry"),
            SMServiceSummary(title: "Cosmetic Dentistry", description: "Smile makeovers, whitening, and veneers.", slug: "cosmetic-dentistry"),
            SMServiceSummary(title: "Restorative Dentistry", description: "Implants, crowns, and bridges.", slug: "restorative-dentistry"),
             SMServiceSummary(title: "Emergency Care", description: "Immediate attention for dental emergencies.", slug: "emergency-care")
        ]
        return await ResponseHandler.success(data: summaries, on: req)
    }
}
