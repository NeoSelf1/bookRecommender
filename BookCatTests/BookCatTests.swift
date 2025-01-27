import XCTest
@testable import BookCat

class BookSearchManagerTests: XCTestCase {
    var sut: EnhancedBookSearchManager!
    var viewModel: BookViewModel!
    let questions = [
        "심리학 입문서 추천해주세요",
        "경영/리더십 도서 중 베스트셀러는?",
        "SF 소설 중 우주를 배경으로 한 작품 있나요?",
        
        "프로그래밍 초보자가 읽기 좋은 파이썬 책은?",
        "고등학생이 이해하기 쉬운 철학책 추천해주세요",
        "영어 중급자에게 적합한 원서 추천해주세요",
        
        "우울할 때 읽으면 좋은 책 알려주세요",
        "면접 준비하는데 도움될 만한 책은?",
        "주말에 하루 만에 읽을 수 있는 가벼운 책 추천해주세요",
        
//        "최근 한 달간 가장 많이 팔린 책은?",
//        "신간 중에서 추천할 만한 책이 있나요?",
//        "이 분야의 고전/필독서는 뭐가 있나요?"
    ]
    
    let testCasesNew = [("심리학 입문서 추천해주세요", "심리학의 모든 것", "박지영", "더퀘스트"), ("심리학 입문서 추천해주세요", "심리학 콘서트", "노명우", "북라이프"), ("심리학 입문서 추천해주세요", "이상한 나라의 심리학", "김환", "알에이치코리아"), ("경영/리더십 도서 중 베스트셀러는?", "하버드 비즈니스 리뷰: 리더십", "하버드 비즈니스 리뷰 편집부", "한국경제신문"), ("경영/리더십 도서 중 베스트셀러는?", "초예측, 부의 미래", "최윤식", "지식노마드"), ("경영/리더십 도서 중 베스트셀러는?", "리더십의 새로운 패러다임", "존 P. 코터", "세종서적"), ("SF 소설 중 우주를 배경으로 한 작품 있나요?", "삼체", "류츠신", "단숨"), ("SF 소설 중 우주를 배경으로 한 작품 있나요?", "프로젝트 헤일메리", "앤디 위어", "알에이치코리아"), ("SF 소설 중 우주를 배경으로 한 작품 있나요?", "다크 포레스트", "류츠신", "단숨"), ("프로그래밍 초보자가 읽기 좋은 파이썬 책은?", "파이썬 for Beginner", "오윤석", "한빛미디어"), ("프로그래밍 초보자가 읽기 좋은 파이썬 책은?", "모두의 파이썬", "이승찬", "길벗"), ("프로그래밍 초보자가 읽기 좋은 파이썬 책은?", "Do it! 점프 투 파이썬", "박응용", "이지스퍼블리싱"), ("고등학생이 이해하기 쉬운 철학책 추천해주세요", "철학의 위안", "보에티우스", "현대지성"), ("고등학생이 이해하기 쉬운 철학책 추천해주세요", "철학 입문", "안광복", "사계절출판사"), ("고등학생이 이해하기 쉬운 철학책 추천해주세요", "철학의 역사", "나이젤 워버턴", "을유문화사"), ("우울할 때 읽으면 좋은 책 알려주세요", "죽음의 수용소에서", "빅터 프랭클", "청아출판사"), ("우울할 때 읽으면 좋은 책 알려주세요", "내 마음을 안아줄게", "정혜신", "창비"), ("우울할 때 읽으면 좋은 책 알려주세요", "감정은 어떻게 만들어지는가", "리사 펠드먼 배럿", "더퀘스트"), ("면접 준비하는데 도움될 만한 책은?", "면접의 기술", "김영종", "위즈덤하우스"), ("면접 준비하는데 도움될 만한 책은?", "취업 면접 바이블", "박선규", "한빛미디어"), ("면접 준비하는데 도움될 만한 책은?", "취업 성공을 위한 면접 전략", "서진영", "미래의창"), ("주말에 하루 만에 읽을 수 있는 가벼운 책 추천해주세요", "어서 오세요, 휴남동 서점입니다", "황보름", "클레이하우스"), ("주말에 하루 만에 읽을 수 있는 가벼운 책 추천해주세요", "죽음의 수용소에서", "빅터 프랭클", "청아출판사"), ("주말에 하루 만에 읽을 수 있는 가벼운 책 추천해주세요", "아몬드", "손원평", "창비")]
    
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
            titleStrategy: (LevenshteinStrategyWithNoParenthesis(), 1.0),
            authorStrategy: (LevenshteinStrategy(), 1.0),
            publisherStrategy: (LevenshteinStrategy(), 1.0),
            weights: [0.5, 0.4, 0.1],
            initialSearchCount: 10
        )
    }
    
    func accurancyTester(question: String, title:String, detail: String) async -> Int {
        let prompt = """
            질문: \(question)
            도서 제목: \(title)
            도서 상세정보: \(detail)
            """
        
        let system = """
              당신은 전문 북큐레이터입니다. 도서의 제목과 상세정보를 보고, 질문에 적합한 도서인지 여부를 0이나 1로 표현해주세요:
            
              1. 입/출력 형식
              입력: 
              - 질문 (문자열)
              - 도서 제목: (문자열)
              - 도서 상세정보: (문자열)
            
              출력: 0 또는 1
              - 0 : 상세정보에 대한 책이 질문에 대한 서적이 아님.
              - 1 : 상세정보에 대한 책이 질문에 적합함.
            
              2. 필수 규칙
              - 최근 한달 간 제일 많이 팔린 책과 같이 확인이 어려운 질문은 1로 반환
            """
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                ["role": "system", "content": system],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.01,
            "max_tokens": 100
        ]
        
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            return -1
        }
        
        guard let openAIApiKey = loadEnv()?["OPENAI_API_KEY"] else {
            print("OpenAi API Key is missing")
            return -1
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(openAIApiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            let (data, _) = try await URLSession.shared.data(for: request)
            
            let response = try JSONDecoder().decode(ChatGPTResponse.self, from: data)
            
            if let result = response.choices.first?.message.content, let resultInt = Int(result) {
                return resultInt
            } else {
                return -1
            }
        } catch {
            return -1
        }
    }
    
