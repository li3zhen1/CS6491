final class BVHAcceleration {
    final Triangle[] triangles;

    BVHAcceleration(Triangle[] triangles) {
        this.triangles = triangles;
    }
}

final class BVHNode {
    BVHNode left;
    BVHNode right;
    Box boundingBox;
    int start;
    int end;
}
