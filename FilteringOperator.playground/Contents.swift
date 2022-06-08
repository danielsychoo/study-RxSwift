import RxSwift


// MARK: - 사전작업

// dispose들을 담을 disposeBag
let disposeBag = DisposeBag()


// MARK: - Basic

// ignoreElements
// next를 무시, completed 만 받음
print("---- ignoreElements ----")
let sleepingMode = PublishSubject<String>()

sleepingMode
    .ignoreElements()
    .subscribe { _ in
        print("취침모드 종료")
    }
    .disposed(by: disposeBag)

sleepingMode.onNext("알람!!!")
sleepingMode.onNext("알람!!!")
sleepingMode.onNext("알람!!!")

sleepingMode.onCompleted()

// elementAt
// at에 해당하는 index의 next만 받음
print("---- elementAt ----")
let awakeAtSecondAlarm = PublishSubject<String>()

awakeAtSecondAlarm
    .element(at: 2)
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

awakeAtSecondAlarm.onNext("알람!!!")
awakeAtSecondAlarm.onNext("알람!!!")
awakeAtSecondAlarm.onNext("깸") /// index 2
awakeAtSecondAlarm.onNext("알람!!!")

// filter
// 기본적인 필터링
print("---- filter ----")
Observable.of(1, 2, 3, 4, 5, 6, 7, 8)
    .filter { $0 % 2 == 0 }
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

// enumerated
// index와 element로 분리
print("---- enumerated ----")
Observable.of("a", "b", "c", "d", "e")
    .enumerated()
    .take(while: { $0.index < 3 })
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)



// MARK: - Skip

// skip
// 첫 번째 요소부터 n개의 연산자를 스킵
print("---- skip ----")
Observable.of(1, 2, 3, 4, 5, 6, 7, 8)
    .skip(4)
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

// skipWhile
// 조건이 true인 동안 스킵
print("---- skipWhile ----")
Observable.of(1, 2, 3, 4, 5, 6, 7, 8)
    .skip(while: { $0 != 6 })
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

// skipUntil
// 다른 Observable의 next까지 skip
print("---- skipUntil ----")
let customer = PublishSubject<String>() /// 기준 Observable
let storeOpen = PublishSubject<String>() /// 다른 Observable

customer
    .skip(until: storeOpen)
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

customer.onNext("손님1")
customer.onNext("손님1")

storeOpen.onNext("오픈")
customer.onNext("손님3")


// MARK: - Take

// take
// 첫 번째부터 n개의 이벤트 (skip의 반대)
print("---- take ----")
Observable.of("a", "b", "c", "d", "e")
    .take(2)
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

// takeWhile
// 조건이 true인 동안 take (skipWhile의 반대)
print("---- takeWhile ----")
Observable.of(1, 2, 3, 4, 5, 6, 7, 8)
    .take(while: { $0 != 4 })
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

// takeUntil
// 다른 Observable의 next까지 take (skipUntil의 반대)
print("---- takeUntil ----")
let child = PublishSubject<String>() /// 기준 Observable
let angryMom = PublishSubject<String>() /// 다른 Observable

child
    .take(until: angryMom)
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

child.onNext("사탕1 먹음")
child.onNext("사탕2 먹음")

angryMom.onNext("그만머거!!")
child.onNext("사탕3 먹음")


// MARK: - distinct

// distinctUntilChanged
// `연속된` 중복된 것 무시
print("---- distinctUntilChanged ----")
Observable.of(1, 1, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 4, 1, 1, 5, 5, 5, 5, 5)
    .distinctUntilChanged()
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

