import Foundation
import RxSwift


// MARK: - 기본적인 Observable 생성자

/*
 Observable 시퀀스는 `Observable` 키워드를 이용해 만들 수 있으며,
 `<>` 에 어떤 타입의 element를 방출할 것인지 정의할 수 있다.
 물론 타입을 적어주지 않고 타입추론을 이용할 수도 있다.
 
 Observable은 실제로는 그저 `시퀀스의 정의`일 뿐이다.
 즉, 구독 되기 전까지는 아무 이벤트도 방출하지 않는다.
 따라서 Observable이 제대로 동작하기 위해서는 반드시 `구독`이 이루어져야 한다.
 
Observable을 생성하는 기본적인 연산자는 `just`, `of`, `from` 가 있다.
*/

// `just` 연산자로 만든 Observable은 하나의 element만 방출할 수 있다.
print("---- Just ----")
Observable<Int>.just(1)
    .subscribe(onNext: {
        print($0)
    })

// `of` 연산자로 만든 Observable은 하나 이상의 element를 방출할 수 있다.
print("---- Of with Element ----")
Observable.of(1, 2, 3, 4, 5)
    .subscribe(onNext: {
        print($0)
    })

// `of` 에 하나의 Array를 넘기면 '하나의 Array'를 element로 방출하게 된다. (== just)
print("---- Of with Array ----")
Observable.of([1, 2, 3, 4, 5])
    .subscribe(onNext: {
        print($0)
    })

// `from` 은 Array만을 element로 받으며, `of`와 달리 Array내 요소를 하나하나 방출한다.
print("---- From ----")
Observable.from([1, 2, 3, 4, 5])
    .subscribe(onNext: {
        print($0)
    })


// MARK: - Subscribe (구독)

/*
 subscribe를 진행할 때 onNext가 있는 것과 없는 것의 결과는 다르다.
 onNext가 없으면 `event 자체`를 반환하고,
 onNext가 있으면 `event의 value`를 반환한다.
 
 따라서 onNext가 없이 반환되는 event는 `completed`와 `error`의 반환까지 확인할 수 있다.
 
 또한 optionalBinding을 이용하게 되면 onNext가 없어도 `event의 value`를 반환한다.
 */

print("---- Subscribe without onNext ----") /// `event`가 반환된다.
Observable.of(1, 2, 3)
    .subscribe {
        print($0)
    }

print("---- Subscribe with onNext ----") /// `event의 value`가 반환된다.
Observable.of(1, 2, 3)
    .subscribe(onNext: {
        print($0)
    })

print("---- Subscribe with optionalBinding ----") /// `event의 value`가 반환된다.
Observable.of(1, 2, 3)
    .subscribe {
        if let element = $0.element {
            print(element)
        }
    }


// MARK: - 추가적인 Observable 생성자

/*
 onNext의 개념을 이해한 뒤 일반적인 Observable 생성자에 조금 더 추가된 개념들을 살펴보자.
 해당 생성자로는 `empty`, `never`, `range` 가 있다.
 */

// `empty`는 요소를 하나도 가지지 않는 Observable을 생성할 때 사용하는 연산자로 아래 경우에 사용된다.
//      1. 즉시 종료할 수 있는 Observable을 생성하고 싶을 때
//      2. 의도적으로 0개의 값을 가지는 Observable을 생성하고 싶을 때
print("---- Empty ----")
Observable<Void>.empty()
    .subscribe {
        print($0)
    }

// `never`는 `empty` 처럼 요소를 하나도 가지지 않지만, 완료시 completed 이벤트조차 발생되지 않는다.
//  따라서 잘 동작중인지 확인하려면 `.debug()` 를 사용해야 한다.
print("---- Never ----")
Observable<Void>.never()
    .debug("never")
    .subscribe(
        onNext: {
            print($0)
        },
        onCompleted: {
            print("Completed")
        }
    )

