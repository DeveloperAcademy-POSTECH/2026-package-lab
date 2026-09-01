# Asset Catalog Build & Runtime Resource Lookup
---
## 1. Why did I select this keyword?

SwiftUI에서 이미지를 사용할 때 나는 평소 다음과 같이 작성했다.

Swift

```
Image("Fish")
```

하지만 `"Fish"`라는 이름만으로 어떻게 이미지가 화면에 나타나는지, Xcode에 추가한 Asset이 Build 과정에서 어떻게 처리되는지는 정확히 설명하지 못했다.

특히 `Assets.xcassets`를 하나의 특수한 파일처럼 생각하고 있었고, Asset Catalog 내부의 이미지와 metadata가 Build 이후에도 그대로 존재하는지 알지 못했다.

> **"Xcode에 추가한 Asset은 어떤 과정을 거쳐 `Image("Fish")`로 찾아지는가?"**
> 

이번 탐구의 범위를 다음과 같이 설정했다.

```
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

**`Assets.xcassets`는 실제로 어떤 구조로 되어 있을까?**

처음에는 `.xcassets`를 하나의 파일이라고 생각했다. Finder에서 `Assets.xcassets`의 내부 구조를 직접 확인해보니 하나의 이미지 파일이 아니라 여러 Asset Set을 포함하는 구조라는 것을 확인할 수 있었다.

```
Assets.xcassets
└── Fish.imageset
    ├── fish.png
    └── Contents.json
```

`Fish.imageset`에는 실제 이미지와 `Contents.json`이 함께 존재했다. `Contents.json`을 살펴보면서 `filename`, `scale`, `idiom`, `appearance`처럼 이미지와 관련된 metadata가 관리된다는 것도 확인했다.

> **새로운 질문:** 그렇다면 이 구조는 앱을 Build한 이후에도 그대로 존재할까?
> 

### Guiding Question 2

**Asset Catalog는 Build 후에도 `.xcassets` 형태로 존재할까?**

처음에는 원본 Asset Catalog가 그대로 `.app`에 들어가지는 않을 것이라고 예상했다. 직접 프로젝트를 Build한 뒤 `.app`의 Package Contents를 확인했다.

Plaintext

```
AssetProject.app
├── AssetProject
├── Assets.car
├── Info.plist
└── ...
```

여기에서는 `Assets.xcassets`, `Fish.imageset`, `Contents.json`을 찾을 수 없었고 대신 `Assets.car`가 존재했다.

Apple의 Xcode command-line tool 문서를 조사하면서 `actool`이 Asset Catalog를 compile하는 도구라는 것을 확인했다. 따라서 다음과 같은 관계를 이해할 수 있었다.

```
Assets.xcassets
      ↓
Asset Catalog Compiler (actool)
      ↓
Compiled Asset Catalog
      ↓
Assets.car
```

> **새로운 질문:** Build된 `Assets.car`는 왜 `.app` 안에 존재하는 것일까?
> 

### Guiding Question 3

**.app은 단순한 실행 파일일까?**

Build Product를 관찰하면서 `.app` 안에는 실행 파일뿐만 아니라 `Assets.car`, `Info.plist` 등 여러 파일이 함께 존재한다는 것을 확인했다.

Plaintext

```
AssetProject.app
├── AssetProject      ← executable
├── Assets.car        ← resource
└── Info.plist        ← metadata
```

이를 Apple의 Bundle 문서와 연결하면서 `.app`을 하나의 **Application Bundle**로 이해하게 되었다.

즉 내가 처음 생각했던:

- `.app = 실행 파일`

이 아니라,

- `.app = Application Bundle = executable + resources + metadata + ...`

라는 구조로 mental model을 수정했다.

Foundation의 `Bundle`은 이러한 Bundle을 코드에서 나타내고 Resource 등에 접근할 수 있게 해주는 타입이고, `Bundle.main`은 현재 executable을 포함하는 main Bundle을 나타낸다는 것도 확인했다.

> **새로운 질문:** 그렇다면 `Image("Fish")`는 이 Bundle에서 어떻게 Fish를 찾을까?
> 

### Guiding Question 4

**`Image("Fish")`에서 "Fish"는 무엇이고 어디에서 찾는 것일까?**

SwiftUI의 `Image.init(_:bundle:)` 문서를 확인했다.

```
init(
    _ name: String,
    bundle: Bundle? = nil
)
```

처음에는 name과 bundle의 역할이 명확하게 구분되지 않았다. 문서를 읽으면서 두 parameter를 다음 질문으로 구분했다.

- **name** → 무엇을 찾는가?
- **bundle** → 어디에서 찾는가?

따라서 `Image("Fish")`에서 `"Fish"`는 찾고자 하는 image resource의 이름이고, `bundle`은 그 image resource를 어느 Bundle에서 검색할지를 지정한다고 이해했다.

또한 bundle의 기본값은 `nil`이며, Apple 문서에 따르면 이 경우 SwiftUI는 **main Bundle**을 사용한다.

따라서 현재 내가 이해한 것은:

```
Image("Fish")

