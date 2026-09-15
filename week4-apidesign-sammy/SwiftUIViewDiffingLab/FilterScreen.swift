import SwiftUI

struct FilterScreen: View {
    @State private var filterState = FilterState()

    var body: some View {
        let handler = FilterActionHandler { action in
            handle(action)
        }

        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    DestinationFilterView(
                        destination: filterState.destination,
                        handler: handler
                    )
                    .equatable() // 수동 Equatable 적용

                    DateFilterView(
                        dateDescription: filterState.dateDescription,
                        handler: handler
                    )

                    GuestFilterView(
                        guestCount: filterState.guestCount,
                        handler: handler
                    )
                }
                .padding(20)
            }
            .navigationTitle("숙소 필터")
        }
    }

    private func handle(_ action: FilterAction) {
        switch action {
        case .destinationTapped:
            print("[Action] 여행지 선택")

        case .dateTapped:
            print("[Action] 날짜 선택")

        case .decrementGuest:
            if filterState.guestCount > 1 {
                filterState.guestCount -= 1
            }

        case .incrementGuest:
            filterState.guestCount += 1
        }
    }
}
