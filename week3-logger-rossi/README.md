# 0. Logger 키워드 선택 이유

- `print`로도 충분히 디버깅을 할 수 있는데, 왜 `Logger`를 활용해서 디버깅을 할까?
- `print`와 `Logger`는 무엇이 다를까?
- 내가 만든 패키지에 로그를 넣으면, 그 패키지를 사용하는 사람에게 어떤 영향을 줄까?

# 1. Logger란?

`Logger`는 Apple의 통합 로깅 시스템(Unified Logging System)에 로그를 기록하기 위한 API입니다. `Logger`는 iOS 14.0 이상에서 사용할 수 있습니다.

`print`는 표준 출력에 문자열을 출력하는 반면, `Logger`는 Apple의 Unified Logging System을 통해 로그를 기록합니다. `Logger`로 기록한 로그는 Console.app, `log` 명령어, Xcode의 디버그 콘솔 등을 통해 확인할 수 있습니다.

```swift
import OSLog

let logger = Logger(subsystem: "com.rossi.StringReverseKit", category: "Core")

logger.debug("reversed 호출")
```

`subsystem`은 로그가 속한 큰 기능 영역을 나타내고, `category`는 그 subsystem 안에서 더 구체적인 영역을 나타냅니다.

- subsystem: 로그가 속한 큰 기능 영역을 식별합니다. 일반적으로 역도메인 표기법을 사용합니다.
    - Apple의 `OSLog` 문서도 subsystem을 역도메인으로 지정하는 예시를 사용하고 있습니다.
        - 보통 앱의 Bundle ID와 동일한 값을 사용합니다.
                
- category: subsystem 내부의 구체적인 기능 영역을 식별합니다.

## Logger가 제공하는 로그 메서드

| 메서드 | 실제 레벨 | 설명 |
| --- | --- | --- |
| `trace` | debug | 추적 메시지를 로그에 기록합니다. |
| `debug` | debug | 디버그 메시지를 로그에 기록합니다. |
| `info` | info | 로그에 정보성 메시지를 기록합니다. |
| `notice` | default | 기본 로그 유형을 사용하여 로그에 메시지를 기록합니다. |
| `warning` | error | 경고에 대한 정보를 로그에 기록합니다. |
| `error` | error | 오류에 대한 정보를 로그에 기록합니다. |
| `critical` | fault | 앱 실행 중 발생한 중요한 이벤트에 대한 메시지를 로그에 기록합니다. |
| `fault` | fault | 앱 실행 중 발생하는 버그에 대한 메시지를 로그에 기록합니다. |

메서드는 8개지만, 통합 로깅 시스템이 실제로 기록하는 레벨(`OSLogType`)은 debug, info, default, error, fault의 5개입니다. Xcode에서 `Logger` 선언부를 열어보면 `trace`는 "an alias for `debug`", `warning`은 "an alias for `error`"라고 명시되어 있고, `critical`은 가장 심각한 `fault` 레벨로 기록된다고 설명합니다.

레벨을 직접 지정하는 `log(level:_:)`도 있습니다.

```swift
public func log(level: OSLogType, _ message: OSLogMessage)
```

이 매핑을 알아야 하는 이유는 필터링 때문입니다. Console.app에서 `warning`으로 남긴 로그를 찾으려면 error 레벨로 필터를 걸어야 합니다.

# 2. 상황 가정

문자열을 뒤집는 아주 작은 패키지 `StringReverseKit`을 만들어 앱에 넣었습니다.

```swift
public struct StringReverseKit {

    public init() {}

    public func reversed(_ input: String) -> String {
        String(input.reversed())
    }
}
```

```swift
Button("reverse") {
    StringReverseKit().reversed(text)   // 아무 일도 안 일어남
}
```

하지만 버튼을 눌러도 화면 속의 Text에는 아무런 움직임이 없습니다.

패키지 안의 `reversed`가 제대로 호출됐는지, 안 됐는지 확인해 볼 방법이 없는데요,

