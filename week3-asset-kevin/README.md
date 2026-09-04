# Asset Catalog Build & Runtime Resource Lookup


## 1. Why did I select this keyword?

SwiftUI에서 이미지를 사용할 때 평소에는 다음과 같이 작성해왔다.

```swift
Image("Fish")
```

`"Fish"`만으로 어떻게 이미지가 화면에 나타나는지, Xcode에 추가한 Asset이 Build 과정에서 어떻게 처리되는지는 정확히 알지 못했었다.

특히 `Assets.xcassets`를 하나의 특수한 파일처럼 생각하고 있었고, Asset Catalog 내부의 이미지와 metadata가 Build 이후에도 그대로 존재하는지 알지 못했다.
추가로 Challenge6와 가장 연관있는 내용을 주제로 다루고 싶었고, 3D Assets을 가져오는 내용을 자세히 탐구해보는 시간을 갖고자 하였다.

> **"Xcode에 추가한 Asset은 어떤 과정을 거쳐 `Image("Fish")`로 찾아지는가?"**

이번 탐구의 범위를 다음과 같이 설정했다.

```text
Assets.xcassets
      ↓
Asset Catalog Compiler (actool)
      ↓
Assets.car
      ↓
Application Bundle
      ↓
Runtime Resource Lookup
```

---

## 2. Guiding Questions & Research

### Guiding Question 1

#### `Assets.xcassets`는 실제로 어떤 구조로 되어 있을까?

처음에는 `.xcassets`를 하나의 파일이라고 생각했다.

Finder에서 `Assets.xcassets`의 내부 구조를 직접 확인해보니 하나의 이미지 파일이 아니라 여러 Asset Set을 포함하는 구조라는 것을 확인할 수 있었다.

```text
Assets.xcassets
└── Fish.imageset
    ├── fish.png
    └── Contents.json
```

`Fish.imageset`에는 실제 이미지와 `Contents.json`이 함께 존재했다.

`Contents.json`을 살펴보면서 `filename`, `scale`, `idiom`, `appearance`처럼 이미지와 관련된 metadata가 관리된다는 것도 확인했다.

또한 하나의 Asset Set 안에서 해상도나 Appearance 등에 따른 여러 variation을 관리할 수 있다는 것을 알게 되었다.

---

### Guiding Question 2

#### Asset Catalog는 Build 후에도 `.xcassets` 형태로 존재할까?

처음에는 원본 Asset Catalog가 그대로 `.app`에 들어가지는 않을 것이라고 예상했다.

직접 프로젝트를 Build한 뒤 `.app`의 Package Contents를 확인했다.

```text
AssetProject.app
├── AssetProject
├── Assets.car
├── Info.plist
└── ...
```

여기에서는 `Assets.xcassets`, `Fish.imageset`, `Contents.json`을 찾을 수 없었고 대신 `Assets.car`가 존재했다.

Apple의 Xcode command-line tool 문서를 조사하면서 `actool`이 Asset Catalog를 compile하는 도구라는 것을 확인했다.

따라서 다음과 같은 관계를 이해할 수 있었다.

```text
Assets.xcassets
      ↓
Asset Catalog Compiler (actool)
      ↓
Compiled Asset Catalog
      ↓
Assets.car
```

즉 개발할 때 사용하는 Source 형태의 Asset Catalog가 그대로 Build Product에 복사되는 것이 아니라, Build 과정에서 처리된다는 것을 확인했다.

---

### Guiding Question 3

#### `.app`은 단순한 실행 파일일까?

Build Product를 관찰하면서 `.app` 안에는 실행 파일뿐만 아니라 `Assets.car`, `Info.plist` 등 여러 파일이 함께 존재한다는 것을 확인했다.

```text
AssetProject.app
├── AssetProject      ← executable
├── Assets.car        ← resource
└── Info.plist        ← metadata
```

이를 Apple의 Bundle 문서와 연결하면서 `.app`을 하나의 **Application Bundle**로 이해하게 되었다.

즉 내가 처음 생각했던:

