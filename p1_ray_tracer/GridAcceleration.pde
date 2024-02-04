final class GridAcceleration {
    final Triangle[] triangles;
    final GridNode[] nodes;
    final int dimensionSize;

    GridAcceleration(
        Triangle[] _triangles,
        PVector pMin,
        PVector pMax
    ) {
        this.triangles = _triangles;
        this.dimensionSize = (int)(3 * Math.cbrt(_triangles.length));
        this.nodes = new GridNode[
            dimensionSize * dimensionSize * dimensionSize
        ];
    }
}

final class GridNode {
    final Box box;
    final Triangle[] triangleRefs;

    GridNode(Box box, Triangle[] triangleRefs) {
        this.box = box;
        this.triangleRefs = triangleRefs;
    }
}
