//
//  Util.swift
//  BookCat
//
//  Created by Neoself on 1/26/25.
//
import Foundation

func loadEnv() -> [String: String]? {
    guard let filePath = Bundle.main.path(forResource: ".env", ofType: "") else {
        print(".env 파일을 찾을 수 없습니다")
        return nil
    }
    
    do {
        let contents = try String(contentsOfFile: filePath)
        var envDict: [String: String] = [:]
        
        // 각 줄을 파싱하여 환경 변수로 저장
        let lines = contents.split(separator: "\n")
        for line in lines {
            let components = line.split(separator: "=")
            if components.count == 2 {
                let key = String(components[0]).trimmingCharacters(in: .whitespacesAndNewlines)
                let value = String(components[1]).trimmingCharacters(in: .whitespacesAndNewlines)
                envDict[key] = value
            }
        }
        return envDict
    } catch {
        print("Error reading .env file: \(error)")
        return nil
    }
}
