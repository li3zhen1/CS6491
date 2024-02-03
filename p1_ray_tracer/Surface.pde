final class Surface implements IRenderableObject {
    Color _color;
    Mesh mesh;
    // ArrayList<PVector> vertices;

    Surface(Color _color) {
        this._color = _color;
        this.mesh = new Mesh();
    }

    Color getColor() {
        return _color;
    }


    PartialHit _getIntersection(Ray ray, SceneGraph sg) {
        return null;
    }

    Hit getIntersection(Ray ray, SceneGraph sg) {
        return null;
    }

    boolean hasIntersection(Ray ray, float mint, float maxt) {
        return false;
    }
}


// static final class _Surface implements IRenderableObject {
//     enum SurfaceKind {
//         // EMPTY,
//         MESH,
//         BOX
//     };

//     SurfaceKind _kind;

//     Color _color;


//     Mesh mesh = null;
//     Box box = null;

//     _Surface(Color _color) {
//         this._color = _color;
//         this.mesh = new Mesh();
//         this._kind = SurfaceKind.MESH;
//     }

//     void convertToBox(Box box) {
//         this.box = box;
//         this._kind = SurfaceKind.BOX;
//     }
    
//     Hit getIntersection(Ray ray, SceneGraph sg) {
//         return null;
//     }

//     boolean hasIntersection(Ray ray, float mint, float maxt) {
//         return false;
//     }
// }