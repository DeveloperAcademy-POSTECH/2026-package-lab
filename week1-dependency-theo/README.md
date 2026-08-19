# 연구 배경

Challenge 4에서 네이버 지도관련 기능 구현을 위한 Swift Package 외부 라이브러리 적용한 경험을 했습니다.

## 1. 기능 사용에만 집중해서 생긴 단순한 이해

당시에는 Swift Package를 추가하는 것을 단순히 ‘외부 라이브러리를 프로젝트에 넣는 과정’ 정도로만 이해하고 있었고, Package를 추가한 이후 해당 라이브러리를 코드에서 사용할 수 있다는 것에만 집중했습니다.

따라서 당시에는 다음과 같이 단순하게 이해했습니다.

외부 Package 추가 → import → 외부 라이브러리 사용

즉, Package를 추가하는 과정과 실제 Target에서 해당 기능을 사용할 수 있게 되는 과정 사이에 어떤 구조가 존재하는지는 깊게 살펴보지 않았습니다.

## 2. 외부 Package와 Target 간의 연결 과정에 대한 궁금증 발생

하지만 Swift Package를 자세하게 알려고 하다보니, 외부 Package를 추가하는 것과 실제 Target에서 해당 기능을 사용할 수 있게 되는 과정이 어떻게 연결되는지에 대한 궁금증이 생겼습니다.

특히 Swift Package의 구조를 살펴보니 `Package`, `Product`, `Target`, `Module`이라는 서로 다른 개념이 존재했고, `Package.Dependency`와 `Target.Dependency`처럼 Dependency 또한 서로 다른 수준에서 선언되고 있었습니다.

이에 따라 다음과 같은 의문이 생겼습니다.

- 외부 Package를 추가하면 어떤 관계가 만들어질까요?
- Package가 제공하는 `Product`는 어떤 역할을 할까요?
- 외부 Package의 Product는 어떻게 내 `Target`과 연결될까요?
- Target의 Source가 만들어내는 `Module`과 `import`는 어떤 관계일까요?
- 외부 Package의 실제 사용 버전은 어떻게 결정될까요?

---

따라서 이번 연구를 통해 Swift Package에서 Dependency가 어떻게 선언되는지, 그리고 외부 Package가 제공하는 기능이 실제 Target에서 사용되기까지 Package → Product → Target → Module이 어떤 구조로 연결되는지 알아보고자 한다.

# 연구 질문

> Swift Package를 추가하면, 외부 라이브러리는 어떻게 내 Target에서 사용할 수 있게 될까?


## Q1. Package, Product, Target은 각각 무엇이고 어떤 관계를 가질까?

### 왜 이 질문을 했습니까?

처음에는 `import LibraryName`을 작성하면 Package 자체를 가져오는 것이라고 생각했습니다.

하지만 Apple의 Swift Package 관련 문서를 살펴보니 Package 안에는 `Product`, `Target`, `Dependency`와 같은 여러 구성 요소가 존재했습니다.

따라서 Dependency가 어떻게 연결되는지 이해하기 전에 개념을 먼저 분리할 필요가 있다고 생각했습니다.

### Package는 무엇인가요?

Swift Package는 `Package.swift`라는 Package Manifest를 통해 구성됩니다.

Apple의 `PackageDescription` 문서에 따르면 Package Manifest에서는 Package의 이름뿐만 아니라 다음과 같은 정보를 정의할 수 있습니다.

- Product
- Target
- 다른 Package에 대한 Dependency
- Platform 등 Package 구성 정보

개념적으로 다음과 같이 볼 수 있습니다.

```
Package
├── Products
├── Targets
└── Dependencies
```

즉, Package는 하나의 Module 자체라기보다 여러 Target, Product, Dependency 등의 구성을 표현하는 상위 단위입니다.

### Target의 정의

Apple은 `Target`을 Swift Package의 기본 구성 요소로 설명합니다.

각 Target은 Source File 집합을 가지고 있으며, Swift Package Manager는 해당 Source File들을 Module 또는 Test Suite로 컴파일합니다.

```
Target
├── SourceA.swift
├── SourceB.swift
└── SourceC.swift
        ↓
      Compile
        ↓
      Module
```

또한 Target은 Dependency를 가질 수 있습니다.

