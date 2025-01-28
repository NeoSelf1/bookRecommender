/// 테스트 간에 전략 구현 내용 및 스위칭이 유연하게 적용될 수 있어야 함. 미리 프로토콜로 분리
protocol CalculationStrategy {
    func calculateSimilarity(_ source: String, _ target: String) -> Double
}



struct ExactMatchStrategy: CalculationStrategy {
    func calculateSimilarity(_ source: String, _ target: String) -> Double {
        return source == target ? 1.0 : 0.0
    }
}

struct ContainsStrategy: CalculationStrategy {
    func calculateSimilarity(_ source: String, _ target: String) -> Double {
        return target.contains(source) || source.contains(target) ? 1.0 : 0.0
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
