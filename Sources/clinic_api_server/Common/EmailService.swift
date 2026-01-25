import Vapor
import Smtp

struct EmailService {
    static let senderEmail: String? = Environment.get(environmentKey: .SMTP_USERNAME)

    static func sendConfirmationStub(appointment: SMAppointment,
                                     req: Request) {
        // We use a background Task to ensure the request returns immediately
        Task {
            guard let customerEmail = appointment.email else { return }
            
            do {
                let htmlBody = """
                <!DOCTYPE html>
                <html>
                <head>
                    <meta charset="utf-8">
                </head>
                <body style="font-family: Arial, Helvetica, sans-serif; margin: 0; padding: 0; background-color: #ffffff;">
                    <div class="container" style="max-width: 600px; margin: 0 auto; border: 1px solid #e0e0e0;">
                        <div class="header" style="background-color: #2C5AA0; padding: 20px; text-align: center;">
                            <h1 style="color: #ffffff; margin: 0; font-size: 24px;">🦷 Monalisha Dental Care and OPG Centre</h1>
                        </div>
                        <div class="status-container" style="text-align: center; margin-top: -15px;">
                            <div class="status-badge" style="background-color: #27AE60; color: #ffffff; padding: 8px 20px; border-radius: 20px; display: inline-block; font-weight: bold; font-size: 14px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">✅ CONFIRMED</div>
                        </div>
                        <div class="content" style="padding: 30px 20px;">
                            <div class="greeting" style="font-size: 18px; color: #333333; margin-bottom: 20px;">Dear \(appointment.name),</div>
                            <p style="color: #333333;">Your dental appointment has been successfully scheduled. We look forward to seeing you!</p>
                            <div class="details-box" style="background-color: #F8F9FA; border-left: 4px solid #27AE60; padding: 20px; margin-bottom: 25px;">
                                <div class="details-row" style="margin-bottom: 10px;"><span class="details-label" style="font-weight: bold; color: #666666; width: 120px; display: inline-block;">Patient:</span> <span class="details-value" style="color: #333333;">\(appointment.name)</span></div>
                                <div class="details-row" style="margin-bottom: 10px;"><span class="details-label" style="font-weight: bold; color: #666666; width: 120px; display: inline-block;">Service:</span> <span class="details-value" style="color: #333333;">\(appointment.service)</span></div>
                                <div class="details-row" style="margin-bottom: 10px;"><span class="details-label" style="font-weight: bold; color: #666666; width: 120px; display: inline-block;">Date:</span> <span class="details-value" style="color: #333333;">\(appointment.preferredDate)</span></div>
                                <div class="details-row" style="margin-bottom: 10px;"><span class="details-label" style="font-weight: bold; color: #666666; width: 120px; display: inline-block;">Time:</span> <span class="details-value" style="color: #333333;">\(appointment.preferredTime)</span></div>
                                <div class="details-row" style="margin-bottom: 10px;"><span class="details-label" style="font-weight: bold; color: #666666; width: 120px; display: inline-block;">Phone:</span> <span class="details-value" style="color: #333333;">\(appointment.phone)</span></div>
                            </div>
                            <div class="warning-box" style="background-color: #FFF3CD; border: 1px solid #FFEAA7; padding: 15px; border-radius: 4px; color: #856404; font-size: 14px;">
                                <p style="margin: 0 0 10px 0;"><strong>Important Reminders:</strong></p>
                                <div style="margin-left: 10px;">
                                    • Please arrive 15 minutes before your scheduled time for check-in.<br>
                                    • If you need to reschedule, please provide at least 24-hour notice.
                                </div>
                            </div>
                        </div>
                        <div class="footer" style="text-align: center; padding: 20px; color: #999999; font-size: 12px;">
                            &copy; 2026 Monalisha Dental Care and OPG Centre. All rights reserved.
                        </div>
                    </div>
                </body>
                </html>
                """
                guard let senderEmail = Self.senderEmail else {
                    throw Abort(.internalServerError, reason: "Invalid Sender email")
                }
                let email = try Email(from: EmailAddress(address: senderEmail,
                                                         name: "Monalisha Dental Care"),
                                      to: [EmailAddress(address: customerEmail,
                                                        name: appointment.name)],
                                      subject: "Appointment Confirmation - Monalisha Dental Care",
                                      body: htmlBody)
                
                let config = req.application.smtp.configuration
                req.logger.info("Attempting to send email via \(config.hostname):\(config.port)")
                
                try await req.application.smtp.send(email)
            } catch {
                req.logger.error("Background confirmation email failed: \(error)")
            }
        }
    }
}