```text
.app = 실행 파일
```

이 아니라,

```text
.app
= Application Bundle
= executable + resources + metadata + ...
```

라는 구조로 이해를 하게 되었다.

정리하면, Application Bundle은 실제 앱의 파일 구조이자 패키징 단위이다.
반면 Foundation의 Bundle 타입은 코드에서 특정 Bundle을 나타내고, 그 안의 Resource를 찾을 수 있게 해주는 타입이다.

이 과정에서 처음에는 `Fish.imageset` 같은 Asset도 Bundle이라고 생각할 수 있는지 헷갈렸다.

하지만 개념을 다음과 같이 구분할 수 있었다.

```text
Fish.imageset
→ Asset Set

Assets.xcassets
→ Asset Catalog

AssetProject.app
→ Application Bundle

Foundation Bundle
→ Bundle을 나타내고 접근하기 위한 타입
```

---

### Guiding Question 4

#### `Image("Fish")`에서 `"Fish"`는 무엇이고 어디에서 찾는 것일까?

SwiftUI의 `Image.init(_:bundle:)` 문서를 확인했다.

```swift
init(
    _ name: String,
    bundle: Bundle? = nil
)
```

처음에는 `name`과 `bundle`의 역할이 명확하게 구분되지 않았다.

문서를 읽으면서 두 parameter를 다음 질문으로 구분했다.

```text
name
→ 무엇을 찾는가?

bundle
→ 어디에서 찾는가?
```

따라서:

```swift
Image("Fish")
```

에서 `"Fish"`는 **찾고자 하는 image resource의 이름**이고, `bundle`은 **그 image resource를 어느 Bundle에서 검색할지를 지정한다**고 이해했다.

또한 `bundle`의 기본값은 `nil`이며, Apple 문서에 따르면 이 경우 SwiftUI는 **main Bundle**을 사용한다.

따라서 현재 내가 이해한 것은 다음과 같다.

```text
Image("Fish")

"Fish"
→ 무엇을?
→ "Fish"라는 이름의 image resource

bundle = nil
→ 어디에서?
→ main Bundle
```

이 과정에서 `Image("Fish")`가 단순히 특정 PNG 파일 이름을 전달하는 코드가 아니라, **이름을 이용해 image resource를 lookup하는 API**라는 관점으로 이해가 바뀌었다.

---

## 3. Main Contents — Asset Pipeline

이번 탐구를 통해 내가 이해한 Asset의 전체 흐름은 다음과 같다.

```text
[Source]

Assets.xcassets
└── Fish.imageset
    ├── image
    └── Contents.json
           │
           ▼

[Build]

Asset Catalog Compiler
(actool)
           │
           ▼

[Build Product]

Assets.car
           │
           ▼

[Application Bundle]

AssetProject.app
├── executable
├── Assets.car
└── Info.plist
           │
           ▼

[Runtime Lookup]

Image("Fish")
├── 무엇을? → "Fish" image resource
└── 어디서? → main Bundle
```

---

## 4. Conclusion — Asset Pipeline

탐구 전에는 Asset을 다음 정도로 이해하고 있었다.

```text
Assets.xcassets
      ↓
Image("Fish")
      ↓
화면
```

결국 중간 과정은 모두 **"Xcode가 알아서 처리한다"**고 생각하고 있었다.

이번 탐구를 통해 이 사이에도 다음과 같은 단계가 있다는 것을 알게 되었다.

```text
Source
→ Build
→ Compiled Resource
→ Bundle
→ Runtime Lookup
```

특히 개발할 때 보는 `Fish.imageset`, `Contents.json` 등의 Source 구조가 Runtime까지 그대로 사용되는 것이 아니라, Build 과정에서 Asset Catalog가 처리되어 Build Product의 Resource로 포함된다는 점을 알게 되었다.

또한 `Image("Fish")`도 단순히 파일 이름을 전달하는 코드라고 생각하기보다,

> **어떤 이름의 image resource를 어느 Bundle에서 찾을 것인가**

라는 관점으로 이해할 수 있게 되었다.

