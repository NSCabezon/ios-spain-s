import Foundation

class ClassicCarouselDatasource: NSObject, ClassicCarouselDatasourceType {
    var requiredHeight: CGFloat {
        return dataSource.reduce(0) { (result, item) -> CGFloat in
            return max(result, item.requiredHeight)
        }
    }
    
    var numberOfItems: Int {
        return dataSource.count
    }
    var dataSource = [CarouselClassicItemViewModelType]()
    var maxWidth: CGFloat = 300
    var onChangeIndex: ((Int) -> Void)?

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "classicCarouselCell", for: indexPath) as? ClassicCarouselCollectionViewCell
            else { return UICollectionViewCell() }
        cell.setViewModel(dataSource[indexPath.item])
        return cell
    }
}

extension ClassicCarouselDatasource: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: maxWidth, height: dataSource[indexPath.item].requiredHeight)
    }
}

extension ClassicCarouselDatasource: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offSet = scrollView.contentOffset.x
        let width = scrollView.frame.width
        let horizontalCenter = width / 2
        let currentPage = Int(offSet + horizontalCenter) / Int(width)
        onChangeIndex?(currentPage)
    }
}
