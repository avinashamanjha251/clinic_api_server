import Vapor

struct HomeViewModel: HomeViewModelProtocol {
    static func getData() -> SMHomeInfoResponse {
        let header = getHeader(activeUrl: "./")
        let hero = getHeroSection()
        let features = getFeatureSection()
        let services = getServiceSection()
        let contact = getContactSection()
        let footer = getFooter()
        let data = SMHomeInfoResponse(header: header,
                                  hero: hero,
                                  features: features,
                                  services: services,
                                  contact_info: contact,
                                  footer: footer)
        return data
    }

    static func getInfo(req: Request) async throws -> Response {
        let info = getData()
        return await ResponseHandler.success(data: info, on: req)
    }
    
    private static func getHeroSection() -> SMHomeInfoResponse.SMHero {
        return SMHomeInfoResponse
            .SMHero(
                title: "Welcome to Monalisha Dental Care and OPG Centre",
                description: "Experience exceptional dental care with our team of experienced professionals. We provide comprehensive dental services in a comfortable, modern environment.",
                buttons: [
                    .init(
                        text: "Schedule Consultation",
                        link: "contact",
                        class: "btn btn-primary"
                    ),
                    .init(
                        text: "View Services",
                        link: "services",
                        class: "btn btn-secondary"
                    )
                ],
                image: .init(
                    src: "images/female-dentist-patient.webp",
                    alt: "Beautiful female dentist treating patient",
                    fallback_src: "https://images.unsplash.com/photo-1576091160550-2173dba999ef?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&h=600&q=80"
                )
            )
    }
    
    private static func getFeatureSection() -> SMHomeInfoResponse.SMFeatureSection {
        return SMHomeInfoResponse
            .SMFeatureSection(
                section_title: "Why Choose Monalisha Dental Care and OPG Centre?",
                items: [
                    .init(
                        title: "Experienced Professionals",
                        description: "Our team of qualified dentists has years of experience providing top-quality dental care.",
                        image: "images/experienced-professional.webp",
                        fallback_image: "https://images.unsplash.com/photo-1559839734-2b71ea197ec2?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&h=200&q=80&fm=webp",
                        fallback_icon: "👨⚕️",
                        fallback_class: "professional-fallback"
                    ),
                    .init(
                        title: "Modern Equipment",
                        description: "We use the latest dental technology and equipment to ensure the best treatment outcomes.",
                        image: "images/modern-equipment.webp",
                        fallback_image: "https://images.unsplash.com/photo-1588776814546-1ffcf47267a5?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&h=200&q=80&fm=webp",
                        fallback_icon: "🏥",
                        fallback_class: "equipment-fallback"
                    ),
                    .init(
                        title: "Comfortable Environment",
                        description: "Our clinic provides a relaxing and comfortable atmosphere for all your dental needs.",
                        image: "images/comfortable-environment.webp",
                        fallback_image: "https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&h=200&q=80&fm=webp",
                        fallback_icon: "😊",
                        fallback_class: "comfort-fallback"
                    ),
                    .init(
                        title: "Personalized Care",
                        description: "Each patient receives individualized treatment plans tailored to their specific needs.",
                        image: "images/personalized-care.webp",
                        fallback_image: "https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&h=200&q=80&fm=webp",
                        fallback_icon: "⭐",
                        fallback_class: "care-fallback"
                    )
                ]
            )
    }
    
    private static func getServiceSection() -> SMHomeInfoResponse.SMServiceSection {
        return SMHomeInfoResponse
            .SMServiceSection(
                section_title: "Our Services",
                section_subtitle: "Comprehensive dental care for the whole family",
                items: getServiceList()
            )
    }
    
    private static func getServiceList() -> [SMServiceSummary] {
        return [
            SMServiceSummary(
                title: "General Dentistry",
                description: "Regular checkups, cleanings, and preventive care to maintain optimal oral health.",
                slug: "general-dentistry"
            ),
            SMServiceSummary(
                title: "Cosmetic Dentistry",
                description: "Teeth whitening, veneers, and smile makeovers to enhance your appearance.",
                slug: "cosmetic-dentistry"
            ),
            SMServiceSummary(
                title: "Restorative Dentistry",
                description: "Crowns, bridges, and implants to restore function and aesthetics.",
                slug: "restorative-dentistry"
            ),
            SMServiceSummary(
                title: "Emergency Care",
                description: "Urgent dental care when you need it most, including pain relief and emergency procedures.",
                slug: "emergency-care"
            )
        ]
    }
    
    static func getHeader(activeUrl: String) -> SMHeader {
        return SMHeader(
            brand_name: "Monalisha Dental Care and OPG Centre",
            tagline: "Your Smile, Our Priority",
            nav_links: [
                .init(text: "Home", url: "./", is_active: activeUrl == "./"),
                .init(text: "Services", url: "services", is_active: activeUrl == "services"),
                .init(text: "About", url: "about", is_active: activeUrl == "about"),
                .init(text: "Contact", url: "contact", is_active: activeUrl == "contact")
            ],
            action_button_text: "Book Appointment",
            action_button_link: "contact"
        )
    }

    private static func getContactSection() -> SMHomeInfoResponse.SMContactSection {
        return SMHomeInfoResponse.SMContactSection(
            section_title: "Visit Our Clinic",
            items: [
                .init(title: "📍 Location", content: "Bhagwati Smriti, Ward Number 31\nJune Bandh, Deoghar", subtitle: nil, link: nil, icon: "📍"),
                .init(title: "📞 Phone", content: "+91 7050554772", subtitle: "Tap to call", link: "tel:7050554772", icon: "📞"),
                .init(title: "🕐 Hours", content: "Monday - Sunday: 10:00 AM - 09:00 PM\nEmergency consultations available", subtitle: nil, link: nil, icon: "🕐"),
                .init(title: "✉️ Email", content: "avinashamanjha.portfolio@gmail.com", subtitle: nil, link: nil, icon: "✉️")
            ]
        )
    }

    static func getFooter() -> SMFooter {
        return SMFooter(
            brand_name: "Monalisha Dental Care and OPG Centre",
            brand_description: "Providing exceptional dental care with a personal touch. Your oral health is our commitment.",
            quick_links_title: "Quick Links",
            quick_links: [
                .init(text: "Home", url: "./"),
                .init(text: "Services", url: "services"),
                .init(text: "About", url: "about"),
                .init(text: "Contact", url: "contact")
            ],
            contact_info_title: "Contact Info",
            contact_info: .init(
                phone: "+91 7050554772",
                phone_link: "tel:7050554772",
                email: "avinashamanjha.portfolio@gmail.com",
                email_link: "mailto:avinashamanjha.portfolio@gmail.com",
                address: "Bhagwati Smriti, Ward Number 31, June Bandh, Deoghar",
                hours: "Mon-Sun: 10:00 AM - 09:00 PM"
            ),
            copyright_text: "© 2026 Monalisha Dental Care and OPG Centre. All rights reserved."
        )
    }
}
