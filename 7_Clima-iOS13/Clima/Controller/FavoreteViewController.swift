//
//  FavoreteViewController.swift
//  Clima
//
//  Created by Ai Tanigwa on 2024/12/09.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import UIKit

// Area構造体（既存のコードに追加）
struct Area {
    var isShown: Bool // 都市が表示されているかどうか
    var areaName: String // 地域の名前（例: アジア）
    var cityArray: [String] // 都市名のリスト（例: ベルリン、アムステルダム、ロンドンなど）
}

class FavoreteViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "都市一覧"
        
    }
    
    //前画面から遷移した時
    @IBOutlet weak var tableView:UITableView!
    {
        didSet {
            //tableView.frame = view.frame
            tableView.dataSource = self
            tableView.delegate = self
            //tableView.tableFooterView = UIView()
        }
    }
    
    //既存のデータ構造を利用して、アコーディオン用のデータを設定
    private let headerArray: [String] = ["EU", "アジア", "オセアニア", "アフリカ"]
    private let euArray: [String] = ["ベルリン", "アムステルダム", "ロンドン"]
    private let asianArray: [String] = ["東京", "バンコク"]
    private let oceaniaArray: [String] = ["シドニー", "メルボルン"]
    private let africaArray: [String] = ["ケープタウン"]
    
    private lazy var courseArray = [
        Area(isShown: true, areaName: self.headerArray[0], cityArray: self.euArray),
        Area(isShown: false, areaName: self.headerArray[1], cityArray: self.asianArray),
        Area(isShown: false, areaName: self.headerArray[2], cityArray: self.oceaniaArray),
        Area(isShown: false, areaName: self.headerArray[3], cityArray: self.africaArray)
    ]
    
    // UITableViewDelegateのdidSelectRowAtで遷移処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCity = courseArray[indexPath.section].cityArray[indexPath.row]
        
        // DetailViewControllerに遷移
        navigateToDetailViewController(cityName: selectedCity)
    }
    
    // 遷移先のDetailViewControllerを表示するメソッド
    func navigateToDetailViewController(cityName: String) {
        // DetailViewControllerのインスタンスを作成
        let detailVC = DetailViewController(nibName: "DetailView", bundle: nil)
        
        // 都市名を渡す
        detailVC.cityName = cityName
        
        // ナビゲーションコントローラを使用して遷移
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    
    @IBAction func GoBack(_ sender: UIButton) {
        
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
    
    //アコーディオン機能を反映させるためisShownプロパティに基づいて
    // 表示する行数を決定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courseArray[section].isShown ? courseArray[section].cityArray.count : 0
    }
    //tableView(_:cellForRowAt:)：表示する都市名をセルに設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = courseArray[indexPath.section].cityArray[indexPath.row]
        // セルの右に「>」を追加
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    // セクションのタイトル（国名）のセルに網掛けを設定
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return courseArray[section].areaName
    }
}
//UITableViewDelegateの拡張
//tableView(_:viewForHeaderInSection:)：セクションヘッダーにタップジェスチャーを追加これにより、ヘッダーをタップすると「アコーディオンの開閉」というアクションが実行される
extension FavoreteViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UITableViewHeaderFooterView()
        let gesture = UITapGestureRecognizer(target: self, action: #selector(headerTapped(sender:)))
        headerView.addGestureRecognizer(gesture)
        headerView.tag = section
        headerView.textLabel?.text = courseArray[section].areaName
        // 国名セルに網掛けを追加
        headerView.contentView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        
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

