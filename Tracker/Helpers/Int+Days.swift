import Foundation

extension Int {
    var localizedDays: String {
        String(
            localized: "\(self) день",
            comment: "Количество дней выполнения трекера"
        )
    }
}
