class Color {
    float r;
    float g;
    float b;

    Color(float r, float g, float b) {
        this.r = r;
        this.g = g;
        this.b = b;
    }

    color asValue() {
        return color(r * 255, g * 255, b * 255);
    }
}