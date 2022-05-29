//

import UI

class ProductHomeDialogViewModel: TableModelViewItem<ProductHomeDialogViewCell> {
    
    override func bind(viewCell: ProductHomeDialogViewCell) {
        viewCell.productImage.image = Assets.image(named: "icnReceipts")
        viewCell.productLabel.text = "Detalle Cuenta"
    }
    
}
