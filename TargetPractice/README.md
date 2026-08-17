# ShoppingExample

Swift Package의 Target을 설명하기 위한 쇼핑앱 예제입니다.

## Target 구성

| Target | 역할 |
| --- | --- |
| `ShoppingModels` | 상품, 카테고리처럼 여러 기능에서 함께 쓰는 데이터 모델 target |
| `ShoppingCart` | 상품 담기, 수량 변경, 소계 계산을 담당하는 장바구니 target |
| `ShoppingCheckout` | 할인, 배송비, 최종 결제 금액 계산을 담당하는 결제 target |
| `ShoppingApp` | 위 기능 target들을 조립해서 실행하는 executable target |
| `ShoppingCartTests` | 장바구니 target만 검증하는 test target |
| `ShoppingCheckoutTests` | 결제 target만 검증하는 test target |

## 실행

```bash
swift run ShoppingApp
```

## 테스트

```bash
swift test
```
