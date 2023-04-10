import SwiftUI

struct OpeningHoursCell: View {
    let openingHours: OpeningHours
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("openingHours", bundle: .module)
                .font(.callout)
                .opacity(0.75)
            ForEach(openingHours.sortedDisplayableWeekPortions, id: \.hashValue) { portion in
                if let firstWeekday = portion.weekdays.first {
                    HStack(alignment: .top) {
                        if portion.weekdays.count > 1 {
                            let lastWeekday = portion.weekdays.last!
                            Text("\(firstWeekday.shortLocalizedName) - \(lastWeekday.shortLocalizedName)")
                        } else {
                            Text(firstWeekday.localizedName)
                        }
                        Spacer()
                        VStack {
                            ForEach(portion.ranges, id: \.hashValue) { range in
                                Text("\(range.from.displayString) - \(range.to.displayString)")
                            }
                        }
                    }
                }
            }
        }
        .listCellEmulationPadding()
    }
}
