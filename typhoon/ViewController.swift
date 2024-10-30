//
//  ViewController.swift
//  typhoon
//
//  Created by johnliang on 2024/10/30.
//

import UIKit
import AVFoundation

struct RegionStatus {
    let region: String
    let status: String
}

class ViewController: UIViewController {

    // 添加背景漸層層
    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(red: 0.4, green: 0.8, blue: 0.9, alpha: 1.0).cgColor,
            UIColor(red: 0.2, green: 0.6, blue: 0.8, alpha: 1.0).cgColor
        ]
        return layer
    }()
    
    // 美化標題標籤
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "颱風假不假"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .white
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOffset = CGSize(width: 0, height: 2)
        label.layer.shadowOpacity = 0.3
        label.layer.shadowRadius = 4
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 添加卡片視圖作為容器
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // 美化選擇器
    private lazy var cityPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.backgroundColor = .clear
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.dataSource = self
        picker.delegate = self
        return picker
    }()
    
    // 美化結果標籤
    private let resultLabel: UILabel = {
        let label = UILabel()
        label.text = "有放假喔!"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.textColor = UIColor(red: 0.2, green: 0.6, blue: 0.8, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let holidayImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // 添加音效播放器
    private var audioPlayer: AVAudioPlayer?
    
    // 台灣縣市資料
    private let cities = ["台北市", "新北市", "基隆市", "桃園市", "新竹市", "新竹縣", 
                         "苗栗縣", "台中市", "彰化縣", "南投縣", "雲林縣", "嘉義市", 
                         "嘉義縣", "台南市", "高雄市", "屏東縣", "宜蘭縣", "花蓮縣", 
                         "台東縣", "澎湖縣", "金門縣", "連江縣"]

    // 添加數據模型
    private var regionStatuses: [RegionStatus] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 設置 UI
        setupUI()
        
        // 獲取數據
        fetchAndParseData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
    private func setupUI() {
        // 設置背景漸層
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        // 添加子視圖
        view.addSubview(titleLabel)
        view.addSubview(cardView)
        cardView.addSubview(cityPicker)
        cardView.addSubview(resultLabel)
        view.addSubview(holidayImageView)
        
        // 設置約束
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            cardView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            cityPicker.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 10),
            cityPicker.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            cityPicker.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            cityPicker.heightAnchor.constraint(equalToConstant: 150),
            
            resultLabel.topAnchor.constraint(equalTo: cityPicker.bottomAnchor, constant: 10),
            resultLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            resultLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            resultLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20),
            
            holidayImageView.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 30),
            holidayImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            holidayImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            holidayImageView.heightAnchor.constraint(equalTo: holidayImageView.widthAnchor),
            holidayImageView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func fetchAndParseData() {
        let urlString = "https://www.dgpa.gov.tw/typh/daily/nds.html"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.addValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
        
        URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            guard let data = data,
                  let htmlString = String(data: data, encoding: .utf8) else { return }
            
            self?.parseHTML(htmlString)
        }.resume()
    }
    
    private func parseHTML(_ htmlString: String) {
        // ... 保持原有的解析邏輯 ...
        if let tableStart = htmlString.range(of: "<TABLE id=\"Table\" rules=\"ALL\""),
           let tableEnd = htmlString.range(of: "</TABLE>", range: tableStart.upperBound..<htmlString.endIndex) {
            
            let tableContent = htmlString[tableStart.lowerBound...tableEnd.upperBound]
            
            if let tbodyStart = tableContent.range(of: "<TBODY class=\"Table_Body\">"),
               let tbodyEnd = tableContent.range(of: "</TBODY>", range: tbodyStart.upperBound..<tableContent.endIndex) {
                
                let tbodyContent = tableContent[tbodyStart.upperBound..<tbodyEnd.lowerBound]
                var rows = String(tbodyContent).components(separatedBy: "<TR>")
                    .filter { !$0.isEmpty }
                
                if !rows.isEmpty {
                    rows.removeLast()
                }
                
                regionStatuses.removeAll()
                
                for row in rows {
                    let cells = row.components(separatedBy: "<TD")
                        .compactMap { cell -> String? in
                            if let endIndex = cell.range(of: "</TD>")?.lowerBound,
                               let startIndex = cell.range(of: ">")?.upperBound {
                                var content = String(cell[startIndex..<endIndex])
                                    .trimmingCharacters(in: .whitespacesAndNewlines)
                                    .replacingOccurrences(of: "&nbsp;", with: "")
                                
                                if let fontStart = content.range(of: "<FONT"),
                                   let fontStartClose = content.range(of: ">", range: fontStart.upperBound..<content.endIndex),
                                   let fontEnd = content.range(of: "</FONT>") {
                                    content = String(content[fontStartClose.upperBound..<fontEnd.lowerBound])
                                }
                                
                                return content.isEmpty ? nil : content
                            }
                            return nil
                        }
                    
                    if cells.count >= 2 {
                        regionStatuses.append(RegionStatus(region: cells[0], status: cells[1]))
                    }
                }
                
                // 在主線程更新 UI
                DispatchQueue.main.async { [weak self] in
                    self?.cityPicker.reloadAllComponents()
                    // 更新初始選擇的城市狀態
                    self?.updateStatusForSelectedCity(row: 0)
                }
            }
        }
    }
    
    private func playSound(named fileName: String) {
        guard let path = Bundle.main.path(forResource: fileName, ofType: "mp3") else {
            print("找不到音效文件：\(fileName)")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("播放音效失敗：\(error.localizedDescription)")
        }
    }
    
    // 更新狀態時添加動畫
    private func updateStatusForSelectedCity(row: Int) {
        let selectedCity = cities[row]
        
        if let regionStatus = regionStatuses.first(where: { 
            $0.region.replacingOccurrences(of: "臺", with: "台") == 
            selectedCity.replacingOccurrences(of: "臺", with: "台") 
        }) {
            DispatchQueue.main.async { [weak self] in
                // 添加動畫效果
                UIView.transition(with: self?.resultLabel ?? UIView(), 
                                duration: 0.3,
                                options: .transitionCrossDissolve,
                                animations: {
                    self?.resultLabel.text = regionStatus.status
                })
                
                UIView.transition(with: self?.holidayImageView ?? UIView(),
                                duration: 0.5,
                                options: .transitionCrossDissolve,
                                animations: {
                    if regionStatus.status.contains("停止上課") {
                        self?.holidayImageView.image = UIImage(named: "karaoke")
                        self?.resultLabel.textColor = UIColor(red: 0.2, green: 0.7, blue: 0.3, alpha: 1.0)
                        self?.playSound(named: "happy")
                    } else {
                        self?.holidayImageView.image = UIImage(named: "hardwork")
                        self?.resultLabel.textColor = UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)
                        self?.playSound(named: "sad")
                    }
                })
            }
        }
    }
}

// MARK: - UIPickerViewDataSource
extension ViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return cities.count
    }
}

// MARK: - UIPickerViewDelegate
extension ViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.text = cities[row]
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .center
        label.textColor = UIColor(red: 0.2, green: 0.6, blue: 0.8, alpha: 1.0)
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        updateStatusForSelectedCity(row: row)
    }
}


