# Macro를 활용한 API Design: Airbnb의 `@Equatable` 사례

> 발표 초안  
> 메인 키워드: **API Design**

## 1. 주제 탐색의 출발점

처음에는 여러 회사가 기존 UIKit 중심의 아키텍처에서 SwiftUI를 도입하거나, 두 프레임워크를 함께 사용하는 이유가 궁금했다.

이 질문을 조사하던 중 Airbnb의 [Understanding and Improving SwiftUI Performance](https://airbnb.tech/web/understanding-and-improving-swiftui-performance/)를 발견했다.

Airbnb는 2022년부터 SwiftUI를 개별 컴포넌트에 도입했고, 이후 전체 화면과 기능으로 적용 범위를 확대했다. 이 과정에서 선언적이고 조합 가능한 구조가 개발 생산성을 높였지만, 예상하지 못한 성능 문제도 함께 드러났다고 설명한다.

## 2. API Design을 키워드로 선택한 이유

Airbnb는 SwiftUI를 실제 서비스의 여러 화면으로 확대하는 과정에서, 화면의 내용이 달라지지 않았는데도 일부 View의 `body`가 불필요하게 다시 계산되는 문제를 발견했다. 작은 규모에서는 잘 드러나지 않던 비효율이 복잡한 화면과 많은 컴포넌트에서 누적되며 성능에 영향을 주고 있었다.

문제의 원인을 파악하기 위해 SwiftUI가 이전 View와 새로운 View를 어떻게 비교하는지 탐구했다. 그 결과 저장 프로퍼티 중 하나라도 안정적으로 비교하기 어려우면, SwiftUI가 해당 View 전체를 이전과 같다고 판단하지 못해 부모 View가 업데이트될 때 `body` 전체가 불필요하게 다시 계산될 수 있음을 발견했다. 특히 단방향 데이터 흐름에서 action을 전달하기 위해 View의 프로퍼티로 저장한 closure 기반 handler가 주요 원인 중 하나였다.

Airbnb가 해결하고자 한 핵심은 기존의 closure 기반 handler 구조를 유지하면서도, 화면 내용이 바뀌지 않은 View의 `body`가 다시 계산되지 않도록 하는 것이었다. 이를 위해 View에 `Equatable`을 채택하면 SwiftUI가 기본 방식 대신 개발자가 구현한 `==` 연산자로 두 View를 비교한다는 점을 활용했다. `==`에서는 화면 출력에 영향을 주는 프로퍼티만 비교하고, 출력과 관계없는 handler는 제외했다. 이로써 closure 기반 구조를 바꾸지 않고도 View의 동등성을 판단할 기준을 직접 정할 수 있었다.

이 방식은 개별 View의 불필요한 계산을 줄일 수 있지만, 많은 View에 적용하면 유사한 `==` 구현을 반복해서 작성해야 한다. 또한 새로운 프로퍼티를 추가할 때 비교식에 포함하는 것을 잊을 수 있고, 여러 개발자가 같은 규칙을 일관되게 유지하기 어렵다는 한계가 있다.

Airbnb는 이러한 반복과 누락을 줄이기 위해 동등성 비교 코드를 macro로 생성하도록 했다. View의 프로퍼티가 비교 규칙을 만족하는지 컴파일 시점에 확인하고, 필요한 `Equatable` 구현이 생성되도록 사용 인터페이스를 설계했다. 컴파일러가 실제 실행 성능을 측정하는 것은 아니지만, 불필요한 계산으로 이어질 수 있는 코드 구조를 개발 과정에서 발견하도록 만든 것이다.

이 사례는 View의 비교에 포함할 프로퍼티와 제외할 프로퍼티를 개발자가 코드로 표현하고, 잘못된 구성을 컴파일 과정에서 확인할 수 있는 인터페이스를 설계했다는 점에서 API Design과 연결된다. 복잡한 비교 코드의 생성은 macro가 담당하고, 개발자는 제공된 사용 방법과 규칙에 따라 View의 비교 의도를 명시할 수 있다.

이러한 이유로 메인 키워드를 **API Design**으로 선택했다.

## 3. Guiding Question

> **Airbnb는 SwiftUI View가 불필요하게 다시 계산되는 문제를 어떻게 발견했고, 어떻게 해결했을까?**

## 4. 연구 내용

### 4.1 예상보다 자주 계산되는 View

Airbnb는 일부 View의 `body`가 실제 화면 내용의 변화보다 더 자주 계산되는 현상을 발견했다.

Airbnb는 SwiftUI를 도입하면서도 기존의 단방향 데이터 흐름 라이브러리를 계속 사용했다. 이 구조에서 화면은 상태를 자식 View에 내려주고, 자식 View에서 발생한 사용자 입력은 action handler를 통해 화면으로 올라간다. 이때 handler는 action을 화면의 action handler로 전달하는 closure를 감싸고 있었다.

이번 실습에서는 글에서 설명한 흐름을 바탕으로 비슷한 상황을 재현했다. 작은 SwiftUI 필터 화면을 구현하고, 각 View의 `body`가 계산될 때마다 카드의 배경색이 달라지는 modifier를 적용해 불필요한 계산이 발생하는지 직접 확인해보았다.

`FilterScreen`이 여행지, 날짜, 인원 상태를 모두 소유하고 각 자식 View에는 표시할 값과 공통 handler를 전달한다.

```swift
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

struct FilterScreen: View {
    @State private var filterState = FilterState()

    var body: some View {
        let handler = FilterActionHandler { action in
            handle(action)
        }

        VStack {
            DestinationFilterView(
                destination: filterState.destination,
                handler: handler
            )

            DateFilterView(
                dateDescription: filterState.dateDescription,
                handler: handler
            )

            GuestFilterView(
                guestCount: filterState.guestCount,
                handler: handler
            )
        }
    }

    private func handle(_ action: FilterAction) {
        switch action {
        case .incrementGuest:
            filterState.guestCount += 1
        default:
            break // 나머지 action 처리 생략
        }
    }
}
```

인원 증가 버튼을 누르면 `GuestFilterView`가 `.incrementGuest`를 handler에 전달하고, `FilterScreen`이 `filterState.guestCount`를 변경한다.

```text
FilterState ──아래로──▶ 자식 View
FilterScreen ◀──action── FilterActionHandler ◀──사용자 입력
```

인원은 달라지지만 여행지와 날짜 값은 그대로이므로, 여행지와 날짜 View의 `body`는 다시 계산되지 않기를 기대할 수 있다. 하지만 모든 자식 View는 closure를 감싼 `FilterActionHandler`를 저장 프로퍼티로 가진다. 이처럼 화면 출력과 직접 관련 없는 handler가 View의 비교를 어렵게 만들어 불필요한 `body` 계산으로 이어질 수 있다는 것이 이번 실험의 핵심이다.

각 하위 View의 `body` 안에서는 무작위 번호를 생성하고 콘솔에 기록한다. 그 번호를 바탕으로 카드 배경색도 결정한다.

```swift
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
}
```

공통 `FilterCard`는 전달받은 번호를 표시하고 `.bodyEvaluationBackground(number:)` modifier로 번호에 대응하는 배경색을 적용한다. 이 장치로 `body`가 다시 계산되면 카드의 번호와 배경색이 함께 바뀌고, 콘솔에도 새로운 로그가 남는다.

Simulator에서 인원만 변경하며 다음 현상을 관찰한다.

- 변경한 값: 인원 수
- 그대로인 화면 표시 값: 여행지와 날짜
- 확인할 내용: 인원뿐 아니라 여행지와 날짜 카드의 body 번호와 배경색도 변경되는가?

여행지와 날짜의 표시 내용은 변하지 않았는데 두 View의 번호와 배경색이 바뀐다면, 상태 자체가 아니라 closure 기반 handler가 View 비교에 참여하면서 계산 범위를 넓힌 것으로 해석할 수 있다. 이 실험은 [SwiftUIViewDiffingLab](./SwiftUIViewDiffingLab.xcodeproj)에서 확인할 수 있다.

### 4.2 Airbnb가 설명한 SwiftUI View diffing

게시글에서 Airbnb는 부모 View가 업데이트될 때 SwiftUI가 자식 View의 저장 프로퍼티를 비교하여 `body`를 다시 계산할지 판단한다고 설명한다.

게시글에서 제시한 관찰 모델은 다음과 같다.

1. 타입이 `Equatable`이면 해당 동등성 비교를 사용한다.
2. 일반적인 값 타입은 저장 프로퍼티를 재귀적으로 비교한다.
3. 참조 타입은 reference identity를 비교한다.
4. closure는 identity 비교를 시도하지만 안정적으로 비교하기 어렵다.

이 세부 알고리즘은 Apple이 공식 API 계약으로 문서화한 내용이 아니다. 게시글 역시 공식적으로 문서화되지 않은 동작이라고 명시한다. 따라서 이는 SwiftUI의 영구적으로 보장된 구현 규칙이 아니라, 성능 문제를 분석하기 위해 사용한 관찰 모델로 다룬다.

Apple이 공식적으로 설명하는 범위에서는 View의 데이터 dependency, View identity, 빠른 `body` 계산과 불필요한 업데이트 방지가 SwiftUI 성능에 중요하다. 자세한 내용은 [Understanding and improving SwiftUI performance](https://developer.apple.com/documentation/xcode/understanding-and-improving-swiftui-performance)와 [Demystify SwiftUI performance](https://developer.apple.com/videos/play/wwdc2023/10160/)에서 확인할 수 있다.

### 4.3 프로퍼티로 저장된 closure

앞의 실험에 사용한 여행지 View를 단순화하면 다음과 같다.

```swift
struct DestinationFilterView: View {
    let destination: String
    let handler: FilterActionHandler

    var body: some View {
        Button(destination) {
            handler.send(.destinationTapped)
        }
    }
}
```

`String`인 `destination`은 이전 값과 새로운 값이 같은지 비교할 수 있다. 반면 `FilterActionHandler`가 감싼 closure는 같은 동작을 하는지 안정적으로 비교하기 어렵다.

```text
destination: 이전과 같음
handler 내부 closure: 같은지 판단하기 어려움
             ↓
View 전체가 같은지 판단하기 어려움
             ↓
불필요한 body 계산 가능성
```

Airbnb의 코드베이스에는 closure를 포함하는 View가 많았기 때문에, closure 사용 방식을 전면 변경하는 것은 크고 침습적인 아키텍처 변경이 될 수 있었다. 따라서 개발팀에게 필요했던 것은 모든 closure를 제거하는 일이 아니라, **화면 출력에 영향을 주는 프로퍼티와 비교에서 제외할 프로퍼티를 선별하는 방법**이었다.

### 4.4 프로퍼티를 선별적으로 비교하기: 수동 `Equatable` 실습

closure 기반 handler 구조를 유지하면서 비교 기준만 바꾸면 결과가 달라지는지 확인하기 위해, 세 자식 View 중 `DestinationFilterView`에만 수동으로 `Equatable`을 적용했다. extension에서 프로토콜을 채택하고 `==` 연산자를 구현하여, 화면에 표시되는 `destination`만 비교하고 handler는 제외했다.

```swift
extension DestinationFilterView: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.destination == rhs.destination
        // handler는 비교에서 제외
    }
}
```

호출부에는 SwiftUI가 이 동등성 비교 결과를 사용해 하위 View의 업데이트 여부를 판단하도록 `.equatable()`을 적용했다.

```swift
DestinationFilterView(
    destination: filterState.destination,
    handler: handler
)
.equatable()
```

인원수를 변경하면 `FilterScreen.body`는 다시 계산된다. 여행지 문자열은 이전과 같으므로, SwiftUI가 수동으로 정의한 `==`를 사용해 비교하면 `true`가 반환되고 `DestinationFilterView`의 하위 업데이트를 생략할 수 있다.

```text
인원 변경
   ↓
FilterScreen.body 계산
   ├─ DestinationFilterView: destination 동일 → == true → 하위 업데이트 생략
   ├─ DateFilterView: closure 기반 handler 비교가 어려움 → 색상 변경
   └─ GuestFilterView: guestCount 변경                 → 색상 변경
```

이 결과를 통해 closure가 있는 구조 자체를 제거하지 않고도, 개발자가 View의 동등성 판단 기준을 정해 불필요한 자식 `body` 계산을 줄일 수 있음을 확인했다. 여기서 조정한 것은 SwiftUI의 diffing 과정 전체나 `body` 호출 시점이 아니라, SwiftUI가 비교를 수행할 때 View를 이전과 같은 값으로 볼 것인지 판단하는 기준이다.

다만 closure가 언제나 비교에서 제외해도 되는 것은 아니다. handler의 변화가 View의 표시나 동작에 영향을 준다면 같은 View로 판단하는 것이 잘못된 결과를 만들 수 있으므로, 어떤 프로퍼티를 제외할지는 해당 View의 역할을 기준으로 개발자가 판단해야 한다.

### 4.5 수동 `Equatable` 구현의 한계

이번 실습처럼 하나의 View에 적용할 때는 수동 `Equatable`만으로도 비교 기준을 명확하게 지정할 수 있다. 문제는 이 방법을 실제 코드베이스의 많은 View로 확대할 때 생긴다.

- View마다 반복적인 `==` 구현이 필요하다.
- 프로퍼티가 추가되었을 때 비교식에도 추가하는 것을 잊을 수 있다.
- 비교에서 빠진 값이 의도적으로 제외된 것인지 실수로 누락된 것인지 알기 어렵다.
- 많은 개발자가 동일한 규칙을 일관되게 유지하기 어렵다.

수동 구현은 비교를 조정할 수 있다는 가능성을 보여 주지만, 작성자가 모든 프로퍼티를 빠짐없이 분류하고 그 규칙을 계속 유지해야 한다.

### 4.6 Swift Package로 `@Equatable` macro API 만들기

수동 `Equatable` 구현은 View가 많아질수록 `==` 작성을 반복해야 하고, 프로퍼티를 추가할 때 비교식에 반영하지 않는 실수가 생길 수 있다. Airbnb는 이러한 한계를 줄이기 위해 `@Equatable` macro로 동등성 비교 코드를 생성하도록 했다.

이번 실습에서는 같은 흐름을 재현하기 위해 `ViewEquatableMacros`라는 로컬 Swift Package를 만들었다. Swift macro package에서는 앱이 사용할 공개 macro 선언과 실제 코드 생성 구현을 서로 다른 target과 module로 나눈다.

#### 공개 API와 구현 target

```text
ViewEquatableMacros
├── ViewEquatableMacros target
│   └── 앱이 import하는 public macro API 선언
├── ViewEquatableMacrosMacros macro target
│   └── SwiftSyntax를 이용한 코드 생성과 compiler plugin 등록
└── ViewEquatableMacrosClient executable target
    └── package 내부의 사용 예제
```

앱에서 API로 보이는 부분은 `ViewEquatableMacros` library product가 제공하는 public macro 선언이다.

```swift
@attached(extension, conformances: Equatable, names: named(==))
public macro Equatable() = #externalMacro(
    module: "ViewEquatableMacrosMacros",
    type: "EquatableMacro"
)

@attached(peer, names: arbitrary)
public macro SkipEquatable() = #externalMacro(
    module: "ViewEquatableMacrosMacros",
    type: "SkipEquatableMacro"
)
```

`public macro` 선언은 macro의 이름과 적용 방식을 앱에 노출한다. `#externalMacro`의 `module`과 `type`은 해당 API를 처리할 macro implementation을 지정한다. 앱은 library product에 의존하고 공개 module만 import하며, SwiftSyntax를 사용하는 구현 module은 직접 import하지 않는다.

```swift
import ViewEquatableMacros
```

#### macro 사용과 생성 코드

앱에서는 View에 `Equatable` 구현 생성을 요청하는 `@Equatable`을 붙이고, 비교에서 제외할 프로퍼티에 `@SkipEquatable`을 명시한다.

```swift
@Equatable
struct DestinationFilterView: View {
    let destination: String

    @SkipEquatable
    let handler: FilterActionHandler
}
```

컴파일 과정에서 `ViewEquatableMacrosMacros` target의 implementation이 저장 프로퍼티를 읽고, `@SkipEquatable`이 붙은 프로퍼티를 제외한 `Equatable` extension을 생성한다.

```swift
extension DestinationFilterView: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.destination == rhs.destination
    }
}
```

Xcode의 **Expand Macro**로 생성된 extension을 확인했고, Simulator에서 수동 구현과 같은 비교 기준이 적용되는지도 확인했다. `Equatable`이 아닌 프로퍼티를 제외하지 않으면 생성된 `==`에서 컴파일 오류가 발생하므로, 제외할 의도를 `@SkipEquatable`로 드러내야 한다.

```text
SwiftUIViewDiffingLab 앱 target
        │ import ViewEquatableMacros
        ▼
ViewEquatableMacros library target
        │ #externalMacro로 구현 연결
        ▼
ViewEquatableMacrosMacros macro target
        │ 컴파일 시 Equatable 구현 생성
        ▼
DestinationFilterView의 Equatable extension
```

Swift macro의 일반적인 구조는 [Swift 공식 Macros 문서](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/macros/)에서 확인할 수 있다.

## 5. 마무리

이 사례를 통해 선언형 UI를 도입한다고 해서 성능에 대한 고민이 사라지는 것은 아니라는 점을 확인했다. SwiftUI에서는 상태 변경에 따라 View의 `body`가 다시 계산될 수 있으므로, View의 dependency와 identity, 동등성 비교가 중요하다.

Airbnb는 코드 전체의 closure 사용 방식을 변경하는 대신, 화면 출력에 영향을 주는 프로퍼티만 선별적으로 비교할 수 있도록 View에 `Equatable`을 적용하는 방법을 선택했다. 이는 SwiftUI의 업데이트 전체를 통제하는 방법이 아니라, SwiftUI가 비교를 수행할 때 사용할 동등성 기준을 제공하는 방법이다. 또한 수동 구현에서 발생할 수 있는 반복과 누락을 줄이기 위해 `@Equatable`과 `@SkipEquatable`이라는 사용 인터페이스를 설계하고, 이를 Swift macro로 구현했다.


## 6. Open Questions

### 1. 모든 View에 `@Equatable`을 적용하는 것이 좋은가?

단순하고 자주 갱신되지 않는 View에도 macro를 적용하면 API와 빌드 과정의 복잡도만 높아질 수 있다. 어떤 기준으로 적용 대상을 선택해야 할까?


### 2. 왜 첫 번째 상태 변경에서는 `==`가 호출되지 않았을까?

https://github.com/user-attachments/assets/976062f8-d752-4709-bdb9-0a52fcc02cc7

- 여행지 View에 @Equatable macro와 .equatable()을 적용했지만, 첫 번째 인원 변경에서는 여행지 View의 배경색이 바뀌었다.
- 로그를 확인해 보니 이때는 ==가 호출되지 않았다. 정확한 원인에 대해서는 잘 모르겠다...

## 7. 참고 자료

- [Airbnb Engineering — Understanding and Improving SwiftUI Performance](https://airbnb.tech/web/understanding-and-improving-swiftui-performance/)
- [Apple Developer — Understanding and improving SwiftUI performance](https://developer.apple.com/documentation/xcode/understanding-and-improving-swiftui-performance)
- [Apple Developer — Demystify SwiftUI performance](https://developer.apple.com/videos/play/wwdc2023/10160/)
- [Apple Developer — View.equatable()](https://developer.apple.com/documentation/swiftui/view/equatable())
- [The Swift Programming Language — Macros](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/macros/)
