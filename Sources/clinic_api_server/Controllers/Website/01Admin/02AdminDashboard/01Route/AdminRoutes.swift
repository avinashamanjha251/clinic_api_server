import Vapor

struct AdminRoutes {
    static func configure(_ r: RoutesBuilder) throws {
        // Protected group
        let admin = r.grouped("admin", "appointments")
                     .grouped(AdminAuthMiddleware()) // Simple check
        
        admin.get("list", use: AdminViewModel.fetchAppointmentsList)
        admin.get("calendar-summary", use: AdminViewModel.fetchCalendarSummary)
        admin.post("status", use: AdminViewModel.updateStatus)
        admin.post("reschedule", use: AdminViewModel.rescheduleAppointment)
        admin.get("date-appointments", use: AdminViewModel.fetchDateAppointments)
    }
}

// Simple Admin Auth Middleware
struct AdminAuthMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        guard let token = request.headers.first(name: "X-Admin-Token"),
              token == (Environment.get(environmentKey: .ENCRYPTION_KEY) ?? "monalisha_admin_token_2026") else {
            throw Abort(.unauthorized, reason: "Unauthorized access")
        }
        return try await next.respond(to: request)
    }
}