---

## 5. Swift Package Resource로 확장

App Target의 Asset Pipeline을 이해한 뒤, Resource의 소속을 Swift Package Target으로 바꾸어 생각해보았다.

기존에는:

```text
App Target
└── Assets.xcassets
    └── Fish.imageset
```

였다.

그런데 다음과 같이 `Fish`가 Swift Package에 있다면 어떻게 될지 궁금해졌다.

```text
App Target
└── ContentView.swift


Swift Package
└── FishFeature Target
    └── Resources
        └── Assets.xcassets
            └── Fish.imageset
```

App Target에서는:

```swift
Image("Fish")
```

가 기본적으로 main Bundle에서 `"Fish"`라는 image resource를 검색한다는 것을 앞에서 확인했다.

하지만 Package의 Resource가 Build 후 어디에 위치하는지 몰랐기 때문에 처음에는 `Image("Fish")`를 그대로 사용할 수 있는지 판단하기 어려웠다.

이를 알아보기 위해 **Target → Resource → Resource 처리 → Resource Bundle → `Bundle.module`** 순서로 탐구를 이어갔다.

---

## 6. Guiding Questions & Research — Swift Package Resource

### Guiding Question 5

#### Target은 무엇이고 Resource가 Target에 속한다는 것은 무슨 의미일까?

처음에는 `Target`이라는 용어 자체가 익숙하지 않았다.

Apple의 `PackageDescription.Target` 문서를 확인하면서 Swift Package의 Target이 Package를 구성하는 기본적인 단위이며, Target의 Source File들이 Module 또는 Test Suite로 compile된다는 것을 확인했다.

이번 탐구에서는 Module 자체를 깊게 조사하기보다 흐름을 이해하는 데 필요한 수준으로 다음과 같이 정리했다.

```text
Package
└── Target
    ├── Source Files
    └── Resources
```

Apple의 Swift Package Resource 문서에서는 Source Code와 마찬가지로 Resource도 Target에 scope된다고 설명한다.

따라서:

```text
MyPackage
└── FishFeature Target
    ├── FishView.swift
    └── Resources
        └── Assets.xcassets
            └── Fish.imageset
```

에서 `Fish`는 단순히:

> "MyPackage 어딘가에 있는 Resource"

라고 보기보다:

> **"FishFeature Target에 속한 Resource"**

라고 이해할 수 있었다.

---

### Guiding Question 6

#### Swift Package에서는 Resource를 어떻게 인식하고 처리할까?

Asset Catalog처럼 Xcode가 자동으로 Resource로 인식하고 처리하는 유형도 있다. 따라서 Asset Catalog를 사용하기 위해 반드시 Package Manifest(Package.swift는 Swift Package의 Manifest 파일로, 이 Package를 어떻게 구성할 것인지 Swift Package Manager에게 알려주는 설정 파일이다)에 .process()를 직접 선언해야 하는 것은 아니다.
반면 자동으로 처리되지 않는 Resource는 Package의 구성 파일인 Package.swift에서 .process(...)나 .copy(...) 같은 규칙을 명시할 수 있다.

Swift Package의 `Package.swift`에서는 Target을 선언하면서 `resources`를 지정할 수 있다.

예를 들어:

```swift
.target(
    name: "FishFeature",
    resources: [
        .process("Resources")
    ]
)
```

처럼 선언할 수 있다.

처음 `.process("Resources")`를 보았을 때는 단순히:

> "Resources를 처리하는 건가?"

정도로 생각했다.

Swift Package에서는 Resource 처리 규칙으로 `.process()`뿐만 아니라 `.copy()`도 제공한다.

두 방식의 차이를 다음과 같이 이해했다.

```text
.process(...)
      ↓
Build 과정에서 Resource 종류와 플랫폼에 맞는
적절한 처리를 적용할 수 있음


.copy(...)
      ↓
Resource를 원본 형태(as-is)로 복사
디렉터리를 지정하면 디렉터리 구조를 유지
```

