import Foundation

enum CalculationError: Error {
    case invalid
    case noBook
}

/// 테스트 간에 전략 구현 내용 및 스위칭이 유연하게 적용될 수 있어야 함. 미리 프로토콜로 분리
protocol CalculationStrategy {
    func calculateSimilarity(_ source: String, _ target: String) -> Double
}

/// 정확히 한글자도 빠짐없이 동일할 경우 1을 반환합니다
struct ExactMatchStrategy: CalculationStrategy {
    func calculateSimilarity(_ source: String, _ target: String) -> Double {
        return source == target ? 1.0 : 0.0
    }
}

/// 제목중에 Source 단어가 포함되어있을 경우 1을 반환합니다.
/// 클린아키텍처
struct ContainsStrategy: CalculationStrategy {
    func calculateSimilarity(_ source: String, _ target: String) -> Double {
        return target.contains(source) || source.contains(target) ? 1.0 : 0.0
    }
}

/// 띄어쓰기 불일치 엣지케이스 대응: 띄어쓰기 모두 제거한 후, 띄어쓰기 모두 제거해서 확인
struct ExactMatchWithNoSpaceStrategy: CalculationStrategy {
    func calculateSimilarity(_ source: String, _ target: String) -> Double {
        let targetWithNoSpace = target.replacingOccurrences(of: " ", with: "")
        let sourceWithNoSpace = source.replacingOccurrences(of: " ", with: "")
        return targetWithNoSpace == sourceWithNoSpace ? 1.0 : 0.0
    }
}

/// 부제 포함된 엣지케이스 대응: 부제와 제목을 나눌수 있는 특수문자를 제거하고, 두 단어가 모두
struct SplitMatchWithNoSpaceStrategy: CalculationStrategy {
    func calculateSimilarity(_ source: String, _ target: String) -> Double {
        let strArr = [":","|","-"]
        /// 검색결과 제목에 부제,제목 구분 역할의 특수문자가 있다고 판단될 경우
        if !strArr.filter{ source.contains($0) }.isEmpty {
            return 0.5
        } else {
            let targetWithNoSpace = target.replacingOccurrences(of: " ", with: "")
            let sourceWithNoSpace = source.replacingOccurrences(of: " ", with: "")
            return targetWithNoSpace == sourceWithNoSpace ? 1.0 : 0.0
        }
    }
}

// MARK: -
struct LevenshteinStrategy: CalculationStrategy {
    /// - Parameter source: 네이버 책검색 api DB 데이터
    /// - Parameter target: GPT가 제시한 텍스트
   func calculateSimilarity(_ source: String, _ target: String) -> Double {
       let sourceChars = Array(source)
       let targetChars = Array(target)
       let sourceLength = sourceChars.count
       let targetLength = targetChars.count
       
       // 빈 문자열 처리
       if sourceLength == 0 { return Double(targetLength) }
       if targetLength == 0 { return Double(sourceLength) }
       
       // 거리 계산을 위한 2차원 배열
       var matrix = Array(repeating: Array(repeating: 0, count: targetLength + 1), count: sourceLength + 1)
       
       // 첫 행과 열 초기화
       for i in 0...sourceLength {
           matrix[i][0] = i
       }
       for j in 0...targetLength {
           matrix[0][j] = j
       }
       
       // 행렬 채우기
       for i in 1...sourceLength {
           for j in 1...targetLength {
               let substitutionCost = sourceChars[i-1] == targetChars[j-1] ? 0 : 1
               matrix[i][j] = min(
                   matrix[i-1][j] + 1,              // 삭제
                   matrix[i][j-1] + 1,              // 삽입
                   matrix[i-1][j-1] + substitutionCost  // 교체
               )
           }
       }
       
       // 거리를 유사도 점수(0~1)로 변환
       let distance = Double(matrix[sourceLength][targetLength])
       let maxLength = Double(max(sourceLength, targetLength))
       return 1 - (distance / maxLength)
   }
}