Apple 문서에 따르면 Target의 Dependency는 다음 중 하나가 될 수 있습니다.

```
Target.Dependency
├── 같은 Package 안의 다른 Target
└── Package Dependency가 제공하는 Product
```

따라서 Target은 단순한 Source Folder가 아니라 Source와 Dependency를 가지는 Package의 Build 구성 단위입니다.

### Module의 정의

이번 연구에서 다루는 일반적인 Swift Source Target에서는 Target에 포함된 Source File이 Swift Pacakge Manager에 의해 Module로 컴파일됩니다.

```
MapUI Target
    ↓
  Compile
    ↓
MapUI Module
```

그리고 Swift Source File에서는 만들어진 Module을 다음과 같이 import합니다.

```
import MapUI
```

따라서 `import MapUI`에서 직접 가져오는 대상을 Package라고 보기보다 Module의 선언을 현재 Source Code에서 사용하기 위한 Import라고 이해할 수 있습니다.

### Product의 정의

Apple의 `Product.library(name:type:targets:)` API는 Package에 Dependency를 선언한 Client가 Package의 기능을 사용할 수 있도록 Library Product를 생성합니다.

Product는 하나 이상의 Target을 포함하도록 정의할 수 있습니다.

```swift
product: [
    .library(
        name: "MapSDK",
        targets: ["MapCore", "MapUI"]
    )
]
```

이 구조를 그림으로 그려보면 다음과 같습니다.

```
MapPackage
│
├── MapCore Target ───┐
│                     ├──→ MapSDK Product
├── MapUI Target ─────┘
│
└── MapTesting Target
```

여기서 `MapTesting` Target은 Package 안에 존재하지만 `MapSDK` Product에는 포함되지 않았습니다.

Apple의 `Target` 문서에서는 Target을 다른 Package에 제공하려면 Target을 포함하는 Product를 정의할 수 있다고 설명합니다.

즉, Product는 Package가 다른 Client에게 제공하는 Build 결과물의 단위라고 볼 수 있습니다.

### Package, Product, Target, Module 관계

지금까지의 관계를 하나로 연결하면 다음과 같습니다.

```
Package
│
├── Product
│     ├── Target
│     │     ↓ Compile
│     │   Module
│     │
│     └── Target
│           ↓ Compile
│         Module
│
└── 다른 Target
```

중요한 점은 이름이 같을 수 있어도 각 개념의 역할은 다르다는 것입니다.

| 개념 | 이번 연구에서의 역할 |
| --- | --------------- |
| Package | Product, Target, Dependency 등의 전체 구성을 표현하는 단위 |
| Product | Package가 Client에게 제공하는 Build 결과물 |
| Target | Source File과 Dependency를 가지는 Package의 기본 구성 단위 |
| Module | 일반적인 Swift Source Target의 Source가 컴파일되어 만들어지는 import 가능한 코드 단위 |

### 이번 연구에서 얻은 결론

처음에는 다음과 같이 생각했습니다.

> "Package를 추가하면 Package를 import해서 사용합니다."

하지만 실제 구조는 더 세분화되어 있었습니다.

```
Package
  ↓
Product
  ↓
Target
  ↓ Compile
Module
  ↓
import
```

따라서 Dependency를 이해하려면 Package 자체와 실제 Swift 코드에서 import하는 Module을 같은 개념으로 보지 않는 것이 중요합니다.

#### 조사한 내용

- Package의 역할
- Product의 역할
- Target의 역할
- Target과 Module의 관계
- Product와 Target의 관계

---

## Q2. `Package.Dependency`와 `Target.Dependency`는 무엇이 다를까요?

### 왜 이 질문을 했습니까?

`Package.swift`를 보면 dependencies라는 이름이 두 곳에서 나타날 수 있습니다.

```swift
let package = Package(
    dependencies: [
        // ①
    ],
    targets: [
        .target(
            name: "MyApp",
            dependencies: [
                // ②
            ]
        )
    ]
)
```

처음에는 두 `dependencies`가 모두 외부 라이브러리를 넣는 같은 역할이라고 생각하기 쉬웠습니다.  
하지만 실제로는 서로 다른 레벨의 의존 관계를 정의합니다.

### `Package.Dependency`

