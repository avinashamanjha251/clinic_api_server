import Vapor

protocol ContactViewModelProtocol {
    static func getData(_ req: Request) async throws -> Response
    static func createAppointment(_ req: Request) async throws -> Response
}
