//
//  SearchTextField.swift
//  SearchTextField
//
//  Created by Rishu Gupta on 05/12/20.
//

import UIKit

// Drop down position
public enum Position {
    case top
    case bottom
}

public enum HeightType {
    case auto
    case manual
}


protocol SearchTextFieldDelegate: class {
    func didSelect(_ textField: SearchTextField, _ item: ListItem)
    func didFilterList(_ textField: SearchTextField, _ filterList:[ListItem])
    func willOpen()
    func didLoad()
    func didClose()
    func show()
    func close()
}

extension SearchTextFieldDelegate {
    func didFilterList(_ textField: SearchTextField, _ filterList:[ListItem]) {}
    func willOpen() {}
    func didLoad() {}
    func didClose() {}
    func show() {}
    func close() {}
}

class SearchTextField: UITextField, UITextFieldDelegate {
        
    // MARK: Variables
    public weak var customDelegate                              : SearchTextFieldDelegate?
    public var dataList                                         = [ListItem]()
    private var resultsList                                     = [ListItem]()
    private var viewListContainer                               = CornerView()
    private var heightConstant                                  : NSLayoutConstraint?
    private var keyboardHeight                                  : CGFloat?
    private var topLayerAlpha                                   : CGFloat?
    private var contentSizeObserver                             : NSKeyValueObservation?
    
    
    // Configure
    public var parentView: UIView                               = UIView()
    public var alwaysOpen: Bool                                 = true
    public var isSearchEnable: Bool                             = true
    
    // Custom variable
    public var borderColor: UIColor                             = .clear
    public var cornerRadius: CGFloat                            = 7
    public var dropDownHeight: CGFloat                          = 180
    public var heightForRow: CGFloat                            = 46.0
    public var heightType: HeightType                           = .manual
    public var animation: UIView.AnimationOptions               = []
    private let cellIdentifier                                  = "SearchTableViewCell"
    
    fileprivate var tableView : UITableView! {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    
    // Initialization
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        commonInit()
    }
    
    func commonInit() {
        self.delegate = self
    }
    
    // Mark:- Private Methods
    private func create(position: Position = .bottom, positonAuto: Bool = true) {
        tableView = UITableView()
        viewListContainer.tag = 99
        self.parentView.addSubview(viewListContainer)
        viewListContainer.addSubview(tableView)
        
        viewListContainer.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        viewListContainer.borderColor = borderColor
        viewListContainer.bezelArcSize = cornerRadius
        viewListContainer.bottomLeftBezel = true
        viewListContainer.bottomRightBezel = true
        viewListContainer.showShadow = true
        
        if isSearchEnable {
            self.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        } else {
            self.resignFirstResponder()
        }
        
        // TableView setup
        self.setupTableView()
        
        //  Constraint Layout
        viewListContainer.leftAnchor.constraint(equalTo:(self.leftAnchor), constant: 0).isActive = true
        viewListContainer.rightAnchor.constraint(equalTo:(self.rightAnchor), constant: 0).isActive = true
        
        heightConstant = viewListContainer.heightAnchor.constraint(equalToConstant: 0)
        heightConstant?.isActive = true
        
        tableView.topAnchor.constraint(equalTo: (viewListContainer.topAnchor), constant: 0).isActive = true
        tableView.leftAnchor.constraint(equalTo: (viewListContainer.leftAnchor), constant: 0).isActive = true
        tableView.rightAnchor.constraint(equalTo: (viewListContainer.rightAnchor), constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: (viewListContainer.bottomAnchor), constant: 0).isActive = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self,selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification,object: nil)
        
