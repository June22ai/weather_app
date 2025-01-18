//
//  FavoreteViewController.swift
//  Clima
//
//  Created by Ai Tanigwa on 2024/12/09.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import UIKit

// rail構造体（既存のコードに追加）
struct Rail {
    var isShown: Bool // 鉄道線が表示されているかどうか
    var railName: String // 鉄道線の名前（例: 山手線）
    var stationArray: [String] // 駅名のリスト（例: 渋谷、新宿、池袋など）
}

class FavoreteViewController: UIViewController {
    
    //    override func viewDidLoad() {
    //        super.viewDidLoad()
    //
    //        // Do any additional setup after loading the view.
    //    }
    //前画面から遷移した時
    @IBOutlet weak var tableView:UITableView!
    //@IBOutlet var tableView: UITableView!
    {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    //既存のデータ構造を利用して、アコーディオン用のデータを設定
    private let headerArray: [String] = ["山手線", "東横線", "田園都市線", "常磐線"]
    private let yamanoteArray: [String] = ["渋谷", "新宿", "池袋"]
    private let toyokoArray: [String] = ["自由ヶ丘", "日吉"]
    private let dentoArray: [String] = ["溝の口", "二子玉川"]
    private let jobanArray: [String] = ["上野"]
    
    private lazy var courseArray = [
        Rail(isShown: true, railName: self.headerArray[0], stationArray: self.yamanoteArray),
        Rail(isShown: false, railName: self.headerArray[1], stationArray: self.toyokoArray),
        Rail(isShown: false, railName: self.headerArray[2], stationArray: self.dentoArray),
        Rail(isShown: false, railName: self.headerArray[3], stationArray: self.jobanArray)
    ]
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //segue.destinationがFavoreteViewController型かどうかをチェック
        if segue.destination is FavoreteViewController {
            // 型チェックだけ行って特に処理はしない
            print("遷移先は FavoreteViewController です")
            
        }
    }
    @IBAction func GoBack(_ sender: UIButton) {
        //今回はナビゲーションコントローラーは使用していないので↓が呼ばれる事はない
        if let navigationController = self.navigationController {
            //ナビゲーションスタックの一番上の画面（FavoriteViewController）をポップして戻る
            navigationController.popViewController(animated: true)
        } else {
            // モーダル遷移している場合はdismissを使う
            dismiss(animated: true, completion: nil)
        }
        
    }
}
//UITableViewDataSourceの拡張
extension FavoreteViewController: UITableViewDataSource {
    // courseArrayの数を返す
    func numberOfSections(in tableView: UITableView) -> Int {
        return courseArray.count
    }
    // アコーディオン機能を反映させるためisShownプロパティに基づいて
    // 表示する行数を決定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if courseArray[section].isShown {
            return courseArray[section].stationArray.count
        } else {
            return 0
        }
    }
    //tableView(_:cellForRowAt:)：表示する駅名をセルに設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = courseArray[indexPath.section].stationArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return courseArray[section].railName
    }
}
//UITableViewDelegateの拡張
//tableView(_:viewForHeaderInSection:)：セクションヘッダーにタップジェスチャーを追加これにより、ヘッダーをタップすると「アコーディオンの開閉」というアクションが実行される
extension FavoreteViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UITableViewHeaderFooterView()
        //headerTapped(sender:)ヘッダーがタップされると、該当セクションの isShown プロパティを切り替えて、テーブルビューの該当セクションを再読み込み
        let gesture = UITapGestureRecognizer(target: self, action: #selector(headerTapped(sender:)))
        headerView.addGestureRecognizer(gesture)
        headerView.tag = section
        headerView.textLabel?.text = courseArray[section].railName
        return headerView
    }
    
    @objc func headerTapped(sender: UITapGestureRecognizer) {
        guard let section = sender.view?.tag else { return }
        
        // アコーディオンの開閉（ビューの表示・非表示）切り替え(toggle)
        // 展開状態を保持するために isShown フラグを使用
        courseArray[section].isShown.toggle()
        
        // セクションのアニメーション付き更新
        tableView.beginUpdates()
        tableView.reloadSections([section], with: .automatic)
        tableView.endUpdates()
    }
}