`Package.Dependency`는 Package와 다른 Package 사이의 의존 관계를 나타냅니다.

예를 들어, 다음과 같이 외부 Package를 선언할 수 있습니다.

```swift
dependencies: [
    .package(
        url: "https://example.com/MapPackage.git",
        from: "1.0.0"
    )
]
```

개념적으로는 다음 관계 입니다.

```
MyPackage
    ↓
    ↓ Package.Dependency
    ↓
MapPackage
```

즉, "MyPackage는 MapPackage에 의존합니다."라는 Package 수준의 관계를 정의합니다.

이 단계에서는 아직 `MapPackage`가 제공하는 여러 Product 중 어떤 Product를 어떤 Target이 사용할지 결정하지 않습니다.

### `Target.Dependency`

외부 Package와의 관계를 만든 뒤에는 특정 Target이 실제로 어떤 기능을 필요로 하는지 정의해야 합니다.  
외부 Package가 다음과 같은 Product를 제공한다고 가정합니다.

```
MapPackage
├── MapSDK Product
├── MapAR Product
└── MapTestKit Product
```

`MyApp` Target이 `MapSDK`만 필요하다면 다음처럼 표현할 수 있습니다.

```swift
.target(
    name: "MyApp",
    dependencies: [
        .product(
            name: "MapSDK",
            package: "MapPackage"
        )
    ]
)
```

Apple의 `Target.Dependency.product(name:package:condition:)` API는 Package Dependency가 제공하는 Product에 대한 Target Dependency를 생성합니다.

구조는 다음과 같습니다.

```
MyApp Target
     ↓
     ↓ Target.Dependency
     ↓
MapSDK Product
```

### Target Dependency는 외부 Product만 의미하지 않습니다

`Target.Dependency`는 외부 Package의 Product뿐 아니라 같은 Package에 속한 다른 Target을 가리킬 수도 있습니다.

```swift
.target(
    name: "Feature",
    dependencies: [
        .target(name: "Core")
    ]
)
```

구조는 다음과 같습니다.

```
Feature Target
      ↓
      ↓ Target.Dependency
      ↓
Core Target
```

따라서 `Target.Dependency`를 단순히 "외부 라이브러리 Dependency"라고만 이해해서는 안 됩니다.

#### 두 Dependency의 차이

| 구분 | 연결 관게 | 의미 |
| --- | ------- | --- | 
| `Package.Dependency` | Package → Package | 내 Package가 어떤 외부 Package에 의존하는지 정의 |
| `Target.Dependency` | Target → Target 또는 Product | 특정 Target이 실제로 어떤 Target/Product에 의존하는지 정의 |

### 이번 연구에서 얻은 결론

처음에는 `dependencies`라는 이름 때문에 두 개념을 같은 것으로 생각했습니다.  
하지만 실제로는 다음처럼 역할이 분리됩니다.

> `Package.Dependency`는 Package와 Package 사이의 관계를 정의하고, `Target.Dependency`는 특정 Target이 같은 Package의 Target 또는 외부 Package가 제공하는 Product에 의존하도록 정의합니다.

이 구분이 외부 Package가 실제 Target까지 연결되는 과정을 이해하는 핵심이었습니다.

## Q3. 왜 외부 Package의 Target에 직접 의존하지 않고 Product를 통해 의존합니까?

### 왜 이 질문을 했습니까?

외부 Package 안에는 실제 코드가 들어 있는 Target이 존재합니다.
그렇다면 사용하는 쪽에서 바로 외부 Target을 선택하면 될거라고 생각했습니다.

```
MyApp Target
    ↓
External Target
```

하지만 Apple의 `Target` 문서에서는 외부 Package에 대해서 Target이 Package Dependency가 제공하는 Product에 의존할 수 있다고 설명합니다.
따라서 Product가 어떤 역할을 하는지 알아볼 필요가 있었습니다.

### Package 제작자는 Product를 정의합니다

예를 들어, 외부 Package가 다음 Target을 가지고 있다고 가정해보겠습니다.

```
MapPackage
├── MapCore Target
├── MapUI Target
└── MapTesting Target
```

Package 제작자는 Product를 다음과 같이 정의할 수 있습니다.

