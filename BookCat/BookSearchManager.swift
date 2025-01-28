import Foundation

enum CalculationError: Error {
    case noBook
}

enum GPTError: Error {
    case invalidResponse
    case noKeys
}

class EnhancedBookSearchManager {
    private let titleStrategy: CalculationStrategy
    private let authorStrategy: CalculationStrategy
    
    private let weights: [Double]
    private let initialSearchCount: Int
    private let threshold: [Double]
    private let maxRetries: Int
    
    // 가중치를 주입하는 방식으로 initializer 설계하여, 테스트 간 가중치 조정 가능토록
    init (
        titleStrategy: CalculationStrategy,
        authorStrategy: CalculationStrategy,
        weights: [Double],
        initialSearchCount: Int,
        threshold:[Double],
        maxRetries: Int
    ) {
        self.titleStrategy = titleStrategy
        self.authorStrategy = authorStrategy
        
        self.weights = weights
        self.initialSearchCount = initialSearchCount
        self.threshold = threshold
        self.maxRetries = maxRetries
    }
    
    func recommendBookFor(question: String, ownedBook: [String]) async throws -> (results:[BookItem],retryCount:Int){
        let (recommendedOwnedBookIds,recommendations) = try await getBookRecommendation(question: question, ownedBooks: ownedBook)
        
        var validUnownedBooks = [BookItem]()
        var overAllRetryCount = 0
        // 한 질문에 대해 2개 이상의 책이 반환되는 상황을 막으려면, 질문에 대한 전체 컨텍스트에서 관리되고 공유되어야 하는 기존 책 배열이 있어야함.
        var previousBooks = recommendations // [RawBook]
        /// 각 책마다 재시도 횟수 3회, 기존 비교대상 서적 배열을 갖습니다.
        for book in recommendations {
            var retryCount = 0
            var currentBook = book
            // previousBooks를 통해 전혀 다른 제목의 책을 추천받아 나온 연관 검색결과들이 저장되는 배열이기 때문에, 매 책마다 리셋되어 관리되어도 괜찮음.
            var candidates = [(BookItem,[Double])]()
            
            do {
                while retryCount <= maxRetries { /// 재시도 횟수가 3회이하일 경우, matchToRealBook에서 유효한 결과를 받지 못한 상황에서
                    if retryCount == maxRetries {
                        candidates.sort(by: {
                            $0.1.enumerated().reduce(0.0){ result, item in
                                result + item.element*weights[item.offset]
                            } > $1.1.enumerated().reduce(0.0){ result, item in
                                result + item.element*weights[item.offset]
                            }
                        })
                        
                        validUnownedBooks.append(candidates.first!.0)
                    }
                    
                    let (isMatching,matchedBook,similarities) = try await matchToRealBook(from: currentBook)
                    
                    previousBooks.append(currentBook)
                    
                    if isMatching, let matchedBook {
                        validUnownedBooks.append((matchedBook))
                        break
                    } else if !isMatching, let matchedBook {
                        candidates.append((matchedBook,similarities))
                        
                        currentBook = try await getAdditionalBookFromGPT(for: question, from: previousBooks) // RawBook
                        retryCount+=1
                    }
                }
                
                overAllRetryCount+=retryCount
            } catch {
                print("Error during book matching: \(error)")
                continue
            }
        }
        
        return (results:Array(Set(validUnownedBooks)),retryCount:overAllRetryCount)
    }
    
    /// 유사도가 가장 높은 최종 책 데이터를 반환하며, 반환도중 존재하지 않는 책임을 감지하면 nil을 반환합니다.
    private func matchToRealBook(from sourceBook: RawBook) async throws -> (isMatching: Bool, book: BookItem?, similarities: [Double]) {
        /// 각 책을 유사도와 매핑시켜 저장하기 위한 튜플 배열을 생성합니다.
        var results = [(index:Int,value:[Double])]()
        
        /// 여기서 0개 searchedResult 나오면 존재하지 않는 책이라 판단 -> 1차 필터링 수행
        guard let searchedResults = try await getSearchResults(from: sourceBook) else {
            return (isMatching:false, book:nil, similarities:[0.0,0.0,0.0])
        }
        
        /// 각 책마다 누적 유사도 값을 계산하고 배열에 id값과 함께 저장합니다.
        for (index, searchedBook) in searchedResults.enumerated() {
            let similarities = calculateOverAllSimilarity(for: searchedBook, from: sourceBook)
            results.append((index:index, value: similarities))
        }
        
        /// 가장 유사도가 높은 책 검출 위해 sort 실행
        // TODO: 우선순위 큐로 변경하기
        results.sort(by: {
            $0.1.enumerated().reduce(0.0){ result, item in
                result + item.element*weights[item.offset]
            } > $1.1.enumerated().reduce(0.0){ result, item in
                result + item.element*weights[item.offset]
            }
        })
        
        let finalBook = searchedResults[results[0].index]
        let similarities = results[0].value
        
        if let result = results.first, result.value[0]>=threshold[0], result.value[1]>threshold[1] {
            return (
                isMatching: true,
                book: finalBook,
                similarities:similarities)
        } else {
            /// 유사도가 일정 기준을 넘기지 못할 경우, 존재하지 않는 책으로 판단 -> 2차 필터링 수행
            return (isMatching:false,
                    book:finalBook,
                    similarities:similarities)
        }
    }
    
