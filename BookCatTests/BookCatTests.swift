import XCTest
@testable import BookCat

struct TestResult {
    let weights: [Double]
    let thresholds: [Double]
    let searchCount: Int
    let maxRetries: Int
    let accuracy: Double
    let totalMatches: Int
    let totalRetries: [Int]
}

class BookSearchManagerTests: XCTestCase {
    var sut: EnhancedBookSearchManager!
    
        let weightOptions: [[Double]] = [[0.8, 0.2], [0.5, 0.5]]
    
        let thresholdOptions: [[Double]] = [[0.40, 0.80], [0.70, 0.80]]
    
        let searchCountOptions: [Int] = [10, 20]
        let maxRetriesOptions: [Int] = [5, 3]
    
    let questionsLegacy = [
        "심리학 입문서 추천해주세요",
        "경영/리더십 도서 중 베스트셀러는?",
        "SF 소설 중 우주를 배경으로 한 작품 있나요?",
        
        "프로그래밍 초보자가 읽기 좋은 파이썬 책은?",
        "고등학생이 이해하기 쉬운 철학책 추천해주세요",
        
        "우울할 때 읽으면 좋은 책 알려주세요",
        "면접 준비하는데 도움될 만한 책은?",
        "최근 한 달간 가장 많이 팔린 책은?",
    ]
    
    let questions = [
        "요즘 스트레스가 많은데, 마음의 안정을 찾을 수 있는 책 추천해주세요.",
        "SF와 판타지를 좋아하는데, 현실과 가상세계를 넘나드는 소설 없을까요?",
        "창업 준비 중인데 스타트업 성공사례를 다룬 책을 찾고 있어요.",
        
        "철학책을 처음 읽어보려고 하는데, 입문자가 읽기 좋은 책이 있을까요?",
        "퇴사 후 새로운 삶을 준비하는 중인데, 인생의 방향을 찾는데 도움이 될 만한 책 있나요?",
        "육아로 지친 마음을 위로받을 수 있는 책을 찾고 있어요.",
        "무라카미 하루키 스타일의 미스터리 소설 없을까요?",
        
        "'사피엔스'를 재미있게 읽었는데, 비슷한 책 추천해주세요.",
        "우울할 때 읽으면 좋은 따뜻한 책 추천해주세요.",
        "의욕이 없을 때 동기부여가 될 만한 책 없을까요?"
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
    }
    