```swift
product: [
    .library(
        name: "MapSDK",
        targets: ["MapCore", "MapUI"]
    ),
    .library(
        name: "MapTestKit",
        targets: ["MapTesting"]
    )
]
```

그러면 외부에 제공되는 단위는 다음과 같이 표현할 수 있습니다.

```
MapPackage
│
├── MapSDK Product
│     ├── MapCore Target
│     └── MapUI Target
│
└── MapTestKit Product
      └── MapTesting Target
```

Apple의 `Product.library(name:type:targets:)` API는 Client가 Package에 Dependency를 선언하여 Package의 기능을 사용할 수 있도록 Library Product를 생성합니다.

또한 `Target` 문서에서는 Target을 다른 Package에 제공하려면 해당 Target을 포함하는 Product를 정의할 수 있다고 설명합니다.

### 사용하는 쪽에서는 필요한 Product를 선택합니다

일반 앱에서 지도 기능만 필요하다면 다음 관게만 만들 수 있습니다.

```
MyApp Target
    ↓
    ↓ Target.Dependency
    ↓
MapSDK Product
```

테스트 기능까지 필요한 Test Target은 다른 Product를 추가로 선택할 수 있습니다.

```
MyAppTests Target
    ├──→ MapSDK Product
    └──→ MapTestKit Product
```

따라서 외부 Package 전체를 하나의 기능으로 취급하기보다 Package가 제공하는 Product를 기준으로 Target Dependency를 구성할 수 있습니다.

### Product에 포함되지 않은 Target은 어떻게 되나요?

다음과 같이 Package 안에는 Target이 존재하지만 Product에 포함되지 않았다고 가정합니다.

```swift
products: [
    .library(
        name: "MapSDK",
        targets: ["MapCore"]
    )
],

targets: [
    .target(name: "MapCore"),
    .target(name: "MapInternal")
]
```

구조는 다음과 같습니다.

```
MapPackage
│
├── MapSDK Product
│     └── MapCore Target
│
└── MapInternal Target
```

`MapInternal`이 Package 안에 존재한다는 사실만으로 다른 Pacakge의 Client에게 Product를 통해 제공되는 것은 아닙니다.

Apple 문서에서 직접 확인할 수 있는 범윈ㄴ 다음과 같습니다.

> Target을 다른 Package에 제공하려면 해당 Target을 포함하는 Product를 정의할 수 있습니다.

따라서 이번 연구에서는 Product의 공식적인 역할인 Package가 Client에게 제공하는 Build 결과물과 Target의 구성 단계까지만 설명합니다.

### 이번 연구에서 얻은 결론

Product는 Target과 같은 개념이 아니었습니다.

Target → Source와 Dependency를 가지는 Package 구성 단위

Product → 하나 이상의 Target을 포함하여 Client에게 제공되는 Build 결과물

따라서 외부 Package를 사용하는 Target은 외부 Package 내부 Target에 직접 의존하기보다 Package Dependency가 제공하는 Product를 Target Dependency로 선택합니다.

## Q4. `Target.Dependency`가 있는데도 왜 `import`가 필요한가요?

### 왜 이 질문을 했습니까?

`MyApp` Target이 이미 `MapSDK` Product에 의존하도록 연결되었다면 다음과 같은 의문이 생겼습니다.

> 이미 Dependency가 있는데 왜 Swift Source File에서 다시 `import MapUI`를 작성해야 할까요?

처음에는 `import`가 Target을 찾아 Source Code를 Module로 변환해 주는 과정이라고 생각했습니다.

하지만 Target Dependency와 import는 서로 다른 역할을 수행합니다.

### Target의 Source는 Module로 컴파일됩니다

Apple의 `Target` 문서에 따르면 각 Target은 Source File 집합을 가지며, Swift Package Manager는 이를 Module 또는 Test Suite로 컴파일합니다.

```
MapUI Target
     ↓
 Source Files
     ↓ Compile
MapUI Module
```

따라서 다음 설명은 잘못된 이해였었습니다.

```
import MapUI
    ↓
Target을 Module로 변환
```

`import` 때문에 Module이 만들어지는 것이 아닙니다.

### `Target.Dependency`는 Build 구성의 관계이다

```swift
.target(
    name: "MyApp",
    dependencies: [
        .product(
            name: "MapSDK",
            package: "MapPackage"
        )
    ]
)
```

