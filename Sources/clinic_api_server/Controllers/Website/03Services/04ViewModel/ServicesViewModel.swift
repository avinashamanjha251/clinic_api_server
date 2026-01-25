import Vapor

struct ServicesViewModel: ServicesViewModelProtocol {
    
    static func getList(req: Request) async throws -> Response {
        let data = getData()
        return await ResponseHandler.success(data: data, on: req)
    }

    private static func getData() -> SMServicesResponse {
        return SMServicesResponse(
            header: HomeViewModel.getHeader(activeUrl: "services"),
            page_header: .init(
                title: "Our Services",
                subtitle: "Comprehensive dental care tailored to your needs"
            ),
            services_categories: [
                .init(
                    title: "General Dentistry",
                    items: [
                        .init(
                            title: "🦷 Routine Cleanings",
                            description: "Professional dental cleanings to remove plaque and tartar, keeping your teeth and gums healthy.",
                            features: [
                                "Deep cleaning procedures",
                                "Plaque and tartar removal",
                                "Fluoride treatments"
                            ]
                        ),
                        .init(
                            title: "🔍 Comprehensive Exams",
                            description: "Thorough dental examinations including X-rays and oral health assessments.",
                            features: [
                                "Digital X-rays",
                                "Oral cancer screening",
                                "Gum disease evaluation"
                            ]
                        ),
                        .init(
                            title: "🩹 Fillings",
                            description: "Modern composite fillings to restore damaged teeth and prevent further decay.",
                            features: [
                                "Tooth-colored fillings",
                                "Mercury-free options",
                                "Long-lasting materials"
                            ]
                        ),
                        .init(
                            title: "🦷 Root Canal Therapy",
                            description: "Advanced endodontic treatment to save infected teeth and relieve pain.",
                            features: [
                                "Pain-free procedures",
                                "Modern techniques",
                                "Tooth preservation"
                            ]
                        )
                    ]
                ),
                .init(
                    title: "Cosmetic Dentistry",
                    items: [
                        .init(
                            title: "✨ Teeth Whitening",
                            description: "Professional whitening treatments for a brighter, more confident smile.",
                            features: [
                                "In-office whitening",
                                "Take-home kits",
                                "Safe and effective"
                            ]
                        ),
                        .init(
                            title: "🦷 Veneers",
                            description: "Custom porcelain veneers to transform your smile and correct imperfections.",
                            features: [
                                "Natural-looking results",
                                "Stain-resistant",
                                "Minimal tooth preparation"
                            ]
                        ),
                        .init(
                            title: "😊 Smile Makeovers",
                            description: "Comprehensive smile transformation combining multiple cosmetic procedures.",
                            features: [
                                "Personalized treatment plans",
                                "Digital smile preview",
                                "Complete smile transformation"
                            ]
                        ),
                        .init(
                            title: "🦷 Bonding",
                            description: "Tooth-colored composite bonding to repair chips, gaps, and discoloration.",
                            features: [
                                "Same-day results",
                                "Conservative treatment",
                                "Natural appearance"
                            ]
                        )
                    ]
                ),
                .init(
                    title: "Restorative Dentistry",
                    items: [
                        .init(
                            title: "👑 Crowns",
                            description: "Custom dental crowns to restore strength and appearance of damaged teeth.",
                            features: [
                                "Porcelain and ceramic options",
                                "Same-day crowns available",
                                "Natural color matching"
                            ]
                        ),
                        .init(
                            title: "🌉 Bridges",
                            description: "Fixed bridges to replace missing teeth and restore your smile.",
                            features: [
                                "Permanent tooth replacement",
                                "Restore chewing function",
                                "Prevent teeth shifting"
                            ]
                        ),
                        .init(
                            title: "🔧 Dental Implants",
                            description: "State-of-the-art implants for permanent tooth replacement solutions.",
                            features: [
                                "Titanium implants",
                                "Bone grafting available",
                                "Lifetime solution"
                            ]
                        ),
                        .init(
                            title: "🦷 Dentures",
                            description: "Full and partial dentures for complete smile restoration.",
                            features: [
                                "Custom-fitted dentures",
                                "Implant-supported options",
                                "Comfortable and natural-looking"
                            ]
                        )
                    ]
                ),
                .init(
                    title: "Specialized Services",
                    items: [
                        .init(
                            title: " OPG (Orthopantomogram)",
                            description: "Advanced panoramic X-ray imaging for comprehensive dental and jaw evaluation.",
                            features: [
                                "Full mouth and jaw X-ray",
                                "Digital imaging technology",
                                "Detailed bone structure analysis",
                                "Pre-treatment planning",
                                "Wisdom tooth evaluation"
                            ]
                        ),
                        .init(
                            title: "🚨 Emergency Care",
                            description: "Urgent dental care for dental emergencies and severe pain relief.",
                            features: [
                                "Same-day appointments",
                                "Pain management",
                                "24/7 emergency line"
                            ]
                        ),
                        .init(
                            title: "😴 Sedation Dentistry",
                            description: "Comfortable dental care with various sedation options for anxious patients.",
                            features: [
                                "Nitrous oxide",
                                "Oral sedation",
                                "IV sedation available"
                            ]
                        ),
                        .init(
                            title: "👶 Pediatric Care",
                            description: "Specialized dental care for children in a fun and comfortable environment.",
                            features: [
                                "Child-friendly approach",
                                "Preventive treatments",
                                "Early orthodontic screening"
                            ]
                        ),
                        .init(
                            title: "🦷 Oral Surgery",
                            description: "Minor oral surgery procedures including extractions and tissue grafts.",
                            features: [
                                "Wisdom tooth extraction",
                                "Bone grafting",
                                "Tissue regeneration"
                            ]
                        )
                    ]
                )
            ],
            cta_section: .init(
                title: "Ready to Schedule Your Appointment?",
                description: "Contact us today to discuss your dental needs and create a personalized treatment plan.",
                button_text: "Book Consultation",
                button_link: "contact"
            ),
            footer: HomeViewModel.getFooter()
        )
    }
}