만약 패키지가 로그를 남기고 있었다면 어땠을까요? 로그를 보고 '패키지 내부의 함수가 호출은 됐구나'를 확인한 뒤 View의 코드만 디버깅해볼 수 있습니다. 로그를 통해 패키지 내부의 실행 상태를 별도로 관찰할 수 있습니다.

# 3. Logger를 사용하는 작은 라이브러리 만들기

앞서 사용했던 문자열을 뒤집는 함수 하나짜리 패키지 StringReverseKit에 Logger를 추가합니다.

```swift
import OSLog

public struct StringReverseKit {

    private let logger = Logger(
        subsystem: "com.rossi.StringReverseKit",
        category: "Core"
    )

    public init() {}

    public func reversed(_ input: String) -> String {
        logger.debug("reversed 호출: 길이 \(input.count)")
        let result = String(input.reversed())
        logger.debug("결과 길이 \(result.count)")
        return result
    }
}
```

이 코드만 넣고 빌드하면 에러가 쏟아집니다.

`Logger`가 iOS 14 / macOS 11 이상에서 사용할 수 있는 API인데, 패키지가 최소 지원 버전을 선언하지 않았기 때문입니다. 패키지는 기본적으로 더 낮은 버전까지 지원한다고 가정하므로, `Logger`를 쓸 수 없다고 판단합니다.

따라서 `Package.swift`에 최소 지원 버전을 명시해야 합니다.

```swift
// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StringReverseKit",
    platforms: [.iOS(.v14), .macOS(.v11)],    // 추가된 줄!
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "StringReverseKit",
            targets: ["StringReverseKit"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "StringReverseKit"
        ),
        .testTarget(
            name: "StringReverseKitTests",
            dependencies: ["StringReverseKit"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
```

이렇게 패키지의 최소 지원 버전을 iOS 14로 올리면, 이 패키지를 사용하는 앱 역시 해당 패키지의 요구사항을 만족해야 하므로 iOS 13을 최소 지원 버전으로 유지할 수 없습니다.

이번 예제에서는 패키지 전체에서 `Logger`를 사용하기 때문에 최소 지원 버전을 iOS 14로 올렸습니다. 만약 패키지가 iOS 13까지 지원해야 한다면 `@available`과 `if #available`을 이용해 API availability를 고려한 별도의 설계가 필요합니다.

제작한 StringReverseKit을 GitHub에 올리고, 다른 프로젝트에서 SPM으로 가져옵니다.

https://github.com/oeunji/StringReverseKit.git

StringReverseKit을 import한 후 clean build를 해보면 정상적으로 패키지가 추가된 것을 알 수 있습니다.

```swift
import SwiftUI
import StringReverseKit

struct ContentView: View {
    @State private var text = "Package Lab !"

    var body: some View {
        VStack {
            Text(text)

            Button("reverse") {
                text = StringReverseKit().reversed(text)
            }
        }
        .padding()
    }
}
```

2장에서 던진 질문으로 돌아가 봅시다. `reversed`가 실제로 호출됐는지 이제 확인할 수 있을까요?

물론 breakpoint를 걸어 실행 흐름을 직접 확인할 수도 있습니다. 하지만 우리는 이미 패키지 안에 Logger를 넣어두었기 때문에, Console.app만 보면 "함수는 호출됐다"는 사실이 즉시 확인됩니다. 호출 여부에 대한 불확실성이 제거되면, 이제 View 쪽만 살펴보면 됩니다.


Xcode 콘솔에서도 앱을 실행하면 하단 디버그 콘솔에 로그가 나옵니다.

Console.app에서도 로그를 확인할 수 있는데요, 
Console.app에서는 시스템과 앱에서 발생하는 다양한 로그를 함께 확인할 수 있습니다. 이 수많은 로그에서 내 라이브러리가 남기는 로그를 찾는다면 어떻게 해야 할까요?

이전에 패키지를 만들 때 subsystem: "com.rossi.StringReverseKit"를 추가해줬는데요, 여기서 com.rossi.StringReverseKit를 검색하면 StringReverseKit이 남긴 로그를 필터링할 수 있습니다. `com.rossi.StringReverseKit`으로 필터를 걸면 해당 subsystem에 속한 로그만 추려서 확인할 수 있습니다.

