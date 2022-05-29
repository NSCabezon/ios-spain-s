// TODO: This method was in legacy, temporally moved here, need check every view where is used if behaviour is the same. 
extension UIView {
    func embedInto(container: UIView, insets: UIEdgeInsets = UIEdgeInsets()) {
        container.addSubview(self)

        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: container.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: insets.right),
            bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: insets.bottom)
        ])
    }
    
    func embedInto(container: UIView, padding: CGFloat) {
        embedInto(container: container, insets: paddingToInsets(padding: padding))
    }
    
    private func paddingToInsets(padding: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: padding, left: padding, bottom: -padding, right: -padding)
    }
}
