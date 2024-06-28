Mesh addNoiseOnDirectionOfNormal(
    Mesh original,
    float noiseScale
) {
    if (original == null) {
        return null;
    }

    original.addNoiseOnDirectionOfNormal(noiseScale);
    return original;
}