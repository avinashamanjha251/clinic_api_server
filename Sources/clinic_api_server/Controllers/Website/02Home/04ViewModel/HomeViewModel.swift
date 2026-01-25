import Vapor

struct HomeViewModel: HomeViewModelProtocol {
    static func getInfo(req: Request) async throws -> Response {
        let hero = getHeroSection()
        let features = getFeatureSection()
        let services = getServiceSection()
        
        let info = SMHomeInfoResponse(hero: hero,
                                      features: features,
                                      services: services)
        return await ResponseHandler.success(data: info,
                                             on: req)
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
}