// `range`는 start부터 count만큼의 값을 갖도록 Observable을 생성하는 생성자이다.
//  주로 특정 Array의 start부터 count만큼의 값을 갖도록 할 때 사용한다.
print("---- Range ----")
Observable.range(start: 1, count: 9)
    .subscribe(onNext: {
        print("2*\($0)=\(2 * $0)") /// 구구단 2단
    })


// MARK: - Dispose (구독 취소)

/*
 위에서 서술했듯이 Observable은 구독되기 전까지 `시퀀스의 정의`일 뿐이다.
 그러나 `Subscribe`가 시작되면 이벤트를 방출한다.
 
 이와 반대로 이벤트를 방출 중인 Observable을 다시 돌려놓는 방법도 있다.
 정확히는 이벤트 방출이 끝나 구독이 필요없을 때 구독을 취소해서 메모리 누수를 막는 것이다.
 그것이 `Dispose`의 개념이다.
 
 
 그러나 모든 Observable을 하나 하나 dispose로 구독취소하는 것은 효율적인 방식이 아니다.
 RxSwift는 이를 개선하기 위해 `disposeBag` 이라는 개념을 제공한다.
 
 여러 Observable을 구독할 때 각각을 공통된 `disposeBag`에 추가해 두면 `disposeBag`은 이들을 가지고 있다가,
 스스로가 할당해제 될 때, 가진 모든 구독에 대해서 `dispose`를 날린다.
 */

// `.dispose()` 를 통해 구독취소
print("---- Dispose ----")
Observable.of(1, 2, 3)
    .debug("Dispose")
    .subscribe(onNext: {
        print($0)
    })
    .dispose()

// `disposeBag` 을 이용해 구독 취소
print("---- DisposeBag ----")
let disposeBag = DisposeBag()

Observable.of(1, 2, 3)
    .debug("DisposeBag")
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)


// MARK: - 독특한 Observable 생성자

/*
 dispose의 개념을 이해한 뒤 독특한 Observable 생성자들을 살펴보자.
 해당 생성자로는 `create`, `deffered` 가 있다.
 
 `create`는 parameter에 `Observer`를 제네릭 타입으로 받고 `Disposable`을 반환한다.
 따라서 onNext, onCompleted 등을 조금 더 편하게 사용할 수 있도록 도와준다.
 
 `deffered`는 subscribe를 기다리는 Observable을 만드는 대신에
 각 subscribe에게 새로운 Observable을 제공하는 `Observable Factory`를 만들어주는 생성자이다.
 */

// onCompleted 이후의 onNext는 동작하지 않는다.
print("---- Create with onCompleted ----")
Observable.create { observer -> Disposable in
    observer.onNext(1) /// == observer.on(.next(1))
    observer.onCompleted() /// == observer.on(.completed)
    observer.onNext(2)
    
    return Disposables.create()
}
.subscribe {
    print($0)
}
.disposed(by: disposeBag)

// onError는 error단에서 Observable이 종료된다.
print("---- Create with onError ----")
enum MyError: Error {
    case anError
}
Observable.create { observer -> Disposable in
    observer.onNext(1)
    observer.onError(MyError.anError)
    observer.onNext(2)
    
    return Disposables.create()
}
.subscribe (
    onNext: { print($0) },
    onError: { print($0.localizedDescription) },
    onCompleted: { print("completed") },
    onDisposed: { print("disposed") }
)
.disposed(by: disposeBag)

// `deffered` 의 parameter는 `Observable Factory` 이므로
//   내부에서 Observable을 정의해준다.
print("---- Deffered ----")
Observable.deferred {
    Observable.of(1, 2, 3)
}
.subscribe {
    print($0)
}
.disposed(by: disposeBag)

// `deffered` 는 이럴때 사용한다..!
print("---- Deffered with Detail Example ----")
var isReversed: Bool = false

let factory: Observable<String> = Observable.deferred {
    isReversed = !isReversed
    
    if isReversed {
        return Observable.of("☝🏻")
    } else {
        return Observable.of("👇🏻")
    }
}

for _ in 0 ... 3 {
    factory.subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)
}