        self.dropDownPosition(position: position, positonAuto: positonAuto)
        
        
        guard let tableView = self.tableView else { return }
        contentSizeObserver = tableView.observe(\.contentSize) { [weak self] tableView, _ in
            guard let self = self else { return }
            let contentHeight = tableView.contentSize.height
            let height = contentHeight < self.dropDownHeightStatus() ? contentHeight : self.dropDownHeightStatus()
            self.heightConstant?.constant = height
        }
        
    }
    
    private func dropDownPosition(position: Position, positonAuto: Bool) {
        var position = position
        if positonAuto == true {
            position = snapDropDownPosition()
        }
        
        switch position {
        case .top:
            viewListContainer.bottomAnchor.constraint(equalTo: self.topAnchor, constant: -5).isActive = true
        case .bottom:
            viewListContainer.topAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        }
    }
        
    private func snapDropDownPosition() -> Position {
        let myViewOriginY = self.frame.origin.y + self.frame.size.height + 5
        let myViewMaxY: CGFloat = 180
        let deviceMaxY = self.parentView.frame.size.height
        
        if myViewOriginY <= 0 {
            return Position.bottom
        } else if (myViewMaxY + myViewOriginY) >= deviceMaxY {
            return Position.top
        }
        return Position.bottom
    }
    
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
            
            self.heightConstant?.constant = self.dropDownHeightStatus()
            self.parentView.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if let _ : NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            keyboardHeight = 0
            
            self.heightConstant?.constant = self.dropDownHeightStatus()
            self.parentView.layoutIfNeeded()
        }
    }
    
    private func dropDownHeightStatus() -> CGFloat {
        if heightType == .auto && snapDropDownPosition() == .bottom {
            let dropDownAutoHeight  = self.parentView.frame.size.height - (self.frame.origin.y) - self.frame.size.height - (keyboardHeight ?? 0)  - 15
            
            return dropDownAutoHeight
        } else {
            return dropDownHeight
        }
    }
    
    private func dropDownAnimation(status:Bool) {
        // Status : true -> Show || false -> Hide
        UIView.animate(withDuration: 0.3, delay:0, options: [animation], animations: {
            if status {
                self.customDelegate?.willOpen()
                self.heightConstant?.constant = self.dropDownHeightStatus()
                self.customDelegate?.didLoad()
            } else {
                self.heightConstant?.constant = 0
                self.customDelegate?.didClose()
                self.heightConstant?.isActive = false
            }
            self.parentView.layoutIfNeeded()
            self.viewListContainer.layoutIfNeeded()
        })
    }
    
    
    private func hideAnimation() {
        if self.parentView.viewWithTag(99) != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
                self.parentView.viewWithTag(99)?.removeFromSuperview()
                self.contentSizeObserver?.invalidate()
                self.contentSizeObserver = nil
            })
            self.parentView.endEditing(true)
            self.dropDownAnimation(status: false)
            
            if !self.resultsList.contains(where: { ($0.name.lowercased() == self.text?.lowercased() ?? "") }) {
                if self.resultsList.count > 0 {
                    self.text = self.resultsList.first?.name
                    self.customDelegate?.didSelect(self, self.resultsList[0])
                }
            }
        }
    }
    
    
    private func showDropDown() {
        guard let parent = self.parentViewController else { return }
        self.parentView = parent.view
        self.cornerRadius = 7
        self.create()
    }
    
    
    // MARK: TextField Delegate Methods
    @objc private func textFieldDidChange(_ textField: UITextField) {
        if self.tableView == nil {
            self.textFieldDidBeginEditing(self)
        }
        
        // // Filtering data
        guard let searchText = textField.text else { return }
        self.resultsList = []
        self.resultsList = self.dataList.filter({ (data) -> Bool in
            let tmp: NSString = data.name as NSString
            let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            return range.location != NSNotFound
        })
        
        if !self.resultsList.isEmpty {
            self.dropDownAnimation(status: true)
        } else {
            self.resultsList = self.dataList
            self.dropDownAnimation(status: alwaysOpen)
        }
        
        self.reloadTableView()
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.showDropDown()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if isSearchEnable {
            self.hideAnimation()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.hideAnimation()
        return true
    }
    
}

// MARK: TableView Delegate Methods
extension SearchTextField : UITableViewDelegate, UITableViewDataSource {
    
    // TableView Configure
    private func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.tableFooterView = UIView()
        
        self.tableView.layer.cornerRadius = 7
        self.tableView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        let nib = UINib(nibName: cellIdentifier, bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: cellIdentifier)
        
        self.resultsList = self.dataList
        self.reloadTableView()
    }
    
    private func reloadTableView() {
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.heightForRow
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.resultsList.isEmpty {
            return 1
        }
        return self.resultsList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SearchTableViewCell
        cell.backgroundColor = UIColor.clear
        
        if self.resultsList.isEmpty {
            cell.setupCell("No data available.")
            return cell
        }
        
        // Set background color for selected cell
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.lightText
        cell.selectedBackgroundView = backgroundView
        
        guard self.resultsList.indices.contains(indexPath.row) else { return cell }
        let data = self.resultsList[indexPath.row]
        cell.setupCell(data.name, icon: data.icon)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.resultsList.isEmpty {
            self.hideAnimation()
            return
        }
        if self.resultsList.indices.contains(indexPath.row) {
            let data = self.resultsList[indexPath.row]
            self.text = data.name
            
            self.customDelegate?.didSelect(self, self.resultsList[indexPath.row])
            self.customDelegate?.didFilterList(self, self.resultsList)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.hideAnimation()
            }
        }
    }
    
}
