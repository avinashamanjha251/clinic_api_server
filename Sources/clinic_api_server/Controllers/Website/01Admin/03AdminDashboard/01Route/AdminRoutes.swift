import Vapor

struct AdminRoutes {
    static func configure(_ r: RoutesBuilder) throws {
        // Protected group (appointments)
        let protected = r.grouped(AccessTokenMiddleware())
        
        protected.get(path: .adminAppointmentsList) { try await AdminViewModel.fetchAppointmentsList(req: $0) }
        protected.get(path: .adminAppointmentsCalendarSummary) { try await AdminViewModel.fetchCalendarSummary(req: $0) }
        protected.post(path: .adminAppointmentsStatus) { try await AdminViewModel.updateStatus(req: $0) }
        protected.post(path: .adminAppointmentsReschedule) { try await AdminViewModel.rescheduleAppointment(req: $0) }
        protected.get(path: .adminAppointmentsDate) { try await AdminViewModel.fetchDateAppointments(req: $0) }
    }
}

