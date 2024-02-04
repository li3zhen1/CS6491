enum Axis {
    X, Y, Z;
}


Box[] splitBox(Box box, Axis axis, float split) {
    Box[] result = new Box[2];
    if (axis == Axis.X) {
        float x = split;
        result[0] = new Box(box.pMin, new PVector(x, box.pMax.y, box.pMax.z));
        result[1] = new Box(new PVector(x, box.pMin.y, box.pMin.z), box.pMax);
    } else if (axis == Axis.Y) {
        float y = split;
        result[0] = new Box(box.pMin, new PVector(box.pMax.x, y, box.pMax.z));
        result[1] = new Box(new PVector(box.pMin.x, y, box.pMin.z), box.pMax);
    } else {
        float z = split;
        result[0] = new Box(box.pMin, new PVector(box.pMax.x, box.pMax.y, z));
        result[1] = new Box(new PVector(box.pMin.x, box.pMin.y, z), box.pMax);
    }
    return result;
}


final class BVHAcceleration<T extends IPrimitive> implements IPrimitive {
    final Box box;
    BVHAcceleration<T> left;
    BVHAcceleration<T> right;
    final ArrayList<T> primitives;
    final int depth;


    Box getBoundingBox() {
        return box;
    }

    BVHAcceleration(Box box, BVHAcceleration left, BVHAcceleration right, int depth) {
        this.box = box;
        this.left = left;
        this.right = right;
        this.depth = depth;
        this.primitives = null;
    }

    BVHAcceleration(Box box, ArrayList<T> primitives, int depth) {
        this.box = box;
        this.left = null;
        this.right = null;
        this.depth = depth;
        this.primitives = primitives;
        // println("depth: " + depth + " primitives: " + primitives.size() + " box: " + box);
    }

    void recursiveSplit() {
        var splitAxis = Axis.X;

        float x = box.pMax.x - box.pMin.x;
        float y = box.pMax.y - box.pMin.y;
        float z = box.pMax.z - box.pMin.z;
        if (y > x && y > z) {
            splitAxis = Axis.Y;
        } else if (z > x && z > y) {
            splitAxis = Axis.Z;
        }

        if (primitives.size() > 1 && depth <30) {
            split(splitAxis);
            if (left != null && left.primitives.size() > 1) {
                left.recursiveSplit();
            }
            if (right != null && right.primitives.size() > 1) {
                right.recursiveSplit();
            }
        }
    }

    void split(Axis axis) {
        
        float split = 0;
        if (axis == Axis.X) {
            split = (box.pMin.x + box.pMax.x) / 2;
        } else if (axis == Axis.Y) {
            split = (box.pMin.y + box.pMax.y) / 2;
        } else {
            split = (box.pMin.z + box.pMax.z) / 2;
        }

        ArrayList<T> leftPrimitives = new ArrayList<T>();
        ArrayList<T> rightPrimitives = new ArrayList<T>();
        for (T primitive : primitives) {
            var centroid = primitive.getBoundingBox().centroid;
            if (axis == Axis.X) {
                if (centroid.x < split) {
                    leftPrimitives.add(primitive);
                } else {
                    rightPrimitives.add(primitive);
                }
            } else if (axis == Axis.Y) {
                if (centroid.y < split) {
                    leftPrimitives.add(primitive);
                } else {
                    rightPrimitives.add(primitive);
                }
            } else {
                if (centroid.z < split) {
                    leftPrimitives.add(primitive);
                } else {
                    rightPrimitives.add(primitive);
                }
            }
        }

        if (leftPrimitives.size() != 0) {
            Box leftBox = leftPrimitives.get(0).getBoundingBox();
            for (T primitive : leftPrimitives) {
                leftBox = union(leftBox, primitive.getBoundingBox());
            }
            left = new BVHAcceleration(leftBox, leftPrimitives, depth + 1);
        }
        else {
            
        }

        if (rightPrimitives.size() != 0) {
            Box rightBox = rightPrimitives.get(0).getBoundingBox();
            for (T primitive : rightPrimitives) {
                rightBox = union(rightBox, primitive.getBoundingBox());
            }
            right = new BVHAcceleration(rightBox, rightPrimitives, depth + 1);
        }
        else {
            right = null;
        }

        primitives.clear();
    }


    void dump() {
        for (int i = 0; i < depth; i++) {
            System.out.print("  ");
        }
        System.out.print("Depth: " + depth + " -- ");
        box.dump();
        if (primitives != null && primitives.size() > 0) {
            for (T primitive : primitives) {
                for (int i = 0; i < depth; i++) {
                    System.out.print("  ");
                }
                System.out.println(primitive);
            }
        } else {
            if (left != null)
            left.dump();
            if (right != null)
            right.dump();
        }
    }


    boolean hasIntersection(Ray ray, float mint, float maxt) {
        var possiblyHasIntersection = box.hasIntersection(ray, 0, Float.MAX_VALUE);
        if (!possiblyHasIntersection) {
            return false;
        }
        if (right == null && left == null) {
            for (T primitive : primitives) {
                if (primitive.hasIntersection(ray, mint, maxt)) {
                    return true;
                }
            }
            return false;
        }
        
        if (left != null) {
            if (left.hasIntersection(ray, mint, maxt) ) {
                return true;
            }
        }
        if (right != null) {
            if (right.hasIntersection(ray, mint, maxt)) {
                return true;
            }
        }
        return false;
    }

    PartialHit _getIntersection(Ray ray, SceneGraph sg) {
        var possiblyHasIntersection = box.hasIntersection(ray, 0, Float.MAX_VALUE);
        if (!possiblyHasIntersection) {
            return null;
        }
        if (right == null && left == null) {
            PartialHit hit = null;
            for (T primitive : primitives) {
                var newHit = primitive._getIntersection(ray, sg);
                if (newHit != null) {
                    if (hit == null || newHit.t0 < hit.t0) {
                        hit = newHit;
                    }
                }
            }
            return hit;
        }
        PartialHit leftHit = null;
        PartialHit rightHit = null;

        if (left != null) {
            leftHit = left._getIntersection(ray, sg);
        }
        if (right != null) {
            rightHit = right._getIntersection(ray, sg);
        }

        if (leftHit == null && rightHit == null) {
            return null;
        }
        if (leftHit == null) {
            return rightHit;
        }
        if (rightHit == null) {
            return leftHit;
        }

        if (leftHit.t0 < rightHit.t0) {
            return leftHit;
        } else {
            return rightHit;
        }
    }
}