단, `.process()`라고 해서 모든 종류의 Resource가 동일한 방식으로 compile된다는 의미는 아니다. Resource 종류와 platform에 따라 적용되는 처리가 달라질 수 있다.

또한 두 규칙은 디렉터리 구조에서도 차이가 있다. .copy()에 디렉터리를 지정하면 해당 디렉터리 구조가 유지된다. 반면 .process()는 디렉터리 내부 Resource에 recursively processing rule을 적용하고, 특별한 처리가 없는 Resource는 Resource Bundle의 top level에 배치될 수 있다. 따라서 두 규칙은 단순히 “Build 처리를 하는가”뿐 아니라 Resource의 기존 디렉터리 구조를 유지해야 하는가도 선택 기준이 될 수 있다.

---

### Guiding Question 7

#### Swift Package Target의 Resource도 App의 main Bundle에 들어갈까?

처음에는 두 가지 가능성을 생각했다.

```text
1. App Resource처럼 Application Bundle에서 관리될까?

2. Package에서 관리하는 Resource이므로 별도의 Resource Bundle이 만들어질까?
```

처음에는 어느 쪽인지 판단하기 어려웠지만, Package로 Resource를 처리한다는 점에서 App Target의 Resource와 무언가 다르게 관리될 수도 있다고 예상했다.

Apple의 **Bundling resources with a Swift package** 문서를 확인하면서 Package Target의 Resource를 위한 Resource Bundle과 그 Resource에 접근하기 위한 Bundle accessor에 대해 확인했다.

따라서 다음과 같은 구조로 이해할 수 있었다.

```text
MyPackage
└── FishFeature Target
    ├── FishView.swift
    └── Resources
        └── Assets.xcassets
            └── Fish.imageset
(FishFeature Target을 대상으로)
            ↓ Build

FishFeature Module
+
FishFeature의 Resource Bundle
```

여기서 처음에 던졌던 질문으로 다시 돌아갈 수 있었다.

```swift
Image("Fish")
```

를 사용하면 `bundle`의 기본값이 `nil`이므로 SwiftUI는 main Bundle을 검색한다.

하지만 `"Fish"`는 이제 App Target의 Resource가 아니라 `FishFeature Target`의 Resource다.

따라서 다음과 같이 검색하려는 Bundle과 Resource가 속한 Bundle이 달라질 수 있다는 문제를 발견했다.

```text
Image("Fish")

검색하려는 곳
→ main Bundle

Fish가 속한 곳
→ FishFeature Target의 Resource Bundle
```

---

### Guiding Question 8

#### `Bundle.module`은 왜 필요할까?

Swift Package Manager는 Package Target의 Resource Bundle에 접근할 수 있도록 `Bundle.module` accessor를 제공한다.


앞에서 배운 `Image(_:bundle:)`과 연결하면:

```swift
// FishFeature Module 내부
Image("Fish", bundle: .module)
```

처럼 사용할 수 있다.

이 코드를 앞에서 사용했던 **"무엇을 찾는가 / 어디에서 찾는가"**라는 관점으로 다시 보면:

```text
// FishFeature Module 내부
Image("Fish", bundle: .module)

"Fish"
→ 무엇을 찾을까?
→ "Fish"라는 image resource

.module
→ 어디에서 찾을까?
→ 현재 Package Target의 Resource Bundle
```

이 된다.

따라서 App Target과 Swift Package Target의 Resource lookup을 다음과 같이 비교할 수 있다.

```swift
// App Target의 image resource
Image("Fish")
// bundle 생략 → main Bundle


// FishFeature Module 내부
Image("Fish", bundle: .module)
// Package Target의 Resource Bundle
```
Resource를 포함하는 Package Target을 Build하면 해당 Module을 위한 Resource Bundle과 Bundle.module accessor가 생성된다.
따라서 FishFeature Module 내부에서 Bundle.module을 사용하면 FishFeature Module의 Resource Bundle에 접근할 수 있다.

