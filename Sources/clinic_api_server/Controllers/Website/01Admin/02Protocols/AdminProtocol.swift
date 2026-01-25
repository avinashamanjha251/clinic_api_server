import Vapor

protocol AdminViewModelProtocol {
    static func fetchAppointmentsList(req: Request) async throws -> Response
    static func fetchCalendarSummary(req: Request) async throws -> Response
    static func updateStatus(req: Request) async throws -> Response
    static func rescheduleAppointment(req: Request) async throws -> Response
    static func fetchDateAppointments(req: Request) async throws -> Response
}
