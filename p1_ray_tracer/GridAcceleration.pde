final class GridAcceleration implements IPrimitive {
    final Triangle[] triangles;
    final GridNode[][][] nodes;
    final int dimensionSize;

    final Box box;

    Box getBoundingBox() {
        return box;
    }

    boolean hasIntersection(Ray ray, float mint, float maxt) {

        if (debug_flag) {
            System.out.println("GridAcceleration.hasIntersection");
        }
        if (!box.hasIntersection(ray, mint, maxt)) {
            return false;
        }

        float t0 = mint, t1 = maxt;
        PVector rayOrigin = ray.origin;
        PVector rayDirection = ray.direction;

        // Calculate the voxel coordinates of the entry and exit points of the ray
        PVector invDir = new PVector(1.0f / rayDirection.x, 1.0f / rayDirection.y, 1.0f / rayDirection.z);
        PVector deltaT = new PVector(Math.abs((box.pMax.x - box.pMin.x) * invDir.x / dimensionSize),
                                    Math.abs((box.pMax.y - box.pMin.y) * invDir.y / dimensionSize),
                                    Math.abs((box.pMax.z - box.pMin.z) * invDir.z / dimensionSize));

        // Calculate the stepping direction in the grid
        PVector step = new PVector(Math.signum(rayDirection.x), Math.signum(rayDirection.y), Math.signum(rayDirection.z));
        PVector out = new PVector((step.x > 0 ? box.pMax.x : box.pMin.x),
                                (step.y > 0 ? box.pMax.y : box.pMin.y),
                                (step.z > 0 ? box.pMax.z : box.pMin.z));

        PVector tMax = new PVector((out.x - rayOrigin.x) * invDir.x,
                                (out.y - rayOrigin.y) * invDir.y,
                                (out.z - rayOrigin.z) * invDir.z);

        PVector cell = new PVector((float)Math.floor((rayOrigin.x - box.pMin.x) / (box.pMax.x - box.pMin.x) * dimensionSize),
                                (float)Math.floor((rayOrigin.y - box.pMin.y) / (box.pMax.y - box.pMin.y) * dimensionSize),
                                (float)Math.floor((rayOrigin.z - box.pMin.z) / (box.pMax.z - box.pMin.z) * dimensionSize));

        // March through the grid cells until we find an intersection or exit the grid
        while (true) {
            if (cell.x < 0 || cell.x >= dimensionSize || cell.y < 0 || cell.y >= dimensionSize || cell.z < 0 || cell.z >= dimensionSize) break;

            GridNode node = nodes[(int)cell.x][(int)cell.y][(int)cell.z];
            if (node.triangleRefs != null) {
                for (Triangle triangle : node.triangleRefs) {
                    
                    if (triangle.hasIntersection(ray, mint, maxt)) {
                        return true;
                    }
                }
            }

            // Move to the next cell
            if (tMax.x < tMax.y) {
                if (tMax.x < tMax.z) {
                    cell.x += step.x;
                    tMax.x += deltaT.x;
                } else {
                    cell.z += step.z;
                    tMax.z += deltaT.z;
                }
            } else {
                if (tMax.y < tMax.z) {
                    cell.y += step.y;
                    tMax.y += deltaT.y;
                } else {
                    cell.z += step.z;
                    tMax.z += deltaT.z;
                }
            }

            if (tMax.x > t1 && tMax.y > t1 && tMax.z > t1) break; // Exit if we've passed t1
        }
        return false;
    }


    PartialHit _getIntersection(Ray ray, SceneGraph sg) {

        var pHitBox = box._getIntersection(ray, sg);
        float t0 = 0, t1 = Float.MAX_VALUE;
        if (pHitBox == null) {
            if (debug_flag) {
                System.out.println("GridAcceleration._getIntersection: pHitBox is null");
            }
            return null;
        }
        PVector pHitPoint = pHitBox.position;
        PVector rayOrigin = ray.origin;
        PVector rayDirection = ray.direction;

        var coordinates = this.getVoxelCoordinates(pHitPoint);
        if (debug_flag) {

            print("pHitPoint: " + pHitPoint + "\n");
            print("rayOrigin: " + rayOrigin + "\n");
            print("rayDirection: " + rayDirection + "\n");
            print("coordinates: " + coordinates[0] + " " + coordinates[1] + " " + coordinates[2] + "\n");

        }

        return null;
    }

    int[] getVoxelCoordinates(PVector p) {
        int x = (int)((p.x - box.pMin.x) / (box.pMax.x - box.pMin.x) * dimensionSize);
        int y = (int)((p.y - box.pMin.y) / (box.pMax.y - box.pMin.y) * dimensionSize);
        int z = (int)((p.z - box.pMin.z) / (box.pMax.z - box.pMin.z) * dimensionSize);
        return new int[]{x, y, z};
    }

    void dump() {
        print("GridAcceleration: \n");
        print("  dimensionSize: " + dimensionSize + "\n");
        print("  box: " );
        box.dump();
        print("  nodes: \n");


        for (int x = 0; x < dimensionSize; x++) {
            for (int y = 0; y < dimensionSize; y++) {
                for (int z = 0; z < dimensionSize; z++) {
                    if (nodes[x][y][z].triangleRefs != null) {
                        System.out.println("Node " + x + " " + y + " " + z + " has " + nodes[x][y][z].triangleRefs.size() + " triangles");
                    }
                }
            }
        }
    }

    
    GridAcceleration(
        Triangle[] _triangles,
        PVector _pMin,
        PVector _pMax
    ) {

        this.triangles = _triangles;
        this.dimensionSize = (int)(3 * Math.cbrt(_triangles.length));
        this.nodes = new GridNode[dimensionSize][dimensionSize][dimensionSize];
        this.box = createBoxChecked(_pMin, _pMax);

        PVector pMin = box.pMin;
        PVector pMax = box.pMax;

        pMin.x -= EPSILON;
        pMin.y -= EPSILON;
        pMin.z -= EPSILON;
        pMax.x += EPSILON;
        pMax.y += EPSILON;
        pMax.z += EPSILON;


        var d = dimensionSize;
        for (int x = 0; x < dimensionSize; x++) {
            for (int y = 0; y < dimensionSize; y++) {
                for (int z = 0; z < dimensionSize; z++) {
                    PVector min = new PVector(
                        pMin.x + (pMax.x - pMin.x) * x / d,
                        pMin.y + (pMax.y - pMin.y) * y / d,
                        pMin.z + (pMax.z - pMin.z) * z / d
                    );
                    PVector max = new PVector(
                        pMin.x + (pMax.x - pMin.x) * (x + 1) / d,
                        pMin.y + (pMax.y - pMin.y) * (y + 1) / d,
                        pMin.z + (pMax.z - pMin.z) * (z + 1) / d
                    );

                    Box box = new Box(min, max);
                    nodes[x][y][z] = new GridNode(box);
                }
            }
        }

        for (var triangle : _triangles) {
            Box box = triangle.getBoundingBox();
            PVector min = box.pMin;
            PVector max = box.pMax;

            int x0 = (int)((min.x - pMin.x) / (pMax.x - pMin.x) * d);
            int y0 = (int)((min.y - pMin.y) / (pMax.y - pMin.y) * d);
            int z0 = (int)((min.z - pMin.z) / (pMax.z - pMin.z) * d);
            int x1 = (int)((max.x - pMin.x) / (pMax.x - pMin.x) * d);
            int y1 = (int)((max.y - pMin.y) / (pMax.y - pMin.y) * d);
            int z1 = (int)((max.z - pMin.z) / (pMax.z - pMin.z) * d);

            // if (x0 < 0) x0 = 0;
            // if (y0 < 0) y0 = 0;
            // if (z0 < 0) z0 = 0;
            // if (x1 >= d) x1 = d - 1;
            // if (y1 >= d) y1 = d - 1;
            // if (z1 >= d) z1 = d - 1;

            for (int x = x0; x <= x1; x++) {
                for (int y = y0; y <= y1; y++) {
                    for (int z = z0; z <= z1; z++) {
                        if (nodes[x][y][z].triangleRefs == null) {
                            nodes[x][y][z].triangleRefs = new ArrayList<Triangle>();
                        }
                        nodes[x][y][z].triangleRefs.add(triangle);
                    }
                }
            }
        }
    }
}

final class GridNode {
    final Box box;
    ArrayList<Triangle> triangleRefs;

    GridNode(Box box) {
        this.box = box;
        this.triangleRefs = null;
    }
}
