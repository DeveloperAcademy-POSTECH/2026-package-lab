import SwiftUI

struct DateFilterView: View {
    let dateDescription: String
    let handler: FilterActionHandler

    var body: some View {
        let bodyNumber = BodyEvaluationProbe.record("DateFilterView")

        Button {
            handler.send(.dateTapped)
        } label: {
            FilterCard(
                icon: "calendar",
                title: "날짜",
                value: dateDescription,
                bodyNumber: bodyNumber
            )
        }
        .buttonStyle(.plain)
    }
}
