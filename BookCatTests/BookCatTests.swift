import XCTest
@testable import BookCat

class BookSearchManagerTests: XCTestCase {
    var sut: EnhancedBookSearchManager!
    var viewModel: BookViewModel!
    let questions = ["심리학 입문서 추천해주세요",
                     "경영/리더십 도서 중 베스트셀러는?",
                     "SF 소설 중 우주를 배경으로 한 작품 있나요?",
                     
                     "프로그래밍 초보자가 읽기 좋은 파이썬 책은?",
                     "고등학생이 이해하기 쉬운 철학책 추천해주세요",
                     "영어 중급자에게 적합한 원서 추천해주세요",
                     
                     "우울할 때 읽으면 좋은 책 알려주세요",
                     "면접 준비하는데 도움될 만한 책은?",
                     "주말에 하루 만에 읽을 수 있는 가벼운 책 추천해주세요",
                     
                     "최근 한 달간 가장 많이 팔린 책은?",
                     "신간 중에서 추천할 만한 책이 있나요?",
                     "이 분야의 고전/필독서는 뭐가 있나요?",]
    
    let teestCasesNew = [("심리학의 모든 것", "김민식", "심리출판사"), ("심리학 입문", "홍길동", "마음연구소"), ("심리학의 이해", "이서연", "지식나무"), ("초격차", "권오현", "쌤앤파커스"), ("리더의 길", "김경준", "올림"), ("팀장 리더십", "장동인", "한빛비즈"), ("우주전쟁", "허버트 조지 웰스", "황금가지"), ("어둠의 왼손", "어슐러 K. 르 귄", "황금가지"), ("유년기의 끝", "아서 C. 클라크", "황금가지"), ("파이썬 for Beginner", "박응용", "이지스퍼블리싱"), ("모두의 파이썬", "이승찬", "길벗"), ("점프 투 파이썬", "박응용", "이지스퍼블리싱"), ("철학의 위안", "보에티우스", "책세상"), ("철학 입문", "안광복", "생각의길"), ("세상에서 가장 쉬운 철학 입문", "이진경", "휴머니스트"), ("우울할 땐 뇌 과학", "앨릭스 코브", "심심"), ("하버드 행복 수업", "탈 벤 샤하르", "흐름출판"), ("감정은 어떻게 만들어지는가", "리사 펠드먼 배럿", "더퀘스트"), ("면접의 정석", "이형준", "이지퍼블리싱"), ("취업 면접의 기술", "윤종혁", "미래의창"), ("합격을 부르는 면접의 기술", "김훈", "리더북스"), ("죽음의 수용소에서", "빅터 프랭클", "청아출판사"), ("연금술사", "파울로 코엘료", "문학동네"), ("모모", "미하엘 엔데", "비룡소"), ("불편한 편의점", "김호연", "나무옆의자"), ("작별의 인사", "김영하", "문학동네"), ("달러구트 꿈 백화점", "이미예", "팩토리나인"), ("역행자", "자청", "웅진지식하우스"), ("불편한 편의점", "김호연", "나무옆의자"), ("트렌드 코리아 2024", "김난도", "미래의창"), ("역행자", "자청", "웅진지식하우스"), ("불편한 편의점", "김호연", "나무옆의자"), ("트렌드 코리아 2024", "김난도", "미래의창")]
    let testCases = [
        /// 심리학 도서
        ("심리학의 모든 것", "필립 짐바르도", "시그마프레스", true),
        ("심리학 입문", "데이비드 마이어스", "한울아카데미", true),
        
        /// 경영/리더십 도서
        ("초격차", "권오현", "쌤앤파커스", true),
        ("리더의 용기", "브레네 브라운", "갤리온", true),
        ("원씽","게리 켈러, 제이 파파산", "비즈니스북스",true),
        
        /// SF 소설
        ("삼체", "류츠신", "자음과모음", true),
        ("어린 왕자","앙투안 드 생텍쥐페리","문예출판사",true),
        ("설국열차: 빙하기의 끝", "자크 로브", "알에이치코리아", true),
        
        /// 프로그래밍 도서
        ("점프 투 파이썬", "박응용", "이지스퍼블리싱", true),
        ("파이썬 for Beginner","유인동","한빛미디어",true),
        ("모두의 파이썬", "이승찬", "길벗", true),
        
        /// 철학 도서
        ("소크라테스 익스프레스", "에릭 와이너", "어크로스", true),
        ("철학자와 늑대","마크 롤랜즈","추수밭",true),
        ("철학의 위안","알랭 드 보통","은행나무",true),
        
        /// 우울할 때 읽으면 좋은 책
        ("죽음의 수용소에서","빅터 프랭클","청아출판사",true),
        ("자기 앞의 생","에밀 아자르","열린책들",true),
        ("그럴 때 있으시죠?","정문정","위즈덤하우스",true),
        
        ("면접의 정석", "오수향", "리더스북", true),
        ("취업 면접 완전정복", "송진아", "시대고시기획", true),
        ("이기는 면접", "임태형", "21세기북스", true),
        
        ("아몬드", "손원평", "창비", true),
        ("하마터면 열심히 살 뻔했다", "하완", "웅진지식하우스", true),
        ("빨강 머리 앤", "루시 모드 몽고메리", "더모던", true),
        
        ("불편한 편의점 2", "김호연", "나무옆의자", true),
        ("작별인사", "김영하", "복복서가", true),
        ("역행자", "자청", "웅진지식하우스", true),
        
        
        ("물고기는 존재하지 않는다", "룰루 밀러", "곰출판", true),
        ("당신의 마음을 정리해드립니다", "정희정", "다산북스", true),
        
        /// 영어 원서
        ("The Great Gatsby", "F. Scott Fitzgerald", "Scribner", true),
        ("To Kill a Mockingbird","Harper Lee","Harper Perennial Modern Classics",true),
        ("1984","George Orwell","Signet Classics",true),
        
        /// Edge cases
        ("존재하지않는책", "가상의저자", "없는출판사", false),
        ("",  "", "", false),
        ("삼체   ", "류츠신", " ", true), // 왜?
        ("the great gatsby", "f. scott fitzgerald", "Scribner", true)
    ]
    
    
    override func setUp() {
        super.setUp()
        viewModel = BookViewModel()
        sut = EnhancedBookSearchManager(
            titleStrategies: [(ContainsStrategy(), 1.0)],
            authorStrategies: [(ContainsStrategy(), 1.0)],
            publisherStrategies: [(ContainsStrategy(), 1.0)],
            weights: [0.5, 0.4, 0.1],
            initialSearchCount: 10
        )
    }
    
