
final class KDNode implements IPrimitive {

    void dump() {
        for (int i = 0; i < depth; i++) {
            System.out.print("  ");
        }
        System.out.print("- " + primitive.size() + " " + depth + "   ");
        if(bound!=null) {
            bound.dump();
        }
        else {
            println();
        }
        if (children != null) {
            for (int i = 0; i < 8; i++) {
                children[i].dump();
            }
        }
    }

    Box getBoundingBox() {
        return bound;
    }


    final ArrayList<IPrimitive> primitive;
    Box bound;
    final int depth;

    KDNode(int depth) {
        this.depth = depth;
        this.bound = null;
        this.primitive = new ArrayList<IPrimitive>();
    }

    KDNode(ArrayList<IPrimitive> primitive, Box bound, int depth) {
        this.primitive = primitive;
        this.bound = bound;
        this.depth = depth;
    }

    KDNode children[]; 

    void split() {
        if (primitive.size() <= 1) {
            return;
        }
        children = new KDNode[8];
        for (int i = 0; i < 8; i++) {
            children[i] = new KDNode(depth+1);
        }
        for (int i = 0; i < primitive.size(); i++) {
            int index = 0;
            IPrimitive p = primitive.get(i);
            var box = p.getBoundingBox();
            if (box.centroid.x > bound.centroid.x) {
                index |= 1;
            }
            if (box.centroid.y > bound.centroid.y) {
                index |= 2;
            }
            if (box.centroid.z > bound.centroid.z) {
                index |= 4;
            }
            children[index].primitive.add(p);
            if (children[index].bound == null) {
                children[index].bound = box;
            } else {
                children[index].bound = union(children[index].bound, box);
            }
        }
        for (int i = 0; i < 8; i++) {
            if (children[i].primitive.size() > 1 && depth < 20) {
                children[i].split();
            }
        }
    }

    boolean hasIntersection(Ray ray, float mint, float maxt) {
        if (bound==null || bound.hasIntersection(ray, mint, maxt)) {
            return false;
        }
        if (children == null) {
            for (int i = 0; i < primitive.size(); i++) {
                if (primitive.get(i).hasIntersection(ray, mint, maxt)) {
                    return true;
                }
            }
            return false;
        }
        
        for (int i = 0; i < 8; i++) {
            if (children[i].hasIntersection(ray, mint, maxt)) {
                return true;
            }
        }
        return false;
    }

    PartialHit _getIntersection(Ray ray, SceneGraph sg) {
        if (bound==null || !bound.hasIntersection(ray, 0, Float.MAX_VALUE) ) {
            return null;
        }
        if (children == null) {
            PartialHit closestHit = null;
            for (int i = 0; i < primitive.size(); i++) {
                var ph = primitive.get(i)._getIntersection(ray, sg);
                if (ph != null) {
                    if (closestHit == null || ph.t0 < closestHit.t0) {
                        closestHit = ph;
                    }
                }
            }
            
            return closestHit;
        }
        
        PartialHit closestHit = null;
        for (int i = 0; i < 8; i++) {
            var ph = children[i]._getIntersection(ray, sg);

            if (ph != null) {
                if (closestHit == null || ph.t0 < closestHit.t0) {
                    closestHit = ph;
                }
            }
                
        }
        return closestHit;
    }

}

