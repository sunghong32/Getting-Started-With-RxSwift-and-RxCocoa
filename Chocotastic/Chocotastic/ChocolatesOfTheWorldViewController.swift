/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import RxSwift
import RxCocoa

class ChocolatesOfTheWorldViewController: UIViewController {
  private let disposeBag = DisposeBag()
  
  @IBOutlet private var cartButton: UIBarButtonItem!
  @IBOutlet private var tableView: UITableView!
  let europeanChocolates = Observable.just(Chocolate.ofEurope)
  
}

//MARK: View Lifecycle
extension ChocolatesOfTheWorldViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Chocolate!!!"
    
    setupCartObserver()
    setUpCellConfiguration()
    setUpCellTapHandling()
  }
}

//MARK: - Rx Setup
private extension ChocolatesOfTheWorldViewController {
  func setupCartObserver() {
    //1
    ShoppingCart.sharedCart.chocolates.asObservable()
      .subscribe(onNext: { [unowned self] chocolates in
        self.cartButton.title = "\(chocolates.count) 🍫"
      })
      .disposed(by: disposeBag)
  }
  
  func setUpCellConfiguration() {
    //1
    europeanChocolates
      .bind(to: tableView
              .rx //2
              .items(cellIdentifier: ChocolateCell.Identifier,
                     cellType: ChocolateCell.self)) {  row, chocolate, cell in // 3
        cell.configureWithChocolate(chocolate: chocolate)
      }
      .disposed(by: disposeBag)
  }

  func setUpCellTapHandling() {
    tableView
      .rx
      .modelSelected(Chocolate.self) //1
      .subscribe(onNext: { [unowned self] chocolate in //2
        let newValue = ShoppingCart.sharedCart.chocolates.value + [chocolate]
        ShoppingCart.sharedCart.chocolates.accept(newValue) //3

        if let selectRowIndexPath = self.tableView.indexPathForSelectedRow {
          self.tableView.deselectRow(at: selectRowIndexPath, animated: true)
        }
      })
      .disposed(by: disposeBag) //5
  }
}

// MARK: - SegueHandler
extension ChocolatesOfTheWorldViewController: SegueHandler {
  enum SegueIdentifier: String {
    case goToCart
  }
}
