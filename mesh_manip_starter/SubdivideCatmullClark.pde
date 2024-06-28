
Mesh createCatmullClarkSubdivision(Mesh original) {
    if (original == null) {
        println("Error: createCatmullClarkSubdivision called with null mesh");
        return null;
    }
    var subdivisionMesh = new Mesh();

    var facePoints = new HashMap<Face, Vertex>();
    var edgePoints = new HashMap<EdgeIndex, Vertex>();
    var vertexPoints = new HashMap<Vertex, Vertex>();
    var vertexIndices = new HashMap<Vertex, Integer>();

    for (Face f: original.faces) {
        var facePoint = original.getCentroid(f);
        facePoints.put(f, facePoint);
    }
    for (DirectedEdge de: original.edges) {
        if (edgePoints.containsKey(
            new EdgeIndex(de.to, de.from)
        )) { continue; }

        var m = original.vertices.get(de.from);
        var e = original.vertices.get(de.to);
        var a = facePoints.get(de.face);
        var f = facePoints.get(de.oppo.face);

        var edgePoint = new Vertex(
            (m.x + e.x + a.x + f.x) / 4,
            (m.y + e.y + a.y + f.y) / 4,
            (m.z + e.z + a.z + f.z) / 4
        );

        edgePoints.put(de.getEdgeIndex(), edgePoint);
    }

    float fx, fy, fz;
    float rx, ry, rz;
    int n;

    for (DirectedEdge de: original.edges) {
        var v = original.vertices.get(de.from);
        if (vertexPoints.containsKey(v)) { continue; }

        DirectedEdge curr = de;
        fx = fy = fz = 0;
        rx = ry = rz = 0;
        n = 0;
        
        do {
            var facePoint = facePoints.get(curr.face);

            fx += facePoint.x;
            fy += facePoint.y;
            fz += facePoint.z;

            var edgeFrom = original.vertices.get(curr.from);
            var edgeTo = original.vertices.get(curr.to);

            rx += edgeFrom.x + edgeTo.x;
            ry += edgeFrom.y + edgeTo.y;
            rz += edgeFrom.z + edgeTo.z;

            n++;

            curr = curr.getSwing();
        } while (curr != de);

        fx /= n;
        fy /= n;
        fz /= n;

        rx /= n*2;
        ry /= n*2;
        rz /= n*2;

        var vertexPoint = new Vertex(
            (fx + 2 * rx + v.x * (n - 3)) / n,
            (fy + 2 * ry + v.y * (n - 3)) / n,
            (fz + 2 * rz + v.z * (n - 3)) / n
        );

        vertexPoints.put(v, vertexPoint);
    }

    int vi = 0;
    for (Vertex v: vertexPoints.values()) {
        vertexIndices.put(v, vi++);
        subdivisionMesh.vertices.add(v);
    }
    for (Vertex v: edgePoints.values()) {
        vertexIndices.put(v, vi++);
        subdivisionMesh.vertices.add(v);
    }
    for (Vertex v: facePoints.values()) {
        vertexIndices.put(v, vi++);
        subdivisionMesh.vertices.add(v);
    }



    for (Face f: original.faces) {
        var fp = facePoints.get(f);
        var fpi = vertexIndices.get(fp);
        
        var curr = f.edge;
        do {
            // fp -> ep -> vp -> enp -> fp
            var currEi = curr.getEdgeIndex();
            var ep = edgePoints.get(currEi);
            if (ep == null) {
                ep = edgePoints.get(currEi.getReversed());
            }
            var epi = vertexIndices.get(ep);

            var vp = vertexPoints.get(original.vertices.get(curr.to));
            var vpi = vertexIndices.get(vp);

            var nextEi = curr.next.getEdgeIndex();
            var enp = edgePoints.get(nextEi);
            if (enp == null) {
                enp = edgePoints.get(nextEi.getReversed());
            }
            var enpi = vertexIndices.get(enp);


            // println(
            //     "fpi = " + fpi + 
            //     ", epi = " + epi + 
            //     ", vpi = " + vpi + 
            //     ", enpi = " + enpi
            // );

            subdivisionMesh.addFace(
                new int[] {fpi, epi, vpi, enpi}
            );
            
            curr = curr.next;
        } while (curr != f.edge);
    }

    subdivisionMesh.seal();

    println("======= Catmull-Clark Subdivision =======");
    println("Vertices: " + subdivisionMesh.vertices.size());
    
    return subdivisionMesh;

}