<aside>
⚠️

`logger.debug`로 기록한 메시지는 기본적으로 debug logging이 활성화되지 않은 경우 캡처되지 않습니다. 개발 중에는 Console.app에서 디버그 메시지를 포함하도록 설정하여 확인할 수 있습니다.

</aside>

# 4. subsystem을 누가 정하는가?

```swift
private let logger = Logger(subsystem: "com.rossi.StringReverseKit", category: "Core")
```

지금 subsystem은 패키지 안에 하드코딩되어 있습니다.

이러면 StringReverseKit을 사용하는 다른 사람의 Console.app에서는 다음처럼 뜨게 됩니다.

<aside>

소비자 앱의 Console.app:
    com.rossi.StringReverseKit   ← 이건 뭐지?
    com.consumer.MyPhotoApp      ← 내 앱

</aside>

소비자 앱의 subsystem인 `com.consumer.MyPhotoApp`을 기준으로 필터링한다면, 별도의 subsystem을 사용하는 `StringReverseKit`의 로그는 해당 필터에 포함되지 않습니다.

여기부터는 하나의 정답이 있는 문제가 아니라 패키지 설계의 선택입니다.

### 방법 1: 하드코딩 + README.md에 문서화

```swift
private let logger = Logger(subsystem: "com.rossi.StringReverseKit", category: "Core")
```

앞에서 제시한 코드처럼 하드코딩을 해두고 README.md에 subsystem을 명시합니다.

### 방법 2: StringReverseKit을 사용하는 사람이 정하게

```swift
public struct StringReverseKit {
    private let logger: Logger

    public init(subsystem: String = "com.rossi.StringReverseKit") {
        self.logger = Logger(subsystem: subsystem, category: "Core")
    }
    ...
}
```

자기 앱에서 사용하는 subsystem을 전달하면 라이브러리 로그도 같은 subsystem으로 분류할 수 있습니다.

다만 방법 2를 택하면 `init` 시그니처만 바뀌는 게 아닙니다. `logger`를 선언과 동시에 초기화할 수 없게 되므로 프로퍼티 선언도 함께 바뀝니다. **공개 API를 하나 여는 결정이 내부 구현까지 연쇄적으로 바꿉니다.**

# 5. 그렇다면 Swift 생태계에서는 이 문제를 어떻게 풀고 있을까?

https://github.com/apple/swift-log

`apple/swift-log`는 Swift 생태계에서 라이브러리와 애플리케이션이 사용할 수 있도록 제공되는 오픈소스 로깅 API이며, 특히 서버 사이드 Swift를 포함한 다양한 환경에서 사용할 수 있도록 설계되어 있습니다.

구조의 핵심은 **로거가 목적지를 모른다**는 것입니다.

```swift
// os.Logger — 만드는 순간 목적지가 확정됨
Logger(subsystem: "com.rossi.StringReverseKit", category: "Core")

// swift-log — 이름표만 붙임
Logger(label: "com.rossi.StringReverseKit")
```

실제 출력은 `LogHandler` 프로토콜을 채택한 구현체가 담당하고, 어떤 구현체를 쓸지는 앱이 `LoggingSystem.bootstrap`으로 한 번 결정합니다. 라이브러리는 백엔드를 알 필요가 없습니다.

"한 번"은 관행이 아니라 강제입니다. 소스를 보면 `precondition`으로 검사하고 있어서, 두 번 호출하면 릴리스 빌드에서도 크래시가 납니다. **전역 설정의 안전성을 얻는 대신 유연성을 포기한 선택입니다.**

그리고 `Package.swift`에는 한 층이 더 있습니다. `MaxLogLevelNone` 같은 트레이트를 소비자가 켜면, 해당 레벨의 로그가 바이너리에서 아예 사라집니다.

```swift
.package(path: "../../", traits: ["MaxLogLevelNone"])
```

