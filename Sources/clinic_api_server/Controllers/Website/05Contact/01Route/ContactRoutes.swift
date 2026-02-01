import Vapor

struct ContactRoutes {
    static func configure(_ route: RoutesBuilder) throws {
        route.get(path: .contact) { try await ContactViewModel.getData($0) }
        route.post(path: .createAppointment) { try await ContactViewModel.createAppointment($0) }
    }
}
