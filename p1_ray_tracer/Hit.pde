final class PartialHit {
    PVector position;
    PVector normal;
    float t0;

    PartialHit(PVector position, PVector normal, float t0) {
        this.position = position;
        this.normal = normal;
        this.t0 = t0;
    }

    void dump() {
        System.out.println("PartialHit(\n  position: " + position + ",\n"
                + "  normal: " + normal + ",\n"
                + "  t0: " + t0 + "\n)");
    
    }
}


final class Hit {
    final PVector position;
    final PVector normal;
    final Color _color;


    Hit(PVector position, PVector normal, Color _color) {
        this.position = position;
        this.normal = normal;
        this._color = _color;

    }

}
