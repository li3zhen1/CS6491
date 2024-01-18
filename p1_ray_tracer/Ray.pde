
class Ray {
    PVector origin;
    PVector direction;

    Ray(PVector origin, PVector direction) {
        this.origin = origin;
        this.direction = direction;
    }

    void dump() {
        println("Ray");
        println("  origin: " + origin.x + " " + origin.y + " " + origin.z);
        println("  direction: " + direction.x + " " + direction.y + " " + direction.z);
    }


    public Hit intersect(Surface surface) {

        Tuple<PVector, PVector> result = null;

        for (int i = 0; i < surface.vertices.size() / 3; i++) {
            var intersection = _intersect(surface, i * 3);

            if (intersection != null) {
                if (debug_flag) {
                    println("point: " + intersection.first);
                }
                if (result == null) {
                    result = intersection;
                } else {
                    var distance = PVector.dist(origin, intersection.first);
                    var closestDistance = PVector.dist(origin, result.first);
                    if (distance < closestDistance) {
                        result = intersection;
                    }
                }
            }
        }
        if (result == null) {
            return null;
        }
        return new Hit(result.first, result.second, surface._color);
    }


    // returns (point, normal)
    private Tuple<PVector, PVector> _intersect(Surface surface, int startIndex) {

        var v1 = surface.getVertex(startIndex);
        var v2 = surface.getVertex(startIndex + 1);
        var v3 = surface.getVertex(startIndex + 2);
        var e1 = PVector.sub(v2, v1);
        var e2 = PVector.sub(v3, v1);

        var h = direction.cross(e2);
        var a = e1.dot(h);

        if (a > -1e-6 && a < 1e-6) {
            return null;
        }

        var f = 1.0 / a;
        var s = PVector.sub(origin, v1);
        var u = f * s.dot(h);

        if (u < 0.0 || u > 1.0) {
            return null;
        }

        var q = s.cross(e1);
        var v = f * PVector.dot(direction, q);

        if (v < 0.0 || u + v > 1.0) {
            return null;
        }

        var t = f * PVector.dot(e2, q);

        if (t > 0) {
            var point = PVector.add(origin, PVector.mult(direction, t));
            var normal = e1.cross(e2);
            normal.normalize();
            if (direction.dot(normal) > 0) {
                normal.mult(-1);
            }
            return new Tuple<PVector, PVector>(point, normal);
        } else {
            return null;
        }
    }
}
