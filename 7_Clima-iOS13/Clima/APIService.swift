//
//  APIService.swift
//  Clima
//
//  Created by Ai Tanigwa on 2025/03/08.
//  Copyright © 2025 App Brewery. All rights reserved.
//

import Foundation
// エラーハンドリング用
enum APIError: Error {
    case badURL
    case requestFailed
    case decodingFailed
    case unknown
}


class APIService {
// 汎用的なAPIリクエストを送信するメソッド
    // ジェネリックにすることで、どの型でも対応できるようにする
    static func request<T: Decodable>(
        urlString: String,
        method: String = "GET",
        headers: [String: String]? = nil,
        completion: @escaping (Result<T, APIError>) -> Void
    ) {
        
        // URL文字列をURL型に変換
        guard let url = URL(string: urlString) else {
            completion(.failure(.badURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        // ヘッダーの追加
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        // URLSession.shared.dataTaskで非同期にAPIリクエストを送信
        // レスポンスを受け取ると、エラーがないか確認
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Request failed with error: \(error.localizedDescription)")
                completion(.failure(.requestFailed))
                return
            }
            
            // レスポンスの検証レスポンスが正しい（statusCode == 200）ことを確認
            guard let data = data, (response as? HTTPURLResponse)?.statusCode == 200 else {
                completion(.failure(.requestFailed))
                return
            }
            
            do {
                // 成功の場合、受け取ったデータをJSONDecoderでデコード
                let decoder = JSONDecoder()
                let decodedData = try decoder.decode(T.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(.decodingFailed))
            }
        }
        
        task.resume()
    }
}