이 선언은 다음 관계를 표현합니다.

```
MyApp Target
      ↓
      ↓ Target.Dependency
      ↓
MapSDK Product
```

즉, "MyApp Target은 MapSDK Product에 의존합니다."라는 Target 수준의 Dependency를 정의합니다.

### `import`는 Swift Source Code에서 Module을 사용합니다

Product를 구성하는 Swift Source Target의 Source가 Module로 컴파일된 뒤 Swift Source File에서는 해당 Module을 import하여 그 Module이 제공하는 선언을 사용할 수 있습니다.

```
import MapUI

let mapView = MapView()
```

따라서 역할을 분리하면 다음과 같습니다.

Target.Dependency = Build 구성에서 Target이 무엇에 의존하는가?  
import = Swift Source File에서 어떤 Module의 선언을 사용할 것인가?

#### 전체 관계

```
외부 Package
    │
    └── MapSDK Product
           │
           └── MapUI Target
                  │
                  │ Compile
                  ▼
              MapUI Module
                  ▲
                  │ import MapUI
                  │
            Swift Source File

MyApp Target
    │
    │ Target.Dependency
    ▼
MapSDK Product
```

이 구조를 통해 Dependency와 import가 서로 다른 층에서 동작한다는 것을 이해할 수 있습니다.

### 이번 연구에서 얻은 결론

처음에는 다음과 같이 생각했습니다.

> import를 하면 Package의 Target을 찾아 Module로 만들어 준다.

하지만 실제로는 다음과 같이 이해하는 것이 더 정확하다는 것을 알게되었습니다.

> Target의 Source File은 Swift Package Manager에 의해 Module로 컴파일되고, `Target.Dependency`는 내 Target과 Product 또는 다른 Target의 Build 의존 관계를 정의하며, `import`는 Swift Source Code에서 해당 Module의 선언을 사용하기 위한 선언입니다.

## Q5. Package의 버전은 어떻게 결정되나요?

### 왜 이 질문을 했습니까?

외부 Package를 추가할 때 다음과 같은 코드를 사용할 수 있습니다.

```swift
.package(
    url: "https://example.com/MapPackage.git",
    from: "1.0.0"
)
```

처음에는 `from: "1.0.0"`이라고 작성하면 정확히 `1.0.0`만 사용하는 것이라고 생각했습니다.

하지만 Apple의 Package Dependency API에서는 `from:`이 정확한 버전을 고정하는 의미가 아니라 최소 버전부터 다음 Major Version 전까지의 Version Requirement를 표현합니다.

### `from: "1.0.0"`은 정확한 하나의 버전이 아니다

다음 선언을 예로 들 수 있습니다.

```swift
.package(
    url: "https://example.com/MapPackage.git",
    from: "1.0.0"
)
```

Apple의 `package(...from:)` API는 주어진 최소 버전에서 시작하여 다음 Major Version 전까지의 Requirement를 만듭니다.
따라서 개념적으로 다음 범위입니다.

```
1.0.0 <= version < 2.0.0
```

예를 들어, 다음 버전들은 Requirement를 만족할 수 있습니다.

```
1.0.0 ✅
1.0.1 ✅
1.3.0 ✅
1.9.0 ✅
2.0.0 ❌
```

### 정확한 버전만 사용하려면 `exact:`가 존재합니다

정확한 특정 버전을 요구하는 API도 존재합니다.

```swift
.package(
    url: "https://example.com/MapPackage.git",
    exact: "1.0.0"
)
```

Apple의 `package(url:exact:)`문서는 Exact Version Requirement가 Dependency Graph에서 다른 Package와 충돌을 만들 수 있으므로 권장되지 않는다고 설명하고, Version Range를 고려할 것을 안내합니다.

### Dependency Resolution은 무엇인가요?

`from: "1.0.0"`은 하나의 정확한 버전을 결정하지 않습니다.

```
가능한 버전

1.0.0
1.1.0
1.5.0
1.9.0
...
```

따라서 Swift Package Manager는 실제로 사용할 정확한 버전을 결정해야 합니다.