여기서 Bundle.module은 Package 전체에 하나 존재하는 전역 Bundle이 아니다. Resource를 가진 Package Module마다 해당 Module의 Resource Bundle에 접근하기 위한 accessor가 생성된다.
(Apple 문서에서는 이를 Bundle의 internal static extension이라고 설명한다.)

---

## 7. App Target과 Swift Package Target 비교

두 번의 탐구를 통해 이해한 흐름을 나란히 비교하면 다음과 같다.

### App Target

```text
Assets.xcassets
      ↓
Asset Catalog Compiler
      ↓
Compiled Asset
      ↓
Application Bundle
      ↓
main Bundle
      ↓
Image("Fish")
```

### Swift Package Target

```text
Swift Package
      ↓
Target
      ↓
Resource
      ↓
.process / .copy
      ↓
Target의 Resource Bundle
      ↓
Bundle.module
      ↓
Image("Fish", bundle: .module)
```

두 흐름의 핵심적인 차이를 **Resource의 소속과 Runtime Lookup에서 사용하는 Bundle**이라는 관점으로 정리할 수 있었다.

```text
Image("Fish")
→ bundle 생략
→ main Bundle에서 lookup

// FishFeature Module 내부
Image("Fish", bundle: .module)
→ FishFeature Module의 Resource Bundle에서 lookup
```

---

## 8. Final Conclusion

이번 탐구는 다음과 같은 간단한 코드에서 시작했다.

```swift
Image("Fish")
```

처음에는 `"Fish"`라는 문자열을 넘기면 Xcode가 알아서 이미지를 찾아 화면에 보여주는 정도로 생각했다.

첫 번째 Research Cycle에서는 그 사이에:

```text
Asset Catalog
      ↓
Build
      ↓
Compiled Resource
      ↓
Application Bundle
      ↓
Runtime Lookup
```

이라는 과정이 있다는 것을 이해했다.

두 번째 Research Cycle에서는 이를 Swift Package까지 확장했다.

```text
Package
      ↓
Target
      ↓
Resource
      ↓
.process / .copy
      ↓
Resource Bundle
      ↓
Bundle.module
```

이를 통해 Resource에는 **어느 Target에 속하는가**라는 개념이 있고, Runtime에서는 **어느 Bundle에서 Resource를 찾는가**가 중요하다는 것을 이해하게 되었다.

따라서 이제 다음 두 코드를 서로 다른 관점에서 설명할 수 있게 되었다.

```swift
Image("Fish")
```

```text
"Fish"라는 image resource를 기본적으로 main Bundle에서 찾는다.
```

반면:

```swift
Image("Fish", bundle: .module)
```

```text
FishFeature Module 내부에서, "Fish"라는 image resource를 해당 Module의 Resource Bundle에서 찾는다.
```

결국 이번 탐구를 통해 Asset을 단순히 Xcode에 넣어 사용하는 파일로 보는 것에서 벗어나 다음과 같은 흐름으로 바라볼 수 있게 되었다.

```text
Resource의 Source
      ↓
어느 Target에 속하는가
      ↓
Build에서 어떻게 처리되는가
      ↓
어느 Bundle을 통해 접근하는가
      ↓
Runtime에서 어느 Bundle을 검색하는가
```

---

## 9. Discussions / Opening Questions

- `Assets.car` 내부에는 Asset이 구체적으로 어떤 형태로 저장될까?
- Dark Mode나 `@2x`, `@3x` 같은 variation은 Runtime에서 어떻게 선택될까?
- 일반 파일 Resource와 Asset Catalog의 Build 과정은 어떻게 다를까?
- `Bundle.module` accessor는 실제로 언제, 어떻게 생성될까?
- Swift Package의 Asset Catalog Build 결과는 App Target의 Asset Catalog와 어떤 차이가 있을까?
- Target, Module, Product는 서로 어떤 관계를 가지고 있을까?

---

## 10. Research Process

