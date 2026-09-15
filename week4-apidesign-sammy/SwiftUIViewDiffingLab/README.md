# 예상하지 못한 SwiftUI View 계산 실험

숙소 검색 필터를 단순화한 화면입니다. `FilterScreen`이 전체 필터 상태를 소유하고, 자식 View는 상태를 표시한 뒤 사용자의 action을 공통 handler로 상위 화면에 전달합니다.

## 실행

1. `ContentView.swift`의 Preview를 실행합니다.
2. 인원 카드의 `+` 또는 `-` 버튼을 누릅니다.
3. 지역, 날짜, 인원 카드의 배경색과 오른쪽 `body #숫자`를 비교합니다.
4. Xcode 콘솔의 `[body 계산]` 로그도 확인합니다.

인원 action이 전달되면 `FilterScreen`이 `FilterState.guestCount`를 변경합니다. 새로운 상태가 다시 자식 View로 전달되지만 여행지와 날짜 값은 그대로이므로, 두 View는 다시 계산되지 않기를 기대할 수 있습니다. 하지만 모든 자식 View가 closure를 감싼 `FilterActionHandler`를 프로퍼티로 가지고 있어 SwiftUI의 View 비교에 영향을 줄 수 있습니다.

```text
FilterState ──아래로──▶ 자식 View
FilterScreen ◀──action── FilterActionHandler ◀──사용자 입력
```

## 파일 구성

- `FilterFeature.swift`: 화면 상태, action과 closure 기반 handler
- `FilterScreen.swift`: 전체 필터 상태를 소유하고 action을 처리하는 상위 화면
- `DestinationFilterView.swift`: 지역 상태를 표시하고 action을 전달하는 필터
- `DateFilterView.swift`: 날짜 상태를 표시하고 action을 전달하는 필터
- `GuestFilterView.swift`: 인원을 표시하고 증감 action을 전달하는 필터
- `FilterCard.swift`: 공통 카드 UI와 관찰용 번호

## 주의

- 무작위 번호, 배경색과 콘솔 출력은 학습을 위한 관찰 장치이며 성능 측정 도구가 아닙니다.
- SwiftUI의 기본 비교 세부 알고리즘은 공식 API 계약으로 공개되어 있지 않습니다.
