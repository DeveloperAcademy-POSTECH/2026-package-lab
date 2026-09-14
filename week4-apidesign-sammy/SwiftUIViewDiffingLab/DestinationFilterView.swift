import SwiftUI
import ViewEquatableMacros

@Equatable
struct DestinationFilterView: View {
    let destination: String
    
    @SkipEquatable
    let handler: FilterActionHandler

    var body: some View {
        let bodyNumber = BodyEvaluationProbe.record("DestinationFilterView")

        Button {
            handler.send(.destinationTapped)
        } label: {
            FilterCard(
                icon: "mappin.and.ellipse",
                title: "여행지",
                value: destination,
                bodyNumber: bodyNumber
            )
        }
        .buttonStyle(.plain)
    }
}


// 수동 Equatable 적용
/*
extension DestinationFilterView: Equatable {
    static func == (
        lhs: DestinationFilterView,
        rhs: DestinationFilterView
    ) -> Bool {
        lhs.destination == rhs.destination
        // handler는 비교에서 제외
    }
}
*/