struct LevenshteinStrategyWithNoParenthesis: CalculationStrategy {
    /// - Parameter source: 네이버 책검색 api DB 데이터
    /// - Parameter target: GPT가 제시한 텍스트
   func calculateSimilarity(_ source: String, _ target: String) -> Double {
       let cleanSource = removeParenthesesContent(from: source)
       let sourceChars = Array(cleanSource)
       let targetChars = Array(target)
       let sourceLength = sourceChars.count
       let targetLength = targetChars.count
       
       // 빈 문자열 처리
       if sourceLength == 0 { return Double(targetLength) }
       if targetLength == 0 { return Double(sourceLength) }
       
       // 거리 계산을 위한 2차원 배열
       var matrix = Array(repeating: Array(repeating: 0, count: targetLength + 1), count: sourceLength + 1)
       
       // 첫 행과 열 초기화
       for i in 0...sourceLength {
           matrix[i][0] = i
       }
       for j in 0...targetLength {
           matrix[0][j] = j
       }
       
       // 행렬 채우기
       for i in 1...sourceLength {
           for j in 1...targetLength {
               let substitutionCost = sourceChars[i-1] == targetChars[j-1] ? 0 : 1
               matrix[i][j] = min(
                   matrix[i-1][j] + 1,              // 삭제
                   matrix[i][j-1] + 1,              // 삽입
                   matrix[i-1][j-1] + substitutionCost  // 교체
               )
           }
       }
       
       // 거리를 유사도 점수(0~1)로 변환
       let distance = Double(matrix[sourceLength][targetLength])
       let maxLength = Double(max(sourceLength, targetLength))
       return 1 - (distance / maxLength)
   }
    private func removeParenthesesContent(from text: String) -> String {
            var result = ""
            var depth = 0
            
            for char in text {
                if char == "(" {
                    depth += 1
                } else if char == ")" {
                    depth -= 1
                } else if depth == 0 {
                    result.append(char)
                }
            }
            
            return result
        }
}

//@MainActor
class EnhancedBookSearchManager {
    private let titleStrategies: [(CalculationStrategy, Double)]
    private let authorStrategies: [(CalculationStrategy, Double)]
    private let publisherStrategies: [(CalculationStrategy, Double)]
    
    private let weights: [Double]
    private let initialSearchCount: Int
    
    // 가중치를 주입하는 방식으로 initializer 설계하여, 테스트 간 가중치 조정 가능토록
    init (
        titleStrategies: [(CalculationStrategy, Double)],
        authorStrategies: [(CalculationStrategy, Double)],
        publisherStrategies: [(CalculationStrategy, Double)],
        weights: [Double],
        initialSearchCount: Int
    ) {
        self.titleStrategies = titleStrategies
        self.authorStrategies = authorStrategies
        self.publisherStrategies = publisherStrategies
        
        self.weights = weights
        self.initialSearchCount = initialSearchCount
    }
    
    func process(_ sourceBook: RawBook) async throws -> (book: BookItem, similarities: [Double])? {
        
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
                /// 아니면 그냥 존재하지 않는 값으로 간주하고 nil 반환
                return nil
            }
        }
        
        /// 각 책을 유사도와 매핑시켜 저장하기 위한 튜플 배열을 생성합니다.
        var results = [(index:Int,value:[Double])]()
        
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
        
        /// 가장 높은 유사도 보유한 책 데이터, 책 데이터에 대한 유사도 분포 점수
        return (book: searchedResults[results[0].index], similarities:results[0].value)
    }
    
    func calculateOverAllSimilarity(for searchedBook: BookItem, from targetBook: RawBook) -> [Double] {
        let values = [
            titleStrategies.reduce(0.0) { result, strategy in
                result + (strategy.0.calculateSimilarity(searchedBook.title, targetBook.title) * strategy.1)
            }, authorStrategies.reduce(0.0) { result, strategy in
                result + (strategy.0.calculateSimilarity(searchedBook.author, targetBook.author) * strategy.1)
            }, publisherStrategies.reduce(0.0) { result, strategy in
                result + (strategy.0.calculateSimilarity(searchedBook.publisher, targetBook.publisher) * strategy.1)
            }
        ]

        return values
    }
    
    private func fetchSearchResults(_ query: String,count: Int = 10) async throws -> [BookItem] {
        let queryString = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://openapi.naver.com/v1/search/book.json?query=\(queryString)&display=\(count)&start=1"
        
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