"Fish"
→ 무엇을?
→ "Fish"라는 이름의 image resource

bundle = nil
→ 어디에서?
→ main Bundle
```
---
## 3. Main Contents

이번 탐구를 통해 내가 이해한 Asset의 전체 흐름은 다음과 같다.

Plaintext

```
[Source]
Assets.xcassets
└── Fish.imageset
    ├── image
    └── Contents.json
           │
           ▼
[Build]
Asset Catalog Compiler (actool)
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
## 4. Conclusion

탐구 전에는 Asset을 다음 정도로 이해하고 있었다.

Plaintext

```
Assets.xcassets
      ↓
Image("Fish")
      ↓
화면
```

결국 중간 과정은 모두 "Xcode가 알아서 처리한다"고 생각하고 있었다. 이번 탐구를 통해 이 사이에도 명확한 단계가 있다는 것을 알게 되었다.

```
Source → Build → Compiled Resource → Bundle → Runtime Lookup
```

특히 개발할 때 보는 `Fish.imageset`, `Contents.json` 등의 Source 구조가 Runtime까지 그대로 사용되는 것이 아니라, Build 과정에서 Asset Catalog가 처리되어 Build Product의 Resource로 포함된다는 점이 가장 크게 바뀐 mental model이다.

또한 `Image("Fish")`도 단순히 파일 이름을 전달하는 코드라고 생각하기보다, "어떤 이름의 image resource를 어느 Bundle에서 찾을 것인가"라는 관점으로 이해할 수 있게 되었다.
---
## 5. Discussions / Opening Questions

- `Assets.car` 내부에는 Asset이 구체적으로 어떤 형태로 저장될까?
- Dark Mode나 `@2x`, `@3x` 같은 variation은 Runtime에서 어떻게 선택될까?
- 일반 파일 Resource와 Asset Catalog의 Build 과정은 어떻게 다를까?
- Asset이 App Target이 아니라 Swift Package Target에 속한다면 무엇이 달라질까?
- Swift Package에서 `Bundle.module`은 왜 필요할까?
---
## 참고 자료
## 참고 자료

- [Apple Developer Documentation — Asset management](https://developer.apple.com/documentation/xcode/asset-management): Xcode에서 이미지, 색상, 아이콘 등의 Asset을 관리하고 Runtime에 로드하는 전반적인 개념과 Asset Catalog 관련 문서의 공식 목차를 제공합니다.
- [Apple Developer Documentation — Managing assets with asset catalogs](https://developer.apple.com/documentation/xcode/managing-assets-with-asset-catalogs): Asset Catalog를 사용해 이미지 등의 Resource와 기기 특성에 따른 variation을 구성하고 관리하는 방법을 설명합니다.
- [Apple Developer Documentation — Xcode command-line tool reference](https://developer.apple.com/documentation/xcode/command-line-tools): Xcode가 제공하는 command-line build tool들을 설명하며, Asset Catalog를 compile·verify하는 actool을 확인하는 데 사용했습니다.
- [Apple Developer Documentation — Bundle](https://developer.apple.com/documentation/foundation/bundle): 디스크의 Bundle directory에 저장된 code와 resource를 나타내는 Foundation의 Bundle 타입과 Bundle을 통한 Resource 접근 방식을 설명합니다.
- [Apple Developer Documentation — Bundle.main](https://developer.apple.com/documentation/foundation/bundle/1410786-main): 현재 실행 중인 executable을 포함하는 Bundle을 반환하는 Bundle.main을 설명합니다.
- [Apple Developer Documentation — Image.init(_:bundle:)](https://developer.apple.com/documentation/swiftui/image/init(_:bundle:)-85lcm): SwiftUI에서 이름으로 image resource를 lookup할 때 검색할 Bundle을 지정하는 방법을 설명합니다. bundle이 nil이면 main Bundle을 사용한다는 것을 확인할 수 있습니다.
- [Apple Developer Documentation — Image.init(systemName:)](https://developer.apple.com/documentation/swiftui/image/init(systemname:)): System Symbol과 Asset Catalog에 저장한 custom image resource의 차이를 확인하고, custom image에는 init(_:bundle:)을 사용한다는 점을 설명합니다.
