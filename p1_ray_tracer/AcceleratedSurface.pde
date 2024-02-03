final class AcceleratedMesh {
    Mesh mesh;
    BVHNode bvh;
}

final class BVHNode {
    final BBox bounds;
    final BVHNode left;
    final BVHNode right;
    final int splitAxis;
    final int firstPrimitiveOffset;
    final int nPrimitives;
    final int[] primitiveIndices;

    BVHNode(BBox bounds, BVHNode left, BVHNode right, int splitAxis, int firstPrimitiveOffset, int nPrimitives, int[] primitiveIndices) {
        this.bounds = bounds;
        this.left = left;
        this.right = right;
        this.splitAxis = splitAxis;
        this.firstPrimitiveOffset = firstPrimitiveOffset;
        this.nPrimitives = nPrimitives;
        this.primitiveIndices = primitiveIndices;
    }
}


final class BVHPrimitiveInfo {
    final PVector centroid;
    final PVector pMin;
    final PVector pMax;
    final int primitiveNumber;

    BVHPrimitiveInfo(int primitiveNumber, PVector pMin, PVector pMax) {
        this.primitiveNumber = primitiveNumber;
        this.pMin = pMin;
        this.pMax = pMax;
        this.centroid = pMin.add(pMax).scale(0.5f);
    }
}