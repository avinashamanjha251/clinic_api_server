import Vapor

struct ServicesViewModel: ServicesViewModelProtocol {
    
    // Static data representing services.php
    static let allServices: [SMServiceSection] = [
        SMServiceSection(category: "General Dentistry", items: [
            SMServiceItem(id: "gd1", title: "Routine Checkups", description: "Comprehensive oral exams.", features: ["X-rays", "Oral cancer screening"], slug: "routine-checkups"),
            SMServiceItem(id: "gd2", title: "Scaling & Root Planing", description: "Deep cleaning for gum health.", features: ["Removes plaque", "Prevents gum disease"], slug: "scaling")
        ]),
        SMServiceSection(category: "Cosmetic Dentistry", items: [
            SMServiceItem(id: "cd1", title: "Teeth Whitening", description: "Professional whitening.", features: ["Zoom whitening", "Home kits"], slug: "teeth-whitening"),
            SMServiceItem(id: "cd2", title: "Veneers", description: "Porcelain veneers for a perfect smile.", features: ["Natural look", "Long lasting"], slug: "veneers")
        ])
    ]
    
    static func getList(req: Request) async throws -> Response {
        return await ResponseHandler.success(data: allServices, on: req)
    }
    
    static func getDetail(req: Request) async throws -> Response {
        let slug = req.parameters.get("slug") ?? ""
        // Flatten list to find item
        let allItems = allServices.flatMap { $0.items }
        if let item = allItems.first(where: { $0.slug == slug }) {
            return await ResponseHandler.success(data: item, on: req)
        }
        throw Abort(.notFound, reason: "Service not found")
    }
}
