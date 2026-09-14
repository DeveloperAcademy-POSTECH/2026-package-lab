import SwiftUI

struct GuestFilterView: View {
    let guestCount: Int
    let handler: FilterActionHandler

    var body: some View {
        let bodyNumber = BodyEvaluationProbe.record("GuestFilterView")

        HStack(spacing: 12) {
            Image(systemName: "person.2")
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text("인원")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("게스트 \(guestCount)명")
                    .font(.body.weight(.semibold))
            }

            Spacer()

            Button {
                handler.send(.decrementGuest)
            } label: {
                Image(systemName: "minus.circle.fill")
            }
            .disabled(guestCount == 1)

            Text("\(guestCount)")
                .font(.body.monospacedDigit().bold())
                .frame(minWidth: 24)

            Button {
                handler.send(.incrementGuest)
            } label: {
                Image(systemName: "plus.circle.fill")
            }

            BodyNumberBadge(number: bodyNumber)
        }
        .font(.title2)
        .padding(16)
        .bodyEvaluationBackground(number: bodyNumber)
    }
}
