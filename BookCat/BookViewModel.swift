import Foundation
import Combine

class BookViewModel: ObservableObject {
    @Published var newBooks: [String] = []
    @Published var question: String = "인류의 발전사에 대해 알고 싶어"
    @Published var ownedBooks: [String] = ["클린 아키텍처", "이기적 유전자"]
    
    @Published var recommendationFromOwned: [RawBook] = []
    @Published var recommendationFromUnowned: [RawBook] = []
    @Published var recommendationReason: String = ""
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published var ownedBookDetails: [BookItem] = []
    @Published var unownedBookDetails: [BookItem] = []
    @Published var searchingBooks = false
    
    // MARK: - ChatGPT API Call
    @MainActor
    func getBookRecommendation() async {
        isLoading = true
        recommendationReason = ""
        
        let prompt = """
            질문: \(question)
            보유도서: \(ownedBooks)
            """
        
        let system = """
              당신은 전문 북큐레이터입니다. 다음 지침에 따라 질문에 제일 적합한 책들을 추천해주세요:

              1. 입/출력 형식
              입력: 
              - 사용자 질문 (문자열)
              - 보유도서 목록 (배열)

              출력: 다음 구조의 JSON
              {
                "ownedBooks": ["도서명-저자명-출판사"],  // 보유도서 중 0-3권
                "newBooks": ["도서명-저자명-출판사"],    // 신규추천 0-3권
                "recommendation_reason": "추천 이유"
              }

              2. 도서 선정 기준
              각 분야별 우선순위:
              - 자기계발: 구체적 방법론 제시 도서
              - 심리/감정: 자격있는 전문가 저술
              - 학문: 검증된 입문서/개론서

              3. 도서 정보 표기
              필수 규칙:
              - 정확한 도서명-저자명-출판사 형식 준수
              - json과 마크다운 구문 제거
              - 영어 원서 제외
              - 절판/품절 도서 제외

              4. 검증 단계
              응답 전 확인사항:
              - 도서명/저자명/출판사명 정확성
              - 추천 도서 발행일 (5년 이내 우선)
              - json과 마크다운 구문 제거 여부
              - 저자 전문성 검증 여부
            """
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                ["role": "system", "content": system],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7,
            "max_tokens": 500
        ]
        
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            errorMessage = "Invalid ChatGPT API URL"
            isLoading = false
            return
        }
        
        guard let openAIApiKey = loadEnv()?["OPENAI_API_KEY"] else {
            print("OpenAi API Key is missing")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(openAIApiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            let (data, _) = try await URLSession.shared.data(for: request)
            
            let response = try JSONDecoder().decode(ChatGPTResponse.self, from: data)
            
            if let jsonString = response.choices.first?.message.content,
               let jsonData = jsonString.data(using: .utf8) {
                let bookRecommendation = try JSONDecoder().decode(ChatGPTRecommendation.self, from: jsonData)
                
                recommendationFromUnowned = bookRecommendation.newBooks.map {
                    let arr = $0.split(separator: "-").map { String($0) }
                    return RawBook(title: arr[0], author: arr[1], publisher: arr[2])
                }
                
                recommendationFromOwned = bookRecommendation.ownedBooks.map {
                    let arr = $0.split(separator: "-").map { String($0) }
                    return RawBook(title: arr[0], author: arr[1], publisher: arr[2])
                }
                
                recommendationReason = bookRecommendation.recommendation_reason
                await fetchBookDetails()
            }
        } catch {
            print(error)
            errorMessage = error.localizedDescription
        }
    }
    
    func searchBook(for query: String) async throws -> BookItem? {
        let urlString = "https://openapi.naver.com/v1/search/book.json?query=\(query)&display=20&start=1"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        guard let clientId = loadEnv()?["NAVER_CLIENT_ID"], let clientSecret = loadEnv()?["NAVER_CLIENT_SECRET"] else {
            print("missing data for Naver API init")
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.addValue(clientId, forHTTPHeaderField: "X-Naver-Client-Id")
        request.addValue(clientSecret, forHTTPHeaderField: "X-Naver-Client-Secret")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(BookResponse.self, from: data)
        return response.items.first
    }
    
    @MainActor
    private func fetchBookDetails() async {
        searchingBooks = true
        ownedBookDetails.removeAll()
        unownedBookDetails.removeAll()
        
        async let ownedSearchResults = withThrowingTaskGroup(of: BookItem?.self) { group in
            var results: [BookItem] = []
            
            for book in recommendationFromOwned {
                group.addTask {
                    try await self.searchBook(for: book.title)
                }
            }
            
            for try await result in group {
                if let item = result {
                    results.append(item)
                }
            }
            return results
        }
        
        async let unownedSearchResults = withThrowingTaskGroup(of: BookItem?.self) { group in
            var results: [BookItem] = []
            
            for book in recommendationFromUnowned {
                group.addTask {
                    try await self.searchBook(for: book.title)
                }
            }
            
            for try await result in group {
                if let item = result {
                    results.append(item)
                }
            }
            return results
        }
        
        do {
            let (owned, unowned) = try await (ownedSearchResults, unownedSearchResults)
            ownedBookDetails = owned
            unownedBookDetails = unowned
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
