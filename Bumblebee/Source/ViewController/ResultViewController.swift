//
//  ResultViewController.swift
//  Bumblebee
//
//  Created by Naver on 2018. 6. 23..
//  Copyright © 2018년 benpark. All rights reserved.
//

import UIKit

class ResultViewController: ViewController {
 
    @IBOutlet weak var tableView: UITableView!
    
    var items = [ClassificationResult]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    @IBAction func closeButtonTapped(sender: UIButton) {
        (parent as? CameraViewController)?.resultContainerView.isHidden = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier ?? "" {
        case "Web":
            let result = (sender as? String) ?? ""
            if let destination = segue.destination as? WebViewController {
                let newString = result.replacingOccurrences(of: " ", with: "+")
                let urlString = "https://www.google.co.kr/search?q=\(newString)"
                destination.url = URL(string: urlString)
            }
        default: return
        }
    }
}

extension ResultViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell") as? ResultCell
        cell?.titleLabel.text = items[indexPath.row].identifierWithPercent
        return cell ?? UITableViewCell()
    }
}

extension ResultViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "Web", sender: items[indexPath.row].identifier)
    }
}

class ResultCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
}
