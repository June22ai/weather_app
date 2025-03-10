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
    
    // 汎用的なGETリクエストを送信するメソッド
    // ジェネリックにすることで、どの型でも対応できるようにする
    static func request<T: Decodable>(url: URL, method: String = "GET", headers: [String: String]? = nil, completion: @escaping (Result<T, Error>) -> Void) {
        
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
                completion(.failure(error))
                return
            }
            
            // レスポンスの検証レスポンスが正しい（statusCode == 200）ことを確認。
            guard let data = data, (response as? HTTPURLResponse)?.statusCode == 200 else {
                completion(.failure(NSError(domain: "APIError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid Response"])))
                return
            }
            
            do {
                // データがあればJSONに変換
                //成功の場合、受け取ったデータをJSONDecoderでデコードして、ジェネリック型Tのデータに変換
                let decoder = JSONDecoder()
                let decodedData = try decoder.decode(T.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }

    //URL文字列からAPIを呼び出し、その結果をデコードするメソッド
    func fetchData<T: Decodable>(urlString: String, completion: @escaping (Result<T, APIError>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(.badURL))
            return
        }
        //URLSession.shared.dataTaskで非同期にAPIリクエストを送信
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Request failed with error: \(error.localizedDescription)")
                completion(.failure(.requestFailed))
                return
            }
            
            guard let data = data else {
                completion(.failure(.requestFailed))
                return
            }
            
            do {
                //レスポンスが正しく受け取れた場合、JSONDecoderでデータをデコード
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
