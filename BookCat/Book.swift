import Foundation

struct BookResponse: Decodable {
    let lastBuildDate: String
    let total: Int
    let start: Int
    let display: Int
    let items: [BookItem]
}

struct BookItem: Identifiable, Decodable, Hashable {
    let id: UUID = UUID()
    let title: String          // 책 제목
    let link: String          // 네이버 도서 정보 URL
    let image: String         // 섬네일 이미지 URL
    let author: String        // 저자 이름
    let discount: String?        // 판매 가격 (optional - 절판 등의 이유로 없을 수 있음)
    let publisher: String     // 출판사
    let isbn: String         // ISBN
    let description: String   // 책 소개
    let pubdate: String      // 출간일
    
    enum CodingKeys: String, CodingKey {
        case title, link, image, author, discount, publisher, isbn, description, pubdate
    }
}

struct ChatGPTResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
        
        struct Message: Codable {
            let content: String
        }
    }
}


/// GPT로부터 받은 Raw 데이터입니다.
struct ChatGPTRecommendation: Codable {
    let ownedBooks: [String]
    let newBooks: [String]
}

struct RawBook: Codable {
    let title: String
    let author: String
    let publisher: String
}
