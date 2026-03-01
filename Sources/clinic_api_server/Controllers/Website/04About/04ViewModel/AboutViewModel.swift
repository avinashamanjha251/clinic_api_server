import Vapor

struct AboutViewModel: AboutViewModelProtocol {
    
    static func getData(req: Request) async throws -> Response {
        let data = getStaticData()
        return await ResponseHandler.success(data: data, on: req)
    }
    
    private static func getStaticData() -> SMAboutResponse {
        return SMAboutResponse(
            header: HomeViewModel.getHeader(activeUrl: "about"),
            page_header: .init(
                title: "About Monalisha Dental Care and OPG Centre",
                subtitle: "Dedicated to providing exceptional dental care with a personal touch"
            ),
            mission: .init(
                title: "Our Mission",
                content: [
                    "At Monalisha Dental Care and OPG Centre, our mission is to provide comprehensive, high-quality dental care in a comfortable and welcoming environment. We are committed to helping our patients achieve and maintain optimal oral health through personalized treatment plans, advanced technology, and compassionate care.",
                    "We believe that a healthy smile contributes to overall well-being and confidence. Our goal is to make dental care accessible, comfortable, and stress-free for patients of all ages."
                ]
            ),
            story: .init(
                title: "Our Story",
                content: [
                    "Founded with a vision to transform dental care in our community, Monalisha Dental Care has been serving families for over a decade. What started as a small practice has grown into a comprehensive dental care center, but we've never lost sight of our core values: personalized care, advanced treatment options, and genuine concern for our patients' well-being.",
                    "Our practice combines traditional dental expertise with modern technology to provide the best possible outcomes for our patients. We continuously invest in the latest equipment and training to ensure we're at the forefront of dental care innovation."
                ]
            ),
            values: .init(
                title: "Our Values",
                items: [
                    .init(
                        icon: "💝",
                        title: "Compassionate Care",
                        description: "We treat each patient with empathy, understanding, and respect, ensuring comfort throughout every visit."
                    ),
                    .init(
                        icon: "🎯",
                        title: "Excellence",
                        description: "We maintain the highest standards of dental care through continuous education and advanced techniques."
                    ),
                    .init(
                        icon: "🤝",
                        title: "Trust & Integrity",
                        description: "We build lasting relationships with our patients based on honesty, transparency, and reliable care."
                    ),
                    .init(
                        icon: "🚀",
                        title: "Innovation",
                        description: "We embrace new technologies and methods that improve patient outcomes and comfort."
                    )
                ]
            ),
            team: .init(
                title: "Meet Our Team",
                members: [
                    .init(
                        photo_placeholder: "https://images.rawpixel.com/image_800/cHJpdmF0ZS9sci9pbWFnZXMvd2Vic2l0ZS8yMDIzLTA4L3Jhd3BpeGVsb2ZmaWNlMV9waG90b2dyYXBoeV9vZl9hbl9zb3V0aF9pbmRpYW5fd29tZW5fYXNfYV9kb2N0b19kMzAxMDM3Zi03MDUzLTQxNDAtYmYyZS1lZDFlYWE0YTM3NDRfMS5qcGc.jpg",
                        name: "Dr. Poonam Pratibha",
                        role: "BDS, MIDA and founder",
                        bio: "Experienced in general and cosmetic dentistry. Graduated from CCS University, done 1 year rotatory internship from Patna Dental College And Hospital, and completed advance training in smile design and aligners.",
                        credentials: [
                            "BDS, CCS University",
                            "MIDA",
                            "Advance training in smile design and aligners"
                        ]
                    ),
//                    .init(
//                        photo_placeholder: "👨⚕️",
//                        name: "Dr. Michael Chen",
//                        role: "Associate Dentist",
//                        bio: "Dr. Chen specializes in restorative and pediatric dentistry. His gentle approach and expertise with children make him a favorite among our younger patients and their families.",
//                        credentials: [
//                            "DDS, State University School of Dentistry",
//                            "Pediatric Dentistry Fellowship",
//                            "Sedation Dentistry Certified"
//                        ]
//                    ),
//                    .init(
//                        photo_placeholder: "👩⚕️",
//                        name: "Lisa Martinez, RDH",
//                        role: "Lead Dental Hygienist",
//                        bio: "Lisa has been with our practice for 8 years and is passionate about preventive care and patient education. She helps patients develop effective oral hygiene routines for long-term dental health.",
//                        credentials: [
//                            "RDH, Community College Dental Program",
//                            "Local Anesthesia Administration",
//                            "Continuing Education in Periodontal Therapy"
//                        ]
//                    ),
//                    .init(
//                        photo_placeholder: "👩💼",
//                        name: "Emma Thompson",
//                        role: "Practice Manager",
//                        bio: "Emma ensures smooth operations and exceptional patient experiences. She coordinates appointments, manages insurance claims, and helps patients navigate their treatment options.",
//                        credentials: [
//                            "Healthcare Administration Degree",
//                            "Dental Practice Management Certified",
//                            "5+ Years in Dental Administration"
//                        ]
//                    )
                ]
            ),
            facility: .init(
                title: "State-of-the-Art Facility",
                description: "Our modern dental facility is designed with patient comfort and safety in mind. We've invested in the latest dental technology to provide accurate diagnoses, efficient treatments, and superior results.",
                technology_title: "Advanced Technology",
                technology_list: [
                    "Digital X-ray systems with reduced radiation exposure",
                    "Intraoral cameras for detailed examination and patient education",
                    "CEREC same-day crown technology",
                    "Laser dentistry for minimally invasive procedures",
                    "3D imaging for implant planning",
                    "Nitrous oxide for patient comfort"
                ],
                comfort_title: "Comfort Features",
                comfort_list: [
                    "Relaxing treatment rooms with entertainment systems",
                    "Comfortable seating in our spacious waiting area",
                    "Complimentary beverages and WiFi",
                    "Sedation options for anxious patients",
                    "Private consultation rooms"
                ]
            ),
            community: .init(
                title: "Community Involvement",
                description: "We believe in giving back to our community. Monalisha Dental Care actively participates in local health fairs, school dental education programs, and provides pro-bono services to those in need. We're proud to be a trusted partner in promoting oral health awareness throughout our community.",
                activities: [
                    .init(
                        title: "🏫 School Visits",
                        description: "Educational presentations about oral hygiene and dental health for local elementary schools."
                    ),
                    .init(
                        title: "🎪 Health Fairs",
                        description: "Free dental screenings and consultations at community health events."
                    ),
                    .init(
                        title: "💝 Charity Care",
                        description: "Providing essential dental services to underserved members of our community."
                    )
                ]
            ),
            cta: .init(
                title: "Ready to Experience the Difference?",
                description: "Join our dental family and discover why patients choose Monalisha Dental Care for their oral health needs.",
                button_text: "Schedule Your Visit",
                button_link: "contact"
            ),
            footer: HomeViewModel.getFooter()
        )
    }
}
