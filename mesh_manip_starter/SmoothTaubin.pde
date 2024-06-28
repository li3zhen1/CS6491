final float lambda1 = 0.6307f;
final float lambda2 = -0.67315f;


Mesh createTaubinSmooth(Mesh original, int iteration) {
    if (original == null) {
        println("Error: createTaubianSmooth called with null mesh");
        return null;
    }

    var m = original;
    for (var i = 0; i < iteration; i++) {
        m = _createLaplacianSmooth(
            _createLaplacianSmooth(m, lambda1),
            lambda2
        );
    }
    m.seal();
    return m;

}