//    func testGainTestData() async throws {
//        var testData = [(String,String,String,String)]()
//        // MARK: - test 케이스 수집
//        for id in 0..<questions.count {
//            viewModel.question = questions[id]
//            await viewModel.getBookRecommendation()
//            viewModel.recommendationFromUnowned.forEach{
//                testData.append((questions[id],$0.title,$0.author,$0.publisher))
//            }
//        }
//        print(testData)
//    }
    
    
    func testOverAllAccurancy() async throws {
        var testData = [(String,String,String,String)]()
        // MARK: - test 케이스 수집
        for id in 0..<questions.count {
            viewModel.question = questions[id]
            await viewModel.getBookRecommendation()
            viewModel.recommendationFromUnowned.forEach{
                testData.append((questions[id],$0.title,$0.author,$0.publisher))
            }
        }
        
        sut = EnhancedBookSearchManager(
            titleStrategy: (LevenshteinStrategyWithNoParenthesis(), 1.0),
            authorStrategy: (LevenshteinStrategy(), 1.0),
            publisherStrategy: (LevenshteinStrategy(), 1.0),
            weights: [0.7, 0.3, 0.0],
            initialSearchCount: 10
        )
        
        var cnt = 0
        
        for (question,title,author,pulisher) in testData {
            try await Task.sleep(nanoseconds: 1_000_000_000 / 5) /// 책 검색 api 속도 제한 초과 방지
            let book = RawBook(title: title, author: author, publisher: pulisher)
            
            do {
                let _finalBook = try await sut.process(book)
                
                if let finalBook = _finalBook {
                    let isAccurate = await accurancyTester(
                        question: question,
                        title: finalBook.book.title,
                        detail: finalBook.book.description
                    )
                    
                    let debugDescription: String = """
                        질문에 적합한 책이 최종반환되지 않았습니다.
                        question: \(question)

                        책 유사도:
                        \(finalBook.similarities.map{String(format:"%.2f",$0)})

                        GPT가 제시한 제목-저자 -> 최종 검출된 책 제목-저자:
                        \(book.title)-\(book.author) -> \(finalBook.book.title)-\(finalBook.book.author)
                    """
                    
                    XCTAssertEqual(isAccurate, 1, debugDescription)
                    
                    if isAccurate == 1 {cnt+=1}
                } else {
                    print("failed for: \(book.title)-\(book.author)")
                }
                
            } catch {
                print("\(error) in \(book.title) \(book.author) \(book.publisher)")
            }
        }
        
        print("최종 정확도: \(Double(cnt)/Double(testData.count))")
    }
    
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
    
    func testAccurancy() async throws {
        sut = EnhancedBookSearchManager(
            titleStrategy: (LevenshteinStrategyWithNoParenthesis(), 1.0),
            authorStrategy: (LevenshteinStrategy(), 1.0),
            publisherStrategy: (LevenshteinStrategy(), 1.0),
            weights: [0.7, 0.3, 0.0],
            initialSearchCount: 10
        )
        
        var cnt = 0
        
        for (question,title,author,pulisher) in testCasesNew {
            try await Task.sleep(nanoseconds: 1_000_000_000 / 5) /// 책 검색 api 속도 제한 초과 방지
            let book = RawBook(title: title, author: author, publisher: pulisher)
            
            do {
                let _finalBook = try await sut.process(book)
                
                if let finalBook = _finalBook {
                    let isAccurate = await accurancyTester(
                        question: question,
                        title: finalBook.book.title,
                        detail: finalBook.book.description
                    )
                    
                    let debugDescription: String = """
                        질문에 적합한 책이 최종반환되지 않았습니다.
                        question: \(question)

                        책 유사도:
                        \(finalBook.similarities.map{String(format:"%.2f",$0)})

                        GPT가 제시한 제목-저자 -> 최종 검출된 책 제목-저자:
                        \(book.title)-\(book.author) -> \(finalBook.book.title)-\(finalBook.book.author)
                    """
                    
                    XCTAssertEqual(isAccurate, 1, debugDescription)
                    
                    if isAccurate == 1 {cnt+=1}
                } else {
                    print("failed for: \(book.title)-\(book.author)")
                }
                
            } catch {
                print("\(error) in \(book.title) \(book.author) \(book.publisher)")
            }
        }
        
        print("최종 정확도: \(Double(cnt)/Double(testCasesNew.count))")
    }
    
    //MARK: -
//    func testSearchResultAccurencyWithLavenStein() async throws {
//        sut = EnhancedBookSearchManager(
//            titleStrategies: [(LevenshteinStrategyWithNoParenthesis(), 1.0)],
//            authorStrategies: [(LevenshteinStrategy(), 1.0)],
//            publisherStrategies: [(LevenshteinStrategy(), 1.0)],
//            weights: [0.5, 0.4, 0.1],
//            initialSearchCount: 10
//        )
//        
//        for (title,author,pulisher) in teestCasesNew {
//            try await Task.sleep(nanoseconds: 1_000_000_000 / 5) /// 책 검색 api 속도 제한 초과 방지
//            
//            let book = RawBook(title: title, author: author, publisher: pulisher)
//            
//            do {
//                let result = try await sut.process(book)
//                if let result = result {
//                    print("\(result.similarities.map{String(format:"%.2f",$0)}) :\(book.title)-\(book.author) -> \(result.book.title)-\(result.book.author)")
//                } else {
//                    print("failed for: \(book.title)-\(book.author)")
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