    func testGainTestCaseData() async throws {
        var stackWithTuple = [(String,String,String)]()
        for id in 0..<questions.count {
            viewModel.question = questions[id]
            await viewModel.getBookRecommendation()
            viewModel.recommendationFromUnowned.forEach{
                stackWithTuple.append(($0.title,$0.author,$0.publisher))
            }
        }
        print(stackWithTuple)
    }
    //    func testBookSearch() async throws {
    //          // Given
    //          let sourceBook = RawBook(
    //              title: "클린 아키텍처",
    //              author: "로버트 C. 마틴",
    //              publisher: "인사이트"
    //          )
    //
    //          // When
    //          let result = try await sut.process(sourceBook)
    //
    //              // Then
    //          XCTAssertNotNil(result)
    //          XCTAssertEqual(result?.title, "클린 아키텍처")
    //          XCTAssertEqual(result?.author, "로버트 C. 마틴")
    ////          XCTAssertEqual(result?.publisher, "인사이트")
    //      }
    
    func testSearchResultNotNil() async throws {
        var cnt: Double = 0
        
        for (title,author,pulisher,shouldSucceed) in testCases {
            try await Task.sleep(nanoseconds: 1_000_000_000 / 15) /// 책 검색 api 속도 제한 초과 방지
            
            let book = RawBook(title: title, author: author, publisher: pulisher)
            
            do {
                let result = try await sut.process(book)
                cnt+=1
                XCTAssertEqual(result != nil, shouldSucceed, book.title)
            } catch {
                print("\(error) in \(book.title) \(book.author) \(book.publisher)")
            }
        }
        print("Accurancy: \(String(format: "%.2f", Double(cnt) / Double(testCases.count))) out of \(testCases.count)")
    }
    
    
    //MARK: -
    func testSearchResultAccurencyWithLavenStein() async throws {
        sut = EnhancedBookSearchManager(
            titleStrategies: [(LevenshteinStrategyWithNoParenthesis(), 1.0)],
            authorStrategies: [(LevenshteinStrategy(), 1.0)],
            publisherStrategies: [(LevenshteinStrategy(), 1.0)],
            weights: [0.5, 0.4, 0.1],
            initialSearchCount: 10
        )
        
        for (title,author,pulisher) in teestCasesNew {
            try await Task.sleep(nanoseconds: 1_000_000_000 / 5) /// 책 검색 api 속도 제한 초과 방지
            
            let book = RawBook(title: title, author: author, publisher: pulisher)
            
            do {
                let result = try await sut.process(book)
                if let result = result {
                    print("\(result.similarities.map{String(format:"%.2f",$0)}) :\(book.title)-\(book.author) -> \(result.book.title)-\(result.book.author)")
                } else {
                    print("failed for: \(book.title)-\(book.author)")
                }
            } catch {
                print("\(error) in \(book.title) \(book.author) \(book.publisher)")
            }
        }
    }
    
    
    
    
    
    
    //    func testSearchResultAccurency() async throws {
    //        var cnt: Double = 0
    //
    //        for (title,author,pulisher,shouldSucceed) in testCases {
    //            try await Task.sleep(nanoseconds: 1_000_000_000 / 15) /// 책 검색 api 속도 제한 초과 방지
    //
    //            let book = RawBook(title: title, author: author, publisher: pulisher)
    //
    //            do {
    //                let result = try await sut.process(book)
    //                if let result = result {
    //                    if book.title == result.title { cnt+=1 }
    //                    XCTAssertEqual(book.title, result.title)
    //                }
    //            } catch {
    //                print("\(error) in \(book.title) \(book.author) \(book.publisher)")
    //            }
    //        }
    //
    //        print("Accurancy: \(String(format: "%.2f", Double(cnt) / Double(testCases.count))) out of \(testCases.count)")
    //    }
    //
    //    func testSearchResultAccurencyBetweenTwo() async throws {
    //        sut = EnhancedBookSearchManager(
    //            titleStrategies: [(ExactMatchStrategy(), 1.0)],
    //            authorStrategies: [(ExactMatchStrategy(), 1.0)],
    //            publisherStrategies: [(ExactMatchStrategy(), 1.0)],
    //            weights: [0.5, 0.4, 0.1],
    //            initialSearchCount: 10
    //        )
    //        var mySet = Set<String>()
    //        for (title,author,pulisher,shouldSucceed) in testCases {
    //            try await Task.sleep(nanoseconds: 1_000_000_000 / 15) /// 책 검색 api 속도 제한 초과 방지
    //
    //            let book = RawBook(title: title, author: author, publisher: pulisher)
    //
    //            do {
    //                let result = try await sut.process(book)
    //                if let result = result, result.title != book.title {
    ////                    print("source: \(book.title) -> target: \(result.title)")
    //                    mySet.insert(book.title)
    //                }
    //            } catch {
    //                print("\(error) in \(book.title) \(book.author) \(book.publisher)")
    //            }
    //        }
    //
    //        sut = EnhancedBookSearchManager(
    //            titleStrategies: [(ContainsStrategy(), 1.0)],
    //            authorStrategies: [(ContainsStrategy(), 1.0)],
    //            publisherStrategies: [(ContainsStrategy(), 1.0)],
    //            weights: [0.5, 0.4, 0.1],
    //            initialSearchCount: 10
    //        )
    //
    //        for (title,author,pulisher,shouldSucceed) in testCases {
    //            try await Task.sleep(nanoseconds: 1_000_000_000 / 15) /// 책 검색 api 속도 제한 초과 방지
    //
    //            let book = RawBook(title: title, author: author, publisher: pulisher)
    //
    //            do {
    //                let result = try await sut.process(book)
    //                if let result = result, result.title != book.title, !mySet.contains(book.title) {
    //                    print("source: \(book.title) -> target: \(result.title)")
    //                }
    //            } catch {
    //                print("\(error) in \(book.title) \(book.author) \(book.publisher)")
    //            }
    //        }
    //    }
    
    func testNilReturnCases() async throws {
        let nilTestCases = [
            RawBook(title: "존재하지않는책", author: "가상의저자", publisher: "없는출판사"),
            RawBook(title: "", author: "", publisher: ""),
            
            // 특수문자만 포함
            RawBook(title: "!@#$%", author: "&*()", publisher: "^_^"),
            
            // 실제 책과 유사하지만 약간 다른 정보
            RawBook(title: "심리학의 모든것들", author: "필립 짐바르도씨", publisher: "시그마출판"),
            RawBook(title: "파이썬 점프", author: "응용박", publisher: "이지스"),
            
            // 공백이나 특수문자가 과도하게 포함
            RawBook(title: "   삼    체    ", author: "류   츠   신", publisher: "자음과...모음"),
            
            // 실제 저자-출판사 매칭이 잘못된 경우
            RawBook(title: "삼체", author: "김영하", publisher: "자음과모음"),
            RawBook(title: "초격차", author: "권오현", publisher: "웅진지식하우스")
        ]
        
        for book in nilTestCases {
            let result = try await sut.process(book)
            XCTAssertNil(result, "Should return nil for book: \(book.title)")
        }
    }
}
