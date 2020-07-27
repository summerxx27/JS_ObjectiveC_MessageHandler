//
//  ViewController.swift
//  Swift-JavaScriptCore
//
//  Created by summerxx on 2020/7/27.
//  Copyright © 2020 summerxx. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let cellId = "cellId"
    var tableView = UITableView()
    let dataArray = ["WKWebView"]
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Swift-JavaScriptCore"
        self.view.backgroundColor = UIColor.white
        self.addTab()
    }
    
    func addTab() -> Void {
        tableView = UITableView.init(frame: CGRect.init(x: 0, y: 64, width: self.view.frame.size.width, height: self.view.frame.size.height - 64))
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.rowHeight = 44
        self.view.addSubview(tableView)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: UITableViewCell.CellStyle.value1, reuseIdentifier: cellId) as UITableViewCell
        cell.textLabel?.text = dataArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0:
            let wkVC = WKWebViewViewController()
            self.navigationController?.pushViewController(wkVC, animated: true)
        default:
            print("default")
        }
    }
    
}