Apple은 `Package.Dependency` 문서에서 Swift Package Manager가 Dependency Resolution이라는 과정을 수행하여 앱 또는 다른 Swift Package가 사용할 Package Dependency의 정확한 버전을 결정한다고 설명합니다.

```
Package.Dependency

Package 정보
+
Version Requirement
        ↓
Dependency Resolution
        ↓
실제 사용할 정확한 버전
```

### 여러 Package가 같은 Dependency를 요구하면 어떻게 될까요?

다음 상황을 가정합니다.

```
PackageA → GeometryPackage: 1.2.0 ..< 2.0.0
PackageB → GeometryPackage: 1.5.0 ..< 2.0.0
```

두 조건이 동시에 만족되어야 한다면 공통 범위는 다음과 같습니다.

```
1.5.0 ..< 2.0.0
```

Apple의 `Package.Dependency`와 Version Requirement 관련 문서는 Swift Package Manager가 Dependency Resolution을 통해 사용할 정확한 Version을 결정한다고 설명합니다.
또한 Exact Version Requirement 문서는 여러 Package가 같은 Package에 의존할 때 서로 다른 요구사항이 Dependency Graph의 출돌을 만들 수 있음을 설명합니다.

반대로 다음처럼 공통 범위가 없다면 문제가 발생할 수 있습니다.

```
PackageA
→ GeometryPackage: 1.0.0 ..< 2.0.0

PackageB
→ GeometryPackage: 2.0.0 ..< 3.0.0

1.x 범위        [ 1.0.0 -------- 2.0.0 )
2.x 범위                          [ 2.0.0 -------- 3.0.0 )

공통 범위 없음
```

이 경우 서로 양립할 수 없는 Version Requirement가 Dependency Graph의 충돌 원인이 될 수 있습니다.
어떤 구체적인 오류 메시지와 해결 절차가 나타나는지는 사용하는 Xcode와 Package 구성에 따라 달라질 수 있으므로 이번 문서에서는 단정하지 않습니다.

### `Package.resolved`는 무엇인가요?

Version Requirement는 허용 가능한 범위를 표현하고, Dependency Resolution은 그 조건을 바탕으로 실제 사용할 버전을 선택합니다.

Apple의 `Package.Dependency` 문서에서는 `Package.resolved`가 Dependency Resolution의 결과를 기록한다고 설명합니다.

예를 들어,

```
Package.swift

from: "1.0.0"
→ 허용 범위: 1.0.0 ..< 2.0.0

            ↓
   Dependency Resolution
            ↓

Package.resolved
→ 1.9.0
```

여기서 둘은 모순되지 않습니다.

Package.swift = 어떤 버전을 허용하는가?  
Package.resolved = 그 Requirement를 바탕으로 실제 어떤 버전을 사용하기로 결정했는가?

Apple의 Xcode CI 관련 ㅁ누서에서도 Xcode가 각 Package Dependency의 정확한 버전을 `Package.resolved`에 저장하며, Package Requirement가 변경되면 이 파일이 갱신될 수 있다고 설명합니다.

### 이번 연구에서 얻은 결론

`Package.Dependency`는 단순히 외부 Package의 URL만 저장하는 개념이 아니었습니다.

```
Package.Dependency
├── 어떤 Package에 의존하는가?
└── 어떤 Version Requirement로 의존하는가?
          ↓
   Dependency Resolution
          ↓
   실제 Version 결정
          ↓
   Package.resolved
```

따라서 Swift Package의 Dependency를 이해하려면 Package 간의 관계뿐 아니라 Version Requirement와 Resolution도 함께 이해할 필요가 있습니다.

## Q6. 여러 Package Dependency가 연결되면 Dependency Graph는 어떻게 형성됩니까?

### 왜 이 질문을 했습니까?

내 Package가 의존하는 외부 Package가 다시 다른 Package에 의존할 수도 있습니다.

예를 들어 다음과 같은 구조입니다.

```
MyPackage
    ↓
MapPackage
    ↓
GeometryPackage
```

이 결우 `MyPackage`는 `MapPackage`만 직접 추가했는데도 `GeometryPackage`가 전체 Dependency 구조에 포함됩니다.

따라서 Package Dependency가 여러 단계로 연결될 때 Swift Package Manager가 이를 어떻게 다루는지 알아볼 필요가 있었습니다.