```text
Image("Fish")는 어떻게 동작하지?
        ↓
Assets.xcassets는 무엇이지?
        ↓
Asset Set은 무엇이지?
        ↓
Contents.json은 왜 있지?
        ↓
Build하면 원본 구조가 그대로 남을까?
        ↓
Assets.car는 무엇이지?
        ↓
.app은 실행 파일인가?
        ↓
Application Bundle은 무엇이지?
        ↓
Image("Fish")는 어디에서 Fish를 찾지?
        ↓
main Bundle
        ↓

──────── Research Cycle 1 완료 ────────

        ↓

그런데 Fish가 Package에 있다면?
        ↓
Target은 무엇이지?
        ↓
Resource가 Target에 속한다는 것은?
        ↓
Package.swift에서 Resource를 어떻게 처리하지?
        ↓
.process / .copy
        ↓
처리된 Resource는 어디에 있지?
        ↓
Resource Bundle
        ↓
그 Bundle에 어떻게 접근하지?
        ↓
Bundle.module

──────── Research Cycle 2 완료 ────────
```

처음에는 각각 독립적으로 보였던 `Asset Catalog`, `actool`, `Assets.car`, `Bundle`, `Target`, `Resource`, `Bundle.module`을 최종적으로 하나의 Resource 흐름 안에서 연결할 수 있게 되었다.

---

## 참고 자료

- [Apple Developer Documentation — Asset management](https://developer.apple.com/documentation/xcode/asset-management): Xcode에서 이미지, 색상, 아이콘 등의 Asset을 관리하는 전반적인 개념과 Asset 관련 공식 문서를 제공합니다.
- [Apple Developer Documentation — Managing assets with asset catalogs](https://developer.apple.com/documentation/xcode/managing-assets-with-asset-catalogs): Asset Catalog를 사용해 Resource와 기기 특성에 따른 variation을 구성하고 관리하는 방법을 설명합니다.
- [Apple Developer Documentation — Xcode command-line tool reference](https://developer.apple.com/documentation/xcode/xcode-command-line-tool-reference): Xcode의 command-line build tools를 설명하며, Asset Catalog를 compile하고 verify하는 `actool`을 확인하는 데 사용했습니다.
- [Apple Developer Documentation — Bundle](https://developer.apple.com/documentation/foundation/bundle): Bundle directory에 저장된 code와 resource를 나타내는 Foundation의 `Bundle` 타입과 Resource 접근 방법을 설명합니다.
- [Apple Developer Documentation — Bundle.main](https://developer.apple.com/documentation/foundation/bundle/main): 현재 executable을 포함하는 main Bundle에 접근하는 `Bundle.main`을 설명합니다.
- [Apple Developer Documentation — Image.init(_:bundle:)](https://developer.apple.com/documentation/swiftui/image/init(_:bundle:)): 이름으로 image resource를 lookup할 때 검색할 Bundle을 지정하는 방법을 설명합니다. `bundle`이 `nil`이면 SwiftUI가 main Bundle을 사용한다는 것을 확인하는 데 사용했습니다.
- [Apple Developer Documentation — PackageDescription](https://developer.apple.com/documentation/packagedescription): Swift Package Manifest에서 Package, Product, Target, Dependency, Resource 등을 구성하는 API를 제공합니다.
- [Apple Developer Documentation — Target](https://developer.apple.com/documentation/packagedescription/target): Swift Package의 `Target`과 Source File, Dependency, Resource 관련 Manifest API를 설명합니다.
- [Apple Developer Documentation — Bundling resources with a Swift package](https://developer.apple.com/documentation/xcode/bundling-resources-with-a-swift-package): Swift Package에서 Resource를 Target에 scope하고 Package의 Resource Bundle에 접근하는 방법을 설명합니다.
- [Apple Developer Documentation — Resource.process(_:localization:)](https://developer.apple.com/documentation/packagedescription/resource/process(_:localization:)): Swift Package Resource에 Build 과정의 처리를 적용하도록 지정하는 `.process()` 규칙을 설명합니다.
- [Apple Developer Documentation — Resource.copy(_:)](https://developer.apple.com/documentation/packagedescription/resource/copy(_:)): Swift Package Resource를 원본 형태로 복사하는 `.copy()` 규칙을 설명합니다.
