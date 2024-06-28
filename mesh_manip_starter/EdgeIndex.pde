// Value semantics, directed
public final class EdgeIndex {
    public final int from;
    public final int to;

    public EdgeIndex(int from, int to) {
        this.from = from;
        this.to = to;
    }

    @Override
    public boolean equals(Object o) {
        if (o instanceof EdgeIndex) {
            EdgeIndex e = (EdgeIndex) o;
            return from == e.from && to == e.to;
        }
        return false;
    }

    // @Override
    public int hashCode() {
        return (from << 8) + to;
    }

    public EdgeIndex getReversed() {
        return new EdgeIndex(to, from);
    }
}