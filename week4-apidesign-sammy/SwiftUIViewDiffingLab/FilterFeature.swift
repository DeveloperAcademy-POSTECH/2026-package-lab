import Foundation

struct FilterState {
    var destination = "제주도"
    var dateDescription = "9월 20일 - 9월 22일"
    var guestCount = 2
}

enum FilterAction {
    case destinationTapped
    case dateTapped
    case decrementGuest
    case incrementGuest
}

struct FilterActionHandler {
    let send: (FilterAction) -> Void
}
