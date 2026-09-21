import UIKit

struct Tracker {
    let id: UUID
    let name: String
    let icon: String
    let color: UIColor
    let schedule: [Schedule]
    
    init(
        id: UUID = UUID(),
        name: String,
        icon: String,
        color: UIColor,
        schedule: [Schedule] = []
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.color = color
        self.schedule = schedule
    }
}