    func accurancyTester(question: String, title:String) async -> Int {
        let prompt = """
            질문: \(question)
            도서 제목: \(title)
            """
        
        let system = """
              당신은 전문 북큐레이터입니다. 도서의 제목을 보고, 질문에 적합한 도서인지 여부를 0이나 1로 표현해주세요:
            
              1. 입/출력 형식
              입력: 
              - 질문 (문자열)
              - 도서 제목: (문자열)
            
              출력: 0 또는 1
              - 0 : 책 제목이 질문에 대한 서적이 아님.
              - 1 : 책 제목이 질문에 적합함.
            
              2. 필수 규칙
              - 최근 한달 간 제일 많이 팔린 책과 같이 확인이 어려운 질문은 1로 반환
            """
        
        let advancedSystem = """
              당신은 공감력이 뛰어난 전문 북큐레이터입니다. 도서의 제목과 상세정보를 보고, 질문에 적합한 도서인지 여부를 0이나 1로 표현해주세요:
            
              1. 입/출력 형식
              입력: 
              - 질문 (문자열)
              - 도서 제목: (문자열)
              - 도서 상세정보: (문자열)
            
              출력: 0 또는 1
              0: 책이 질문의 맥락이나 의도와 전혀 관련이 없는 경우에만 해당
              1: 다음 중 하나라도 해당되는 경우
              - 책이 질문과 직접적으로 관련된 경우
              - 책이 질문의 근본적인 감정이나 니즈를 간접적으로라도 충족시킬 수 있는 경우
              - 책이 질문자의 상황이나 심리상태에 위로나 통찰을 줄 수 있는 경우
              - 최근 판매량과 같이 객관적 확인이 어려운 질문의 경우
            
              2. 필수 규칙
              - 최근 한달 간 제일 많이 팔린 책과 같이 확인이 어려운 질문은 1로 반환
            """
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                ["role": "system", "content": advancedSystem],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.01,
            "max_tokens": 150
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
    
    func testOptimizeParameters() async throws {
        var results: [TestResult] = []
        
        for weights in weightOptions {
            for thresholds in thresholdOptions {
                for searchCount in searchCountOptions {
                    for maxRetries in maxRetriesOptions {
                        print("\nStarting test combination \(weights)-\(thresholds)-\(searchCount)-\(maxRetries)")
                        
                        do {
                            let (accuracy, totalMatches, retries) = try await runTest(
                                weights: weights,
                                thresholds: thresholds,
                                searchCount: searchCount,
                                maxRetries: maxRetries
                            )
                            
                            results.append(TestResult(
                                weights: weights,
                                thresholds: thresholds,
                                searchCount: searchCount,
                                maxRetries: maxRetries,
                                accuracy: accuracy,
                                totalMatches: totalMatches,
                                totalRetries: retries
                            ))
                            
                            print("""
                               Test completed:
                               - weights: \(weights)
                               - thresholds: \(thresholds)
                               - searchCount: \(searchCount)
                               - maxRetries: \(maxRetries)
                               - accuracy: \(accuracy)
                               - totalMatches: \(totalMatches)
                               - retryCounts: \(retries)
                               ----------------------
                               """)
                        } catch {
                            print("Error in combination \(weights)-\(thresholds)-\(searchCount)-\(maxRetries): \(error)")
                            // 선택적: 에러가 발생해도 다음 조합을 계속 테스트하고 싶다면 continue를 사용
                            continue
                        }
                        
                        // API 호출 간 딜레이 추가
                        try await Task.sleep(nanoseconds: 1_000_000_000)
                    }
                }
            }
        }
        
        // 결과 분석 및 최적 파라미터 도출
        let sortedResults = results.sorted { $0.accuracy > $1.accuracy }
        let bestResult = sortedResults[0]
        
        print("""
                최적 파라미터 조합:
                - weights: \(bestResult.weights)
                - thresholds: \(bestResult.thresholds)
                - searchCount: \(bestResult.searchCount)
                - maxRetries: \(bestResult.maxRetries)
                - 최종 정확도: \(bestResult.accuracy)
                - 총 매칭 수: \(bestResult.totalMatches)
                """)
    }
    
    private func runTest(
            weights: [Double],
            thresholds: [Double],
            searchCount: Int,
            maxRetries: Int
    ) async throws -> (accuracy: Double, totalMatches: Int, retries: [Int]) {
        sut = EnhancedBookSearchManager(
            titleStrategy: LevenshteinStrategyWithNoParenthesis(),
            authorStrategy: LevenshteinStrategy(),
            weights: weights,
            initialSearchCount: searchCount,
            threshold: thresholds,
            maxRetries: maxRetries
        )
        
        var cnt = 0
        var total = 0
        var retries = [Int]()
        for question in questions {
            do {
                try await Task.sleep(nanoseconds: 2_000_000_000)
                let (validBooks, retryCount) = try await sut.recommendBookFor(question: question, ownedBook: [])
                total += validBooks.count
                retries.append(retryCount)
                
                for book in validBooks {
                    let myBool = await accurancyTester(question: question, title: book.title)
                    if myBool == 1 { cnt += 1 }
                }
                print("question: \(question) proceeded")
            } catch {
                print("Error during test: \(error)")
            }
        }
        
        return (Double(cnt)/Double(total), total, retries)
    }
    
    //MARK: - Legacy
    func testOverAllAccurancyLegacy() async throws {
        sut = EnhancedBookSearchManager(
            titleStrategy: LevenshteinStrategyWithNoParenthesis(),
            authorStrategy: LevenshteinStrategy(),
            weights: [0.7, 0.3],
            initialSearchCount: 10,
            threshold: [0.42,0.80],
            maxRetries: 3
        )
        
        var cnt = 0
        var total = 0
        
        for question in questions {
            try await Task.sleep(nanoseconds: 1_000_000_000 / 5) /// 책 검색 api 속도 제한 초과 방지
            
            do {
                let (validBooks,retryCount) = try await sut.recommendBookFor(question: question,ownedBook:[])
                total+=validBooks.count
                
                for book in validBooks {
                    let myBool = await accurancyTester(question: question, title: book.title)
                    
                    let debugDescription: String = """
                        질문에 적합한 책이 최종반환되지 않았습니다.
                        question: \(question) -> \(book.title)-\(book.author)
                        재시도 횟수: \(retryCount)
                    """
                    
                    XCTAssertEqual(myBool, 1, debugDescription)
                    
                    if myBool == 1 {cnt+=1}
                }
            } catch {
                print(error)
            }
        }
        print("매칭된 케이스 개수: \(total)")
        print("최종 정확도: \(Double(cnt)/Double(total))")
    }
    
    func testGetAdditionalBookFromGPT() async {
        do {
            sut = EnhancedBookSearchManager(
                titleStrategy: LevenshteinStrategyWithNoParenthesis(),
                authorStrategy: LevenshteinStrategy(),
                weights: [0.7, 0.3],
                initialSearchCount: 10,
                threshold: [0.42,0.80],
                maxRetries: 3
            )
            
            let book = try await sut.getAdditionalBookFromGPT(
                for: "요리하는 데에 참고할 수 있는 책 추천해주세요",
                from: []
            )
            print(book)
        } catch {
            print(error)
        }
    }
}