4장의 방법 1·2가 소스 코드 층위의 통제였다면, 이건 매니페스트 층위의 통제입니다.

### 기본값

앱이 `bootstrap`을 호출하지 않으면 `swift-log`는 로그를 **표준 에러로 그냥 출력합니다.** 즉 아무 설정도 안 한 소비자의 콘솔에 라이브러리 로그가 찍힙니다.

|  | 기본 동작 |
| --- | --- |
| `os.Logger`의 `debug` | 수집되지 않음 |
| `swift-log` (bootstrap 안 함) | 표준 에러로 출력됨 |
| `swift-log` (트레이트로 제거) | 코드가 아예 없음 |

같은 문제를 두고 Apple의 두 API가 서로 다른 기본값을 골랐습니다. **"라이브러리 로그는 기본으로 꺼져 있어야 한다"는 것도 정답이 아니라 선택이라는 뜻입니다.**

# 6. `print`와 `Logger`의 차이

패키지 안에 `print`를 넣어도 내부에서 어떤 일이 일어났는지 확인할 수 있습니다.

그런데 제가 만든 라이브러리를 다른 사람이 사용한다고 생각하면 이야기가 달라집니다. 라이브러리 내부에서 무분별하게 `print`를 사용한다면, 그 라이브러리를 쓰는 사람의 콘솔에도 원하지 않는 출력이 계속 나타납니다.

0장에서 던진 질문으로 돌아가 보겠습니다. `print`와 `Logger`는 무엇이 다를까요?

### 문자열을 미리 만든다

`Logger` 선언부를 보면 파라미터 타입이 `String`이 아닙니다.

```swift
public func debug(_ message: OSLogMessage)
```

그리고 "`OSLogMessage`를 직접 만들지 말고 문자열 보간을 넘기라"는 경고가 붙어 있습니다. 이 보간은 일반 `String` 보간이 아니라 컴파일러가 별도로 처리하는 경로이고, 포맷 문자열과 인자가 분리되어 저장됩니다.

`print`는 호출 시점에 완성된 문자열을 만들어 표준 출력에 씁니다.

### 끄고 켤 수 없다

`print`에는 로그 레벨이라는 개념이 없습니다. 라이브러리가 `print`로 메시지를 출력하면, 그 라이브러리를 쓰는 사람은 특정 메시지만 끄거나 레벨에 따라 관리할 방법이 없습니다.

반면 `Logger`는 `debug`, `info`, `default`, `error`, `fault`의 레벨을 제공합니다. 3장에서 본 것처럼 `debug`는 기본적으로 수집되지 않으므로, 라이브러리가 debug 레벨로 로그를 남기면 소비자가 켜지 않는 한 아무 일도 일어나지 않습니다.

### 누가 남긴 로그인지 알 수 없다

`print`가 남기는 것은 문자열 하나뿐입니다. 여러 라이브러리가 동시에 `print`를 사용하면, 출력된 문자열만 보고 어디서 나온 로그인지 구분할 수 없습니다.

반면 `Logger`는 `subsystem`과 `category`라는 **내용과 분리된 라벨**을 붙입니다. 메시지가 무슨 말을 하든 출처로 걸러낼 수 있습니다. 3장에서 Console.app의 수많은 로그 중 우리 것만 골라낼 수 있었던 이유입니다.

# 마무리

결국 `print`와 `Logger`의 차이는 단순히 문자열을 출력하느냐, 로그를 기록하느냐가 아닙니다.

`print`는 표준 출력에 문자열을 흘려보내고 끝나지만, `Logger`는 Apple의 Unified Logging System에 기록을 남깁니다. 그래서 레벨로 걸러내고, `subsystem`과 `category`로 분류하고, 저장하고, 개인정보를 보호하는 일을 시스템이 대신해 줍니다.

잠깐 값을 확인하는 용도라면 `print`도 충분합니다. 하지만 **다른 사람이 쓰는 패키지에서 로그를 남긴다면, 그 로그를 어떻게 관리하고 소비자에게 어떻게 노출할지까지 설계에 포함해야 합니다.**
