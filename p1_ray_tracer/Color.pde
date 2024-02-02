final class Color {
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


    Color multiplying(float factor) {
        return new Color(r * factor, g * factor, b * factor);
    }

    Color adding(Color other) { 
        return new Color(r + other.r, g + other.g, b + other.b);
    }

    void add(Color other) {
        r += other.r;
        g += other.g;
        b += other.b;
    }

    Color elementwiseMultiplying(Color other) {
        return new Color(r * other.r, g * other.g, b * other.b);
    }
}