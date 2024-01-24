final class Hit {
    PVector position;
    PVector normal;
    Color _color;

    Hit(PVector position, PVector normal, Color _color) {
        this.position = position;
        this.normal = normal;
        this._color = _color;
    }
}
