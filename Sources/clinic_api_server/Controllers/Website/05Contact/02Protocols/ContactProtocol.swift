import Vapor

protocol ContactViewModelProtocol {
    static func createAppointment(_ req: Request) async throws -> Response
}