### Direct Dependency와 Transitive Dependency

`Package.Dependency`는 하나의 Package가 다른 Package에 의존한다는 관계를 선언합니다.
외부 Package가 자신의 Manifest에서 다시 다른 Package Dependency를 선언하면 다음과 같은 연쇄적인 구조가 만들어질 수 있습니다.

```
MyPackage
    │
    └── MapPackage
          │
          └── GeometryPackage
```

이 구조에서 `MyPackage`가 직접 선언한 `MapPackage`는 Direct Dependency이고, `MapPackage`를 거쳐 연결되는 `GeometryPackage`는 `MyPackage` 관점에서 Transitive Dependency입니다.

Apple의 WWDC18 Getting to Know Swift Package Manager에서도 SwiftPM이 먼저 Direct Dependency의 버전을 Resolve한 뒤, 그 Package들이 가지고 있는 Transitive Dependency를 재구적으로 확인한다고 설명합니다.

따라서 Package Dependency는 내가 `Package.swift`에 직접 작성한 Package만으로 끝나는 것이 아니라, 각 Dependency Package가 다시 선언한 Dependency까지 이어지며 전체 Package Graph를 구성합니다.

### Dependency Graph 전체가 Version Resolution에 영향을 줍니다

다음처럼 서로 다른 경로에서 같은 Package를 요구할 수 있습니다.

```
MyPackage
├── PackageA
│     └── GeometryPackage: 1.0.0 ..< 2.0.0
│
└── PackageB
      └── GeometryPackage: 1.5.0 ..< 2.0.0
```

이 경우 공통 범위는 다음과 같습니다.

```
1.5.0 ..< 2.0.0
```

반대로 Requirement가 서로 겹치지 않는다면 Dependency Resolution Error가 발생할 수 있습니다.

즉, Package Dependency는 단순한 일렬 구조가 아니라 여러 Package와 Requirement가 연결된 Graph로 이해할 필요가 있습니다.

### 이번 연구에서 얻은 결론

외부 Package 하나를 추가한다고 해서 그 Package 하나만 고려하면 되는 것은 아니었습니다.

내 Package가 직접 선언한 Package Dependency + 의존하는 Package가 다시 선언한 Package Dependency + 각 Package의 Version Requirement  
→ Pakcage Dependency Graph  
→ Dependency Resolution

따라서 Package가 커지고 여러 외부 Dependency가 연결될수도록 전체 Dependency Graph를 함께 이해하는 것이 중요합니다.

## 최종 결론

이번 연구는 다음 질문에서 시작했습니다.

> Swift Package를 추가하면, 외부 라이브러리는 어떻게 내 Target에서 사용할 수 있게 될까?

처음에는 Xcode에서 Package를 추가하면 바로 `import`할 수 있기 때문에 Package 자체가 Target에 들어오고 이를 import한다고 생각했습니다.

하지만 실제 구조는 다음과 같이 여러 단계로 분리되어 있었습니다.

```
Package.Dependency
       ↓
외부 Package와의 의존 관계
       ↓
Version Requirement / Dependency Resolution
       ↓
외부 Package가 Product 제공
       ↓
Target.Dependency
       ↓
내 Target과 외부 Product 연결
       ↓
Product를 구성하는 Swift Source Target
       ↓
Module로 컴파일
       ↓
import Module
       ↓
Swift Source Code에서 API 사용
```

따라서 현재 내린 결론은 다음과 같습니다.

> Swift Package Dependency는 단순히 외부 라이브러리를 프로젝트에 복사하거나 추가하는 기능이 아닙니다.
> Package 수준에서는 Package.Dependency를 통해 외부 Package와의 관계와 Version Requirement를 정의하고, Target 수준에서는 외부 Package가 제공하는 Product를 Target.Dependency로 연결합니다.
> Product를 구성하는 Swift Source Target의 Source는 Module로 컴파일되며, 실제 Swift Source File에서는 해당 Module을 import하여 API를 사용합니다.

이번 연구를 통해 Challenge 4에서 단순히 Xcode UI로 수행했던 "Package 추가 → Target 선택 → import" 과정이 실제로는 Package, Product, Target, Module과 두 종류의 Dependency가 연결되는 과정이라는 점을 이해하게 되었습니다.
