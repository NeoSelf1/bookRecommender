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
        
        // 현재 처리 중인 키와 값을 저장할 변수들
        var currentKey: String?
        var currentValue = ""
        var isMultiline = false
        
        // 각 줄을 처리
        let lines = contents.split(separator: "\n", omittingEmptySubsequences: false)
        for line in lines {
            let trimmedLine = String(line).trimmingCharacters(in: .whitespacesAndNewlines)
            
            if !isMultiline {
                // 새로운 키-값 쌍의 시작인 경우
                if trimmedLine.contains("=") {
                    let parts = trimmedLine.split(separator: "=")
                    currentKey = String(parts[0]).trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    let value = String(parts[1]).trimmingCharacters(in: .whitespacesAndNewlines)
                    if value.hasPrefix("`") {
                        // 멀티라인 값 시작
                        isMultiline = true
                        currentValue = String(value.dropFirst()) + "\n"
                    } else {
                        // 일반 한 줄 값
                        envDict[currentKey!] = value
                        currentKey = nil
                    }
                }
            } else {
                // 멀티라인 값 처리 중
                if trimmedLine.hasSuffix("`") {
                    // 멀티라인 값 종료
                    currentValue += String(trimmedLine.dropLast())
                    if let key = currentKey {
                        envDict[key] = currentValue
                    }
                    currentKey = nil
                    currentValue = ""
                    isMultiline = false
                } else {
                    // 멀티라인 값 계속
                    currentValue += trimmedLine + "\n"
                }
            }
        }
        
        return envDict
    } catch {
        print("Error reading .env file: \(error)")
        return nil
    }
}