    private func getSearchResults(from sourceBook: RawBook) async throws -> [BookItem]? {
        var searchedResults: [BookItem] = []
        /// 제목으로 네이버 책 api에 검색하여 나온 상위 책 10개를 반환받습니다.
        async let searchByTitle = fetchSearchResults(sourceBook.title)
        async let searchByAuthor = fetchSearchResults(sourceBook.author)
        
        let (searchByTitleResult, searchByAuthorResult) = try await (searchByTitle,searchByAuthor)
        
        searchedResults.append(contentsOf: searchByTitleResult)
        searchedResults.append(contentsOf: searchByAuthorResult)
        
        let subTitleDivider = [":","|","-"]
        
        if searchedResults.isEmpty {
            /// 제목 내부에 부제 이전에 오는 특수문자 존재할 경우
            if !subTitleDivider.filter({ sourceBook.title.contains($0) }).isEmpty {
                if let divider = subTitleDivider.first(where: { sourceBook.title.contains($0) }),
                   let title = sourceBook.title.split(separator: divider).first {
                    searchedResults = try await fetchSearchResults(String(title))
                }
            } else {
                /// 아니면 그냥 존재하지 않는 값으로 간주하고 nil 반환 -> matchToRealBook 1차 guard let 필터링에 걸러짐
                return nil
            }
        }
        
        return searchedResults
    }
    
    private func calculateOverAllSimilarity(for searchedBook: BookItem, from targetBook: RawBook) -> [Double] {
        let values = [
            titleStrategy.calculateSimilarity(searchedBook.title, targetBook.title),
            authorStrategy.calculateSimilarity(searchedBook.author, targetBook.author),
        ]
        
        return values
    }
    
    private func getAdditionalBookFromGPT(for question:String, from previousResults: [RawBook]) async throws -> RawBook {
        guard let system = loadEnv()?["ADDITIONAL_PROMPT"], let openAIApiKey = loadEnv()?["OPENAI_API_KEY"] else {
            print("Prompt is missing")
            throw GPTError.noKeys
        }
        
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            throw GPTError.noKeys
        }
        
        let previewBookTitles = previousResults.map{$0.title}
        let prompt = "질문: \(question)\n기존 도서 제목 배열: \(previewBookTitles)"
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                ["role": "system", "content": system],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.01,
            "max_tokens": 500
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(openAIApiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            let (data, _) = try await URLSession.shared.data(for: request)
            
            let response = try JSONDecoder().decode(ChatGPTResponse.self, from: data)
            
            if let result = response.choices.first?.message.content {
                let arr = result.split(separator: "-").map { String($0) }
                return RawBook(title: arr[0], author: arr[1], publisher: arr[2])
            } else {
                throw GPTError.invalidResponse
            }
        } catch {
            print("GPT Error :\(error)")
            throw GPTError.invalidResponse
        }
    }
    
    /// - Parameter ownedBooks: 로컬저장소에 저장된 책의 id 값 배열
    /// - Parameter question: GPT에게 전달할 책추천에 대한 질문
    /// - Returns:[[선택된 보유도서 id값], [(미보유 도서 제목, 미보유 도서 저자, 미보유 도서 출판사)]
    private func getBookRecommendation(question:String,ownedBooks: [String]) async throws -> (recommendationFromOwned:[String],recommendationFromUnowned:[RawBook]) {
        guard let system = loadEnv()?["PROMPT"], let openAIApiKey = loadEnv()?["OPENAI_API_KEY"] else {
            print("Prompt is missing")
            throw GPTError.noKeys
        }
        
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            throw GPTError.noKeys
        }
        
        // TODO: 로컬 저장소 접근해 실제 제목 전달
        let tempOwnedBooks = ["이기적 유전자","클린 아키텍처"]
        let prompt = "질문: \(question)\n보유도서: \(tempOwnedBooks)"
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                ["role": "system", "content": system],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.01,
            "max_tokens": 500
        ]
        
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
                
                let ownedBooks = bookRecommendation.ownedBooks.map {
                    // TODO: 로컬저장소 중에 $0과 일치하는 이름의 id값 찾아서 return
                    return $0
                }
                
                let newBooks = bookRecommendation.newBooks.map {
                    let arr = $0.split(separator: "-").map { String($0) }
                    return RawBook(title: arr[0], author: arr[1], publisher: arr[2])
                }
                
                return (
                    recommendationFromOwned:ownedBooks,
                    recommendationFromUnowned:newBooks
                )
            } else {
                throw GPTError.invalidResponse
            }
        } catch {
            print("GPT Error :\(error)")
            throw GPTError.invalidResponse
        }
    }
    
    private func fetchSearchResults(_ query: String) async throws -> [BookItem] {
        let queryString = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://openapi.naver.com/v1/search/book.json?query=\(queryString)&display=\(initialSearchCount)&start=1"
        
        guard !query.isEmpty else { return [] }
        
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
        
        let (data,_) = try await URLSession.shared.data(for: request)
        
        do {
            let response = try JSONDecoder().decode(BookResponse.self, from: data)
            return response.items
        } catch {
            print("Decode error:", error)
            throw error
        }
    }